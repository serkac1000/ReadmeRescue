class VoiceVideoEditor {
    constructor() {
        this.currentFileId = null;
        this.currentTaskId = null;
        this.recognition = null;
        this.isListening = false;
        this.lastCutParams = null;

        this.initializeElements();
        this.setupEventListeners();
        this.checkSystemStatus();
        this.initializeSpeechRecognition();
    }

    initializeElements() {
        this.elements = {
            systemStatus: document.getElementById('system-status'),
            videoFile: document.getElementById('video-file'),
            uploadBtn: document.getElementById('upload-btn'),
            uploadStatus: document.getElementById('upload-status'),
            videoPreview: document.getElementById('video-preview'),
            videoPreviewSection: document.getElementById('video-preview-section'),
            voiceCommandsSection: document.getElementById('voice-commands-section'),
            manualInputSection: document.getElementById('manual-input-section'),
            processingSection: document.getElementById('processing-section'),
            resultsSection: document.getElementById('results-section'),
            voiceBtn: document.getElementById('voice-btn'),
            voiceStatus: document.getElementById('voice-status'),
            startTime: document.getElementById('start-time'),
            endTime: document.getElementById('end-time'),
            outputName: document.getElementById('output-name'),
            manualCutBtn: document.getElementById('manual-cut-btn'),
            processingStatus: document.getElementById('processing-status'),
            resultsContent: document.getElementById('results-content')
        };
    }

    setupEventListeners() {
        this.elements.videoFile.addEventListener('change', () => {
            this.elements.uploadBtn.disabled = !this.elements.videoFile.files.length;
        });

        this.elements.uploadBtn.addEventListener('click', () => {
            this.uploadVideo();
        });

        this.elements.voiceBtn.addEventListener('click', () => {
            this.toggleVoiceRecognition();
        });

        this.elements.manualCutBtn.addEventListener('click', () => {
            this.processManualCut();
        });
    }

    async checkSystemStatus() {
        try {
            const response = await fetch('/check_ffmpeg');
            const data = await response.json();
            
            if (data.available) {
                this.elements.systemStatus.className = 'alert alert-success';
                this.elements.systemStatus.innerHTML = '<i class="fas fa-check-circle me-2"></i>System ready! FFmpeg is available.';
            } else {
                this.elements.systemStatus.className = 'alert alert-warning';
                this.elements.systemStatus.innerHTML = '<i class="fas fa-exclamation-triangle me-2"></i>Warning: FFmpeg not found. Video processing may not work properly.';
            }
        } catch (error) {
            this.elements.systemStatus.className = 'alert alert-danger';
            this.elements.systemStatus.innerHTML = '<i class="fas fa-times-circle me-2"></i>Error checking system status.';
        }
    }

    initializeSpeechRecognition() {
        if ('webkitSpeechRecognition' in window || 'SpeechRecognition' in window) {
            const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
            this.recognition = new SpeechRecognition();
            this.recognition.continuous = false;
            this.recognition.interimResults = false;
            this.recognition.lang = 'en-US';

            this.recognition.onstart = () => {
                this.isListening = true;
                this.elements.voiceBtn.textContent = 'Listening...';
                this.elements.voiceBtn.className = 'btn btn-danger btn-lg w-100 listening';
                this.elements.voiceStatus.innerHTML = '<i class="fas fa-microphone me-2"></i>Listening for command...';
            };

            this.recognition.onresult = (event) => {
                const command = event.results[0][0].transcript.toLowerCase();
                this.elements.voiceStatus.innerHTML = `<i class="fas fa-comment me-2"></i>You said: "${command}"`;
                this.processVoiceCommand(command);
            };

            this.recognition.onerror = (event) => {
                this.elements.voiceStatus.innerHTML = `<i class="fas fa-exclamation-triangle me-2"></i>Speech recognition error: ${event.error}`;
                this.resetVoiceButton();
            };

            this.recognition.onend = () => {
                this.resetVoiceButton();
            };
        } else {
            this.elements.voiceBtn.disabled = true;
            this.elements.voiceBtn.innerHTML = '<i class="fas fa-microphone-slash me-2"></i>Speech Recognition Not Supported';
            this.elements.voiceStatus.innerHTML = '<i class="fas fa-info-circle me-2"></i>Your browser does not support speech recognition. Please use manual input.';
        }
    }

    resetVoiceButton() {
        this.isListening = false;
        this.elements.voiceBtn.innerHTML = '<i class="fas fa-microphone me-2"></i>Click to Give Voice Command';
        this.elements.voiceBtn.className = 'btn btn-success btn-lg w-100';
    }

    toggleVoiceRecognition() {
        if (!this.recognition) return;

        if (this.isListening) {
            this.recognition.stop();
        } else {
            this.recognition.start();
        }
    }

    async uploadVideo() {
        const file = this.elements.videoFile.files[0];
        if (!file) return;

        const formData = new FormData();
        formData.append('video', file);

        this.elements.uploadBtn.disabled = true;
        this.elements.uploadStatus.innerHTML = '<i class="loading me-2"></i>Uploading...';

        try {
            const response = await fetch('/upload', {
                method: 'POST',
                body: formData
            });

            const data = await response.json();

            if (data.success) {
                this.currentFileId = data.file_id;
                this.elements.uploadStatus.innerHTML = '<i class="fas fa-check-circle me-2"></i>File uploaded successfully!';
                this.elements.uploadStatus.className = 'mt-2 text-success';
                
                // Show video preview
                const url = URL.createObjectURL(file);
                this.elements.videoPreview.src = url;
                this.elements.videoPreviewSection.style.display = 'block';
                this.elements.voiceCommandsSection.style.display = 'block';
                this.elements.manualInputSection.style.display = 'block';
                
            } else {
                throw new Error(data.error || 'Upload failed');
            }
        } catch (error) {
            this.elements.uploadStatus.innerHTML = `<i class="fas fa-times-circle me-2"></i>Error: ${error.message}`;
            this.elements.uploadStatus.className = 'mt-2 text-danger';
        } finally {
            this.elements.uploadBtn.disabled = false;
        }
    }

    processVoiceCommand(command) {
        if (command.includes('cut from') && command.includes('to')) {
            this.handleCutCommand(command);
        } else if (command.includes('save with name')) {
            this.handleSaveCommand(command);
        } else if (command.includes('cancel') || command.includes('stop')) {
            this.elements.voiceStatus.innerHTML = '<i class="fas fa-times me-2"></i>Command cancelled.';
        } else {
            this.elements.voiceStatus.innerHTML = '<i class="fas fa-question-circle me-2"></i>Command not recognized. Please try again.';
        }
    }

    handleCutCommand(command) {
        try {
            const parts = command.split(' to ');
            const startStr = parts[0].replace('cut from', '').trim();
            const endStr = parts[1].trim();

            this.lastCutParams = {
                start_time: startStr,
                end_time: endStr
            };

            this.elements.voiceStatus.innerHTML = `<i class="fas fa-scissors me-2"></i>Ready to cut from "${startStr}" to "${endStr}". Say "Save with name [filename]" to process.`;
            
            // Auto-fill manual inputs
            this.elements.startTime.value = startStr;
            this.elements.endTime.value = endStr;
            
        } catch (error) {
            this.elements.voiceStatus.innerHTML = `<i class="fas fa-exclamation-triangle me-2"></i>Error parsing cut command: ${error.message}`;
        }
    }

    handleSaveCommand(command) {
        if (!this.lastCutParams) {
            this.elements.voiceStatus.innerHTML = '<i class="fas fa-exclamation-triangle me-2"></i>Please specify a cut first using "Cut from ... to ..." command.';
            return;
        }

        try {
            const outputName = command.replace('save with name', '').trim();
            if (!outputName) {
                throw new Error('Output name cannot be empty');
            }

            this.elements.outputName.value = outputName;
            this.processCut(this.lastCutParams.start_time, this.lastCutParams.end_time, outputName);
            
        } catch (error) {
            this.elements.voiceStatus.innerHTML = `<i class="fas fa-exclamation-triangle me-2"></i>Error processing save command: ${error.message}`;
        }
    }

    processManualCut() {
        const startTime = this.elements.startTime.value.trim();
        const endTime = this.elements.endTime.value.trim();
        const outputName = this.elements.outputName.value.trim() || 'cut_video';

        if (!startTime || !endTime) {
            alert('Please specify both start and end times.');
            return;
        }

        this.processCut(startTime, endTime, outputName);
    }

    async processCut(startTime, endTime, outputName) {
        if (!this.currentFileId) {
            alert('Please upload a video file first.');
            return;
        }

        const requestData = {
            file_id: this.currentFileId,
            start_time: startTime,
            end_time: endTime,
            output_name: outputName
        };

        try {
            this.elements.processingSection.style.display = 'block';
            this.elements.resultsSection.style.display = 'none';

            const response = await fetch('/process_cut', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(requestData)
            });

            const data = await response.json();

            if (data.success) {
                this.currentTaskId = data.task_id;
                this.pollTaskStatus();
            } else {
                throw new Error(data.error || 'Processing failed');
            }
        } catch (error) {
            this.elements.processingSection.style.display = 'none';
            this.showError(`Error starting processing: ${error.message}`);
        }
    }

    async pollTaskStatus() {
        if (!this.currentTaskId) return;

        try {
            const response = await fetch(`/task_status/${this.currentTaskId}`);
            const data = await response.json();

            this.elements.processingStatus.innerHTML = `<i class="fas fa-cog fa-spin me-2"></i>${data.message}`;

            if (data.status === 'completed') {
                this.elements.processingSection.style.display = 'none';
                this.showSuccess('Video processed successfully!', data.download_url);
                this.currentTaskId = null;
                this.lastCutParams = null;
            } else if (data.status === 'error') {
                this.elements.processingSection.style.display = 'none';
                this.showError(`Processing failed: ${data.message}`);
                this.currentTaskId = null;
            } else {
                // Continue polling
                setTimeout(() => this.pollTaskStatus(), 2000);
            }
        } catch (error) {
            this.elements.processingSection.style.display = 'none';
            this.showError(`Error checking status: ${error.message}`);
            this.currentTaskId = null;
        }
    }

    showSuccess(message, downloadUrl) {
        this.elements.resultsContent.innerHTML = `
            <div class="alert alert-success">
                <i class="fas fa-check-circle me-2"></i>${message}
            </div>
            ${downloadUrl ? `
                <div class="text-center">
                    <a href="${downloadUrl}" class="btn btn-primary btn-lg" download>
                        <i class="fas fa-download me-2"></i>Download Processed Video
                    </a>
                </div>
            ` : ''}
        `;
        this.elements.resultsSection.style.display = 'block';
    }

    showError(message) {
        this.elements.resultsContent.innerHTML = `
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-triangle me-2"></i>${message}
            </div>
        `;
        this.elements.resultsSection.style.display = 'block';
    }
}

// Initialize the application when the page loads
document.addEventListener('DOMContentLoaded', () => {
    new VoiceVideoEditor();
});
