#!/usr/bin/env python3
"""
Voice-Controlled Video Cutter - Desktop GUI Application
Windows-optimized version with improved error handling and cross-platform compatibility
"""

import tkinter as tk
from tkinter import filedialog, messagebox, scrolledtext, ttk
import os
import sys
import subprocess
import re
import threading
import time
import platform
from pathlib import Path

# Initialize dependency flags
SPEECH_AVAILABLE = False
VIDEO_PLAYER_AVAILABLE = False
sr = None
TkinterVideo = None

def check_speech_recognition():
    """Check if speech recognition is fully functional"""
    global SPEECH_AVAILABLE, sr
    try:
        import speech_recognition as sr
        # Test PyAudio availability
        recognizer = sr.Recognizer()
        mic = sr.Microphone()
        # Quick test to see if microphone works
        with mic as source:
            recognizer.adjust_for_ambient_noise(source, duration=1)
        SPEECH_AVAILABLE = True
        print("✓ Speech recognition working")
        return True
    except ImportError as e:
        if "PyAudio" in str(e):
            print("✗ PyAudio not installed - run install_pyaudio.bat")
        else:
            print(f"✗ SpeechRecognition package not installed: {e}")
        return False
    except OSError as e:
        if "No Default Input Device Available" in str(e):
            print("✗ No microphone detected")
        elif "PortAudio" in str(e):
            print("✗ PortAudio error - run install_pyaudio.bat")
        else:
            print(f"✗ Audio system error: {e}")
        return False
    except Exception as e:
        if "PyAudio" in str(e) or "Could not find PyAudio" in str(e):
            print("✗ PyAudio missing - run install_pyaudio.bat")
        else:
            print(f"✗ Speech recognition error: {e}")
        return False

def check_video_player():
    """Check if video player is available"""
    global VIDEO_PLAYER_AVAILABLE, TkinterVideo
    try:
        from tkVideoPlayer import TkinterVideo
        VIDEO_PLAYER_AVAILABLE = True
        print("✓ Video preview available")
        return True
    except ImportError:
        print("✗ tkvideoplayer not installed")
        print("  Run: pip install tkvideoplayer")
        return False
    except Exception as e:
        print(f"✗ Video player error: {e}")
        return False

# Check dependencies at startup
print("Checking dependencies...")
check_speech_recognition()
check_video_player()

