import os
import subprocess
import tempfile
import uuid
from flask import Flask, request, jsonify, render_template, send_file, abort
from werkzeug.utils import secure_filename
from werkzeug.middleware.proxy_fix import ProxyFix
import threading
import time
import logging

app = Flask(__name__)
app.secret_key = os.environ.get("SESSION_SECRET", "dev-key-change-in-production")
app.wsgi_app = ProxyFix(app.wsgi_app, x_proto=1, x_host=1)
app.config['MAX_CONTENT_LENGTH'] = 500 * 1024 * 1024  # 500MB max file size
app.config['UPLOAD_FOLDER'] = 'uploads'
app.config['OUTPUT_FOLDER'] = 'output'

# Set up logging
logging.basicConfig(level=logging.DEBUG)

# Create necessary directories
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
os.makedirs(app.config['OUTPUT_FOLDER'], exist_ok=True)

# Store processing tasks
processing_tasks = {}

def check_ffmpeg():
    """Check if FFmpeg is available"""
    try:
        subprocess.run(['ffmpeg', '-version'], capture_output=True, check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False

def parse_time_to_seconds(time_str):
    """Parse time string to seconds"""
    time_str = time_str.lower().strip()
    total_seconds = 0
    
    # Handle various time formats
    if 'minute' in time_str and 'second' in time_str:
        # e.g., "1 minute 30 seconds"
        parts = time_str.split()
        for i, part in enumerate(parts):
            if part.isdigit():
                if i + 1 < len(parts):
                    if 'minute' in parts[i + 1]:
                        total_seconds += int(part) * 60
                    elif 'second' in parts[i + 1]:
                        total_seconds += int(part)
    elif 'minute' in time_str:
        # e.g., "2 minutes"
        import re
        minutes = re.findall(r'(\d+)\s*minute', time_str)
        if minutes:
            total_seconds += int(minutes[0]) * 60
    elif 'second' in time_str:
        # e.g., "30 seconds"
        import re
        seconds = re.findall(r'(\d+)\s*second', time_str)
        if seconds:
            total_seconds += int(seconds[0])
    elif time_str.replace('.', '').isdigit():
        # Plain number, assume seconds
        total_seconds = float(time_str)
    
    return total_seconds

def cut_video(input_path, output_path, start_time, end_time, task_id):
    """Cut video using FFmpeg"""
    try:
        processing_tasks[task_id]['status'] = 'processing'
        processing_tasks[task_id]['message'] = 'Cutting video...'
        
        # Ensure output directory exists
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        
        # FFmpeg command
        cmd = [
            'ffmpeg', '-i', input_path,
            '-ss', str(start_time),
            '-to', str(end_time),
            '-c', 'copy',
            '-avoid_negative_ts', 'make_zero',
            '-y', output_path
        ]
        
        # Run FFmpeg
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            processing_tasks[task_id]['status'] = 'completed'
            processing_tasks[task_id]['message'] = 'Video cut successfully!'
            processing_tasks[task_id]['output_file'] = output_path
        else:
            processing_tasks[task_id]['status'] = 'error'
            processing_tasks[task_id]['message'] = f'FFmpeg error: {result.stderr}'
            
    except Exception as e:
        processing_tasks[task_id]['status'] = 'error'
        processing_tasks[task_id]['message'] = f'Error: {str(e)}'

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/check_ffmpeg')
def check_ffmpeg_status():
    """Check if FFmpeg is available"""
    return jsonify({'available': check_ffmpeg()})

@app.route('/upload', methods=['POST'])
def upload_file():
    """Handle video file upload"""
    if 'video' not in request.files:
        return jsonify({'error': 'No video file provided'}), 400
    
    file = request.files['video']
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400
    
    if file and file.filename:
        filename = secure_filename(str(file.filename))
        # Add timestamp to avoid conflicts
        timestamp = str(int(time.time()))
        filename = f"{timestamp}_{filename}"
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(file_path)
        
        return jsonify({
            'success': True,
            'file_id': filename,
            'message': 'File uploaded successfully'
        })

@app.route('/process_cut', methods=['POST'])
def process_cut():
    """Process video cutting request"""
    data = request.get_json()
    
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    file_id = data.get('file_id')
    start_time_str = data.get('start_time')
    end_time_str = data.get('end_time')
    output_name = data.get('output_name', 'cut_video')
    
    if not all([file_id, start_time_str, end_time_str]):
        return jsonify({'error': 'Missing required parameters'}), 400
    
    input_path = os.path.join(app.config['UPLOAD_FOLDER'], file_id)
    if not os.path.exists(input_path):
        return jsonify({'error': 'Input file not found'}), 404
    
    try:
        start_time = parse_time_to_seconds(start_time_str)
        end_time = parse_time_to_seconds(end_time_str)
        
        if start_time >= end_time:
            return jsonify({'error': 'Start time must be before end time'}), 400
        
        # Generate unique task ID
        task_id = str(uuid.uuid4())
        
        # Determine output file path
        _, ext = os.path.splitext(input_path)
        output_filename = f"{output_name}{ext}"
        output_path = os.path.join(app.config['OUTPUT_FOLDER'], output_filename)
        
        # Initialize task
        processing_tasks[task_id] = {
            'status': 'queued',
            'message': 'Task queued',
            'output_file': None
        }
        
        # Start processing in background thread
        thread = threading.Thread(
            target=cut_video,
            args=(input_path, output_path, start_time, end_time, task_id)
        )
        thread.start()
        
        return jsonify({
            'success': True,
            'task_id': task_id,
            'message': 'Processing started'
        })
        
    except Exception as e:
        return jsonify({'error': f'Error processing request: {str(e)}'}), 500

@app.route('/task_status/<task_id>')
def get_task_status(task_id):
    """Get processing task status"""
    if task_id not in processing_tasks:
        return jsonify({'error': 'Task not found'}), 404
    
    task = processing_tasks[task_id]
    response = {
        'status': task['status'],
        'message': task['message']
    }
    
    if task['status'] == 'completed' and task['output_file']:
        response['download_url'] = f'/download/{os.path.basename(task["output_file"])}'
    
    return jsonify(response)

@app.route('/download/<filename>')
def download_file(filename):
    """Download processed video file"""
    file_path = os.path.join(app.config['OUTPUT_FOLDER'], filename)
    if not os.path.exists(file_path):
        abort(404)
    
    return send_file(file_path, as_attachment=True)

if __name__ == '__main__':
    if not check_ffmpeg():
        print("WARNING: FFmpeg not found. Video processing will not work.")
        print("Please install FFmpeg to use this application.")
    
    app.run(host='0.0.0.0', port=5000, debug=True)