class VoiceVideoEditor(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Voice Controlled Video Cutter")
        self.geometry("900x800")
        self.minsize(800, 600)
        
        # Configure style
        self.configure(bg='#f0f0f0')
        
        # Application state
        self.input_file_path = ""
        self.last_cut_times = None
        self.is_listening = False
        
        # Check system requirements
        self.check_system_requirements()
        
        # Create UI
        self.create_ui()
        
        # Initialize speech recognition if available
        if SPEECH_AVAILABLE:
            self.init_speech_recognition()
        
    def check_system_requirements(self):
        """Check if all required system components are available"""
        self.ffmpeg_available = self.check_ffmpeg()
        
    def check_ffmpeg(self):
        """Check if FFmpeg is available"""
        try:
            # Try different common FFmpeg locations
            ffmpeg_paths = [
                'ffmpeg',  # System PATH
                'C:\\ffmpeg\\bin\\ffmpeg.exe',  # Windows common location
                '/usr/bin/ffmpeg',  # Linux common location
                '/usr/local/bin/ffmpeg',  # macOS common location
            ]
            
            for ffmpeg_path in ffmpeg_paths:
                try:
                    result = subprocess.run([ffmpeg_path, '-version'], 
                                          capture_output=True, 
                                          text=True, 
                                          timeout=5)
                    if result.returncode == 0:
                        self.ffmpeg_path = ffmpeg_path
                        return True
                except (FileNotFoundError, subprocess.TimeoutExpired):
                    continue
            
            return False
        except Exception:
            return False
    
    def create_ui(self):
        """Create the user interface"""
        # Create main frame with scrollbar
        main_frame = tk.Frame(self, bg='#f0f0f0')
        main_frame.pack(fill="both", expand=True, padx=10, pady=10)
        
        # System Status Section
        self.create_system_status_section(main_frame)
        
        # File Selection Section
        self.create_file_selection_section(main_frame)
        
        # Video Preview Section (if available)
        if VIDEO_PLAYER_AVAILABLE:
            self.create_video_preview_section(main_frame)
        
        # Voice Commands Section
        self.create_voice_commands_section(main_frame)
        
        # Manual Input Section
        self.create_manual_input_section(main_frame)
        
        # Progress Section
        self.create_progress_section(main_frame)
        
        # Status Section
        self.create_status_section(main_frame)
    
    def create_system_status_section(self, parent):
        """Create system status display"""
        status_frame = tk.LabelFrame(parent, text="System Status", 
                                   font=("Helvetica", 12, "bold"),
                                   bg='#f0f0f0', fg='#333333')
        status_frame.pack(fill="x", pady=(0, 10))
        
        # FFmpeg status
        ffmpeg_status = "✓ Available" if self.ffmpeg_available else "✗ Not Found"
        ffmpeg_color = "green" if self.ffmpeg_available else "red"
        tk.Label(status_frame, text=f"FFmpeg: {ffmpeg_status}", 
                fg=ffmpeg_color, bg='#f0f0f0', font=("Helvetica", 10)).pack(anchor="w", padx=10, pady=2)
        
        # Speech Recognition status
        speech_status = "✓ Available" if SPEECH_AVAILABLE else "✗ Not Available"
        speech_color = "green" if SPEECH_AVAILABLE else "orange"
        tk.Label(status_frame, text=f"Speech Recognition: {speech_status}", 
                fg=speech_color, bg='#f0f0f0', font=("Helvetica", 10)).pack(anchor="w", padx=10, pady=2)
        
        # Video Player status
        player_status = "✓ Available" if VIDEO_PLAYER_AVAILABLE else "✗ Not Available"
        player_color = "green" if VIDEO_PLAYER_AVAILABLE else "orange"
        tk.Label(status_frame, text=f"Video Preview: {player_status}", 
                fg=player_color, bg='#f0f0f0', font=("Helvetica", 10)).pack(anchor="w", padx=10, pady=(2, 10))
        
        if not self.ffmpeg_available:
            warning_label = tk.Label(status_frame, 
                                   text="⚠ Warning: FFmpeg is required for video processing. Please install FFmpeg.",
                                   fg="red", bg='#f0f0f0', font=("Helvetica", 9), wraplength=800)
            warning_label.pack(anchor="w", padx=10, pady=(0, 10))
    
    def create_file_selection_section(self, parent):
        """Create file selection interface"""
        file_frame = tk.LabelFrame(parent, text="Step 1: Select Video File", 
                                 font=("Helvetica", 12, "bold"),
                                 bg='#f0f0f0', fg='#333333')
        file_frame.pack(fill="x", pady=(0, 10))
        
        button_frame = tk.Frame(file_frame, bg='#f0f0f0')
        button_frame.pack(fill="x", padx=10, pady=10)
        
        self.select_button = tk.Button(button_frame, text="Select Video File", 
                                     command=self.select_file,
                                     bg='#4CAF50', fg='white', font=("Helvetica", 11, "bold"),
                                     padx=20, pady=5)
        self.select_button.pack(side="left")
        
        self.file_label = tk.Label(button_frame, text="No file selected", 
                                 wraplength=650, bg='#f0f0f0', fg='#666666')
        self.file_label.pack(side="left", padx=(15, 0))
    
    def create_video_preview_section(self, parent):
        """Create video preview section"""
        preview_frame = tk.LabelFrame(parent, text="Video Preview", 
                                    font=("Helvetica", 12, "bold"),
                                    bg='#f0f0f0', fg='#333333')
        preview_frame.pack(fill="both", expand=True, pady=(0, 10))
        
        try:
            self.videoplayer = TkinterVideo(master=preview_frame, scaled=True)
            self.videoplayer.pack(expand=True, fill="both", padx=10, pady=10)
        except Exception as e:
            error_label = tk.Label(preview_frame, 
                                 text=f"Video preview not available: {str(e)}", 
                                 bg='#f0f0f0', fg='red')
            error_label.pack(pady=20)
    
    def create_voice_commands_section(self, parent):
        """Create voice commands interface"""
        voice_frame = tk.LabelFrame(parent, text="Step 2: Voice Commands", 
                                  font=("Helvetica", 12, "bold"),
                                  bg='#f0f0f0', fg='#333333')
        voice_frame.pack(fill="x", pady=(0, 10))
        
        # Command instructions
        cmd_text = scrolledtext.ScrolledText(voice_frame, height=5, wrap=tk.WORD, 
                                           bg='#ffffff', fg='#333333', font=("Helvetica", 10))
        cmd_text.pack(fill="x", padx=10, pady=(10, 5))
        
        instructions = """Available Voice Commands:
1. Cut Video: "Cut from [X] seconds to [Y] seconds"
   Examples: "Cut from 10 seconds to 30 seconds", "Cut from 1 minute to 2 minutes 15 seconds"
2. Save Cut: "Save with name [filename]"
   Example: "Save with name my_video_clip"
3. Exit: "exit" or "quit"

Note: Speak clearly and wait for the "Listening..." indicator."""
        
        cmd_text.insert(tk.END, instructions)
        cmd_text.configure(state="disabled")
        
        # Voice button
        button_frame = tk.Frame(voice_frame, bg='#f0f0f0')
        button_frame.pack(fill="x", padx=10, pady=(5, 10))
        
        self.listen_button = tk.Button(button_frame, 
                                     text="🎤 Click to Give Voice Command", 
                                     command=self.start_listening_thread,
                                     font=("Helvetica", 12, "bold"), 
                                     bg='#2196F3', fg='white',
                                     padx=20, pady=10)
        if SPEECH_AVAILABLE:
            self.listen_button.pack(side="left", fill="x", expand=True)
        else:
            self.listen_button.configure(state="disabled", text="🎤 Speech Recognition Not Available")
            self.listen_button.pack(side="left", fill="x", expand=True)
    
    def create_manual_input_section(self, parent):
        """Create manual input interface"""
        manual_frame = tk.LabelFrame(parent, text="Alternative: Manual Input", 
                                   font=("Helvetica", 12, "bold"),
                                   bg='#f0f0f0', fg='#333333')
        manual_frame.pack(fill="x", pady=(0, 10))
        
        input_frame = tk.Frame(manual_frame, bg='#f0f0f0')
        input_frame.pack(fill="x", padx=10, pady=10)
        
        # Start time
        tk.Label(input_frame, text="Start Time:", bg='#f0f0f0', font=("Helvetica", 10, "bold")).grid(row=0, column=0, sticky="w", padx=(0, 5))
        self.start_time_var = tk.StringVar()
        self.start_time_entry = tk.Entry(input_frame, textvariable=self.start_time_var, width=25, font=("Helvetica", 10))
        self.start_time_entry.grid(row=0, column=1, padx=(0, 10), pady=2)
        tk.Label(input_frame, text="(e.g., '10 seconds', '1 minute 30 seconds')", 
                bg='#f0f0f0', fg='#666666', font=("Helvetica", 9)).grid(row=1, column=1, sticky="w", pady=(0, 5))
        
        # End time
        tk.Label(input_frame, text="End Time:", bg='#f0f0f0', font=("Helvetica", 10, "bold")).grid(row=2, column=0, sticky="w", padx=(0, 5))
        self.end_time_var = tk.StringVar()
        self.end_time_entry = tk.Entry(input_frame, textvariable=self.end_time_var, width=25, font=("Helvetica", 10))
        self.end_time_entry.grid(row=2, column=1, padx=(0, 10), pady=2)
        tk.Label(input_frame, text="(e.g., '45 seconds', '2 minutes')", 
                bg='#f0f0f0', fg='#666666', font=("Helvetica", 9)).grid(row=3, column=1, sticky="w", pady=(0, 5))
        
        # Output name
        tk.Label(input_frame, text="Output Name:", bg='#f0f0f0', font=("Helvetica", 10, "bold")).grid(row=4, column=0, sticky="w", padx=(0, 5))
        self.output_name_var = tk.StringVar()
        self.output_name_entry = tk.Entry(input_frame, textvariable=self.output_name_var, width=25, font=("Helvetica", 10))
        self.output_name_entry.grid(row=4, column=1, padx=(0, 10), pady=2)
        tk.Label(input_frame, text="(filename without extension)", 
                bg='#f0f0f0', fg='#666666', font=("Helvetica", 9)).grid(row=5, column=1, sticky="w", pady=(0, 10))
        
        # Cut button
        self.manual_cut_button = tk.Button(input_frame, text="✂ Cut Video", 
                                         command=self.process_manual_cut,
                                         bg='#FF9800', fg='white', font=("Helvetica", 11, "bold"),
                                         padx=20, pady=5)
        self.manual_cut_button.grid(row=6, column=0, columnspan=2, pady=(5, 0))
    
    def create_progress_section(self, parent):
        """Create progress display"""
        progress_frame = tk.Frame(parent, bg='#f0f0f0')
        progress_frame.pack(fill="x", pady=(0, 10))
        
        self.progress_var = tk.DoubleVar()
        self.progress_bar = ttk.Progressbar(progress_frame, variable=self.progress_var, 
                                          mode='indeterminate', length=400)
        self.progress_bar.pack(pady=5)
        self.progress_bar.pack_forget()  # Hide initially
    
    def create_status_section(self, parent):
        """Create status display"""
        self.status_label = tk.Label(parent, text="Status: Ready - Select a video file to begin", 
                                   font=("Helvetica", 11), wraplength=850, 
                                   bg='#f0f0f0', fg='#333333', justify="left")
        self.status_label.pack(pady=(0, 10))
    
    def init_speech_recognition(self):
        """Initialize speech recognition"""
        if not SPEECH_AVAILABLE or sr is None:
            self.listen_button.configure(state="disabled", text="🎤 Speech Not Available")
            return
            
        try:
            self.recognizer = sr.Recognizer()
            self.microphone = sr.Microphone()
            
            # Adjust for ambient noise
            with self.microphone as source:
                self.recognizer.adjust_for_ambient_noise(source, duration=1)
            
            print("Speech recognition initialized successfully")
        except Exception as e:
            print(f"Error initializing speech recognition: {e}")
            self.listen_button.configure(state="disabled", text="🎤 Microphone Error")
    
    def select_file(self):
        """Handle file selection"""
        filetypes = (
            ("All Video Files", "*.mp4 *.avi *.mov *.mkv *.wmv *.flv *.webm"),
            ("MP4 files", "*.mp4"),
            ("AVI files", "*.avi"),
            ("All files", "*.*")
        )
        
        file_path = filedialog.askopenfilename(
            title="Select a Video File",
            filetypes=filetypes
        )
        
        if file_path:
            self.input_file_path = file_path
            filename = os.path.basename(file_path)
            self.file_label.config(text=f"Selected: {filename}", fg='#2196F3')
            self.status_label.config(text="Status: Video loaded. Ready for voice command or manual input.")
            
            # Load video preview if available
            if VIDEO_PLAYER_AVAILABLE and hasattr(self, 'videoplayer'):
                try:
                    self.videoplayer.load(file_path)
                    self.videoplayer.play()
                except Exception as e:
                    print(f"Error loading video preview: {e}")
        else:
            self.file_label.config(text="No file selected", fg='#666666')
            self.status_label.config(text="Status: Ready - Select a video file to begin")
    
    def start_listening_thread(self):
        """Start listening for voice commands in a separate thread"""
        if not self.input_file_path:
            messagebox.showerror("Error", "Please select a video file first.")
            return
        
        if not SPEECH_AVAILABLE:
            messagebox.showerror("Error", "Speech recognition is not available.")
            return
        
        if self.is_listening:
            return
        
        self.listen_button.config(state="disabled", text="🎤 Listening...", bg='#f44336')
        self.status_label.config(text="Status: Listening for voice command... Speak clearly!")
        
        thread = threading.Thread(target=self.listen_for_command, daemon=True)
        thread.start()
    
    def listen_for_command(self):
        """Listen for voice commands"""
        try:
            self.is_listening = True
            
            with self.microphone as source:
                # Listen for audio
                audio = self.recognizer.listen(source, timeout=10, phrase_time_limit=15)
            
            # Recognize speech
            command = self.recognizer.recognize_google(audio).lower()
            
            # Update UI in main thread
            self.after(0, lambda: self.status_label.config(text=f"You said: '{command}'"))
            self.after(0, lambda: self.process_command(command))
            
        except sr.UnknownValueError:
            self.after(0, lambda: self.status_label.config(text="Status: Could not understand audio. Please try again."))
        except sr.RequestError as e:
            self.after(0, lambda: self.status_label.config(text=f"Status: Speech recognition service error: {e}"))
        except sr.WaitTimeoutError:
            self.after(0, lambda: self.status_label.config(text="Status: Listening timed out. Click the button to try again."))
        except Exception as e:
            self.after(0, lambda: self.status_label.config(text=f"Status: Speech recognition error: {e}"))
        finally:
            self.is_listening = False
            self.after(0, lambda: self.listen_button.config(state="normal", text="🎤 Click to Give Voice Command", bg='#2196F3'))
    
    def process_command(self, command):
        """Process voice commands"""
        try:
            if "cut from" in command and "to" in command:
                self.handle_cut_command(command)
            elif "save with name" in command:
                self.handle_save_command(command)
            elif "exit" in command or "quit" in command:
                self.quit()
            else:
                self.status_label.config(text="Status: Command not recognized. Please try again with a valid command.")
        except Exception as e:
            self.status_label.config(text=f"Status: Error processing command: {e}")
    
    def handle_cut_command(self, command):
        """Handle cut command from voice input"""
        try:
            # Parse the command
            parts = command.split(" to ")
            if len(parts) != 2:
                raise ValueError("Invalid command format")
            
            start_str = parts[0].replace("cut from", "").strip()
            end_str = parts[1].strip()
            
            # Parse times
            start_time = self.parse_time(start_str)
            end_time = self.parse_time(end_str)
            
            if start_time is None or end_time is None:
                raise ValueError("Could not parse time values")
            
            if start_time >= end_time:
                raise ValueError("Start time must be before end time")
            
            # Store cut parameters
            self.last_cut_times = (start_time, end_time)
            
            # Update UI
            self.start_time_var.set(start_str)
            self.end_time_var.set(end_str)
            
            self.status_label.config(text=f"Status: Ready to cut from {start_time}s to {end_time}s. Say 'Save with name [filename]' or use manual input.")
            
            # Seek video player if available
            if VIDEO_PLAYER_AVAILABLE and hasattr(self, 'videoplayer'):
                try:
                    self.videoplayer.seek(int(start_time))
                    self.videoplayer.play()
                except Exception:
                    pass  # Ignore video player errors
                    
        except Exception as e:
            self.status_label.config(text=f"Status: Error processing cut command: {e}")
    
    def handle_save_command(self, command):
        """Handle save command from voice input"""
        if not self.last_cut_times:
            self.status_label.config(text="Status: Please specify a cut first using 'cut from ... to ...' command.")
            return
        
        try:
            # Extract filename
            output_name = command.replace("save with name", "").strip()
            if not output_name:
                raise ValueError("Output filename cannot be empty")
            
            # Update UI
            self.output_name_var.set(output_name)
            
            # Process the cut
            self.cut_video(self.input_file_path, output_name, self.last_cut_times[0], self.last_cut_times[1])
            
        except Exception as e:
            self.status_label.config(text=f"Status: Error processing save command: {e}")
    
    def process_manual_cut(self):
        """Process manual cut input"""
        if not self.input_file_path:
            messagebox.showerror("Error", "Please select a video file first.")
            return
        
        try:
            start_str = self.start_time_var.get().strip()
            end_str = self.end_time_var.get().strip()
            output_name = self.output_name_var.get().strip()
            
            if not start_str or not end_str:
                raise ValueError("Please specify both start and end times")
            
            if not output_name:
                output_name = "cut_video"
            
            # Parse times
            start_time = self.parse_time(start_str)
            end_time = self.parse_time(end_str)
            
            if start_time is None or end_time is None:
                raise ValueError("Could not parse time values. Use formats like '10 seconds' or '1 minute 30 seconds'")
            
            if start_time >= end_time:
                raise ValueError("Start time must be before end time")
            
            # Process the cut
            self.cut_video(self.input_file_path, output_name, start_time, end_time)
            
        except Exception as e:
            messagebox.showerror("Error", str(e))
    
    def parse_time(self, time_str):
        """Parse time string to seconds"""
        try:
            time_str = time_str.lower().strip()
            total_seconds = 0
            
            # Find minutes
            minute_match = re.search(r'(\d+)\s*minute', time_str)
            if minute_match:
                total_seconds += int(minute_match.group(1)) * 60
            
            # Find seconds
            second_match = re.search(r'(\d+)\s*second', time_str)
            if second_match:
                total_seconds += int(second_match.group(1))
            
            # If no units found, assume it's seconds
            if not minute_match and not second_match:
                # Try to parse as plain number
                clean_str = re.sub(r'[^\d.]', '', time_str)
                if clean_str:
                    total_seconds = float(clean_str)
            
            return total_seconds if total_seconds > 0 else None
            
        except Exception:
            return None
    
    def cut_video(self, input_file, output_name, start_time, end_time):
        """Cut video using FFmpeg"""
        if not self.ffmpeg_available:
            messagebox.showerror("Error", "FFmpeg is not available. Please install FFmpeg to use this feature.")
            return
        
        try:
            # Prepare output path
            input_dir = os.path.dirname(input_file)
            _, input_ext = os.path.splitext(input_file)
            output_file = os.path.join(input_dir, f"{output_name}{input_ext}")
            
            # Show progress
            self.progress_bar.pack(pady=5)
            self.progress_bar.start()
            self.status_label.config(text="Status: Cutting video... Please wait.")
            self.update()
            
            # Build FFmpeg command
            command = [
                self.ffmpeg_path,
                '-i', input_file,
                '-ss', str(start_time),
                '-to', str(end_time),
                '-c', 'copy',
                '-avoid_negative_ts', 'make_zero',
                '-y', output_file
            ]
            
            # Execute FFmpeg
            if platform.system() == "Windows":
                result = subprocess.run(command, check=True, 
                                      capture_output=True, text=True,
                                      creationflags=subprocess.CREATE_NO_WINDOW)
            else:
                result = subprocess.run(command, check=True, 
                                      capture_output=True, text=True)
            
            # Success
            self.progress_bar.stop()
            self.progress_bar.pack_forget()
            
            messagebox.showinfo("Success", f"Video successfully cut and saved to:\n{output_file}")
            self.status_label.config(text="Status: Video cut completed successfully. Ready for next operation.")
            
            # Reset state
            self.last_cut_times = None
            
        except subprocess.CalledProcessError as e:
            self.progress_bar.stop()
            self.progress_bar.pack_forget()
            error_msg = f"FFmpeg error: {e.stderr if e.stderr else 'Unknown error'}"
            messagebox.showerror("FFmpeg Error", error_msg)
            self.status_label.config(text="Status: Error during video processing.")
            
        except Exception as e:
            self.progress_bar.stop()
            self.progress_bar.pack_forget()
            messagebox.showerror("Error", f"Unexpected error: {str(e)}")
            self.status_label.config(text="Status: Error during video processing.")

def main():
    """Main application entry point"""
    try:
        app = VoiceVideoEditor()
        app.mainloop()
    except KeyboardInterrupt:
        print("\nApplication terminated by user.")
    except Exception as e:
        print(f"Application error: {e}")
        messagebox.showerror("Application Error", f"An unexpected error occurred: {e}")

if __name__ == "__main__":
    main()