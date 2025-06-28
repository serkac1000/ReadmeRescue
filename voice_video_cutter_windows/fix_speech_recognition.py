#!/usr/bin/env python3
"""
Speech Recognition Fixer - GUI installer for PyAudio
This script provides a visual interface to fix speech recognition issues
"""

import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import subprocess
import sys
import threading
import os

class SpeechRecognitionFixer:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Speech Recognition Fixer")
        self.root.geometry("600x500")
        self.root.configure(bg='#f0f0f0')
        
        # Create UI
        self.create_ui()
        
        # Start checking status
        self.check_current_status()
    
    def create_ui(self):
        """Create the user interface"""
        # Title
        title_label = tk.Label(self.root, text="Voice Video Cutter - Speech Recognition Fix", 
                              font=("Arial", 16, "bold"), bg='#f0f0f0')
        title_label.pack(pady=10)
        
        # Status frame
        status_frame = tk.Frame(self.root, bg='#f0f0f0')
        status_frame.pack(fill='x', padx=20, pady=10)
        
        tk.Label(status_frame, text="Current Status:", font=("Arial", 12, "bold"), bg='#f0f0f0').pack(anchor='w')
        
        self.status_label = tk.Label(status_frame, text="Checking...", 
                                   font=("Arial", 10), bg='#f0f0f0', fg='orange')
        self.status_label.pack(anchor='w', pady=5)
        
        # Progress bar
        self.progress = ttk.Progressbar(self.root, length=400, mode='indeterminate')
        self.progress.pack(pady=10)
        
        # Buttons frame
        buttons_frame = tk.Frame(self.root, bg='#f0f0f0')
        buttons_frame.pack(pady=10)
        
        self.fix_button = tk.Button(buttons_frame, text="Fix Speech Recognition", 
                                   command=self.start_fix, bg='#4CAF50', fg='white',
                                   font=("Arial", 12), padx=20, pady=5)
        self.fix_button.pack(side='left', padx=5)
        
        self.test_button = tk.Button(buttons_frame, text="Test Speech Recognition", 
                                    command=self.test_speech, bg='#2196F3', fg='white',
                                    font=("Arial", 12), padx=20, pady=5)
        self.test_button.pack(side='left', padx=5)
        
        # Log area
        log_frame = tk.Frame(self.root, bg='#f0f0f0')
        log_frame.pack(fill='both', expand=True, padx=20, pady=10)
        
        tk.Label(log_frame, text="Installation Log:", font=("Arial", 12, "bold"), bg='#f0f0f0').pack(anchor='w')
        
        self.log_text = scrolledtext.ScrolledText(log_frame, height=15, width=70,
                                                 font=("Consolas", 9))
        self.log_text.pack(fill='both', expand=True, pady=5)
        
        # Instructions
        instructions = """
INSTRUCTIONS:
1. Click "Fix Speech Recognition" to automatically install PyAudio
2. Wait for the installation to complete
3. Click "Test Speech Recognition" to verify it works
4. If it still fails, the log will show manual installation steps

This tool will try multiple installation methods:
• Standard pip installation
• Windows binary packages (pipwin)
• Unofficial PyAudio binaries
• Manual wheel installation guide
        """
        
        self.log_text.insert('1.0', instructions.strip())
    
    def log(self, message):
        """Add message to log"""
        self.log_text.insert(tk.END, f"\n{message}")
        self.log_text.see(tk.END)
        self.root.update()
    
    def check_current_status(self):
        """Check if speech recognition is currently working"""
        def check():
            try:
                import speech_recognition as sr
                recognizer = sr.Recognizer()
                mic = sr.Microphone()
                with mic as source:
                    recognizer.adjust_for_ambient_noise(source, duration=0.5)
                
                self.status_label.config(text="✓ Speech recognition is working!", fg='green')
                self.fix_button.config(state='disabled', text="Already Working")
                self.log("\n✓ Speech recognition is already working correctly!")
                
            except ImportError as e:
                if "PyAudio" in str(e):
                    self.status_label.config(text="✗ PyAudio not installed", fg='red')
                    self.log(f"\n✗ PyAudio missing: {e}")
                else:
                    self.status_label.config(text="✗ SpeechRecognition not installed", fg='red')
                    self.log(f"\n✗ SpeechRecognition missing: {e}")
            except Exception as e:
                self.status_label.config(text="✗ Speech recognition not working", fg='red')
                self.log(f"\n✗ Error: {e}")
        
        threading.Thread(target=check, daemon=True).start()
    
    def start_fix(self):
        """Start the fix process"""
        self.fix_button.config(state='disabled')
        self.progress.start()
        self.log("\n" + "="*50)
        self.log("Starting PyAudio installation process...")
        
        threading.Thread(target=self.fix_pyaudio, daemon=True).start()
    
    def fix_pyaudio(self):
        """Fix PyAudio installation with multiple methods"""
        python_cmd = sys.executable
        
        # Method 1: Standard pip
        self.log("\n[Method 1] Trying standard pip installation...")
        result = self.run_command([python_cmd, "-m", "pip", "install", "PyAudio"])
        
        if result == 0:
            self.log("✓ PyAudio installed successfully via pip!")
            self.installation_complete()
            return
        
        # Method 2: Upgrade pip and try again
        self.log("\n[Method 2] Upgrading pip and trying again...")
        self.run_command([python_cmd, "-m", "pip", "install", "--upgrade", "pip"])
        result = self.run_command([python_cmd, "-m", "pip", "install", "PyAudio"])
        
        if result == 0:
            self.log("✓ PyAudio installed successfully after pip upgrade!")
            self.installation_complete()
            return
        
        # Method 3: pipwin
        self.log("\n[Method 3] Trying pipwin (Windows binaries)...")
        self.run_command([python_cmd, "-m", "pip", "install", "pipwin"])
        result = self.run_command([python_cmd, "-m", "pipwin", "install", "pyaudio"])
        
        if result == 0:
            self.log("✓ PyAudio installed successfully via pipwin!")
            self.installation_complete()
            return
        
        # Method 4: Unofficial binaries
        self.log("\n[Method 4] Trying unofficial PyAudio binaries...")
        result = self.run_command([
            python_cmd, "-m", "pip", "install", 
            "--find-links", "https://github.com/intxcc/pyaudio_portaudio/releases",
            "PyAudio"
        ])
        
        if result == 0:
            self.log("✓ PyAudio installed successfully via unofficial binaries!")
            self.installation_complete()
            return
        
        # All methods failed
        self.log("\n" + "="*50)
        self.log("❌ All automatic installation methods failed.")
        self.log("\nMANUAL INSTALLATION REQUIRED:")
        self.log("1. Go to: https://www.lfd.uci.edu/~gohlke/pythonlibs/#pyaudio")
        self.log("2. Download PyAudio wheel for your Python version")
        
        # Detect Python version
        import platform
        py_version = f"{sys.version_info.major}.{sys.version_info.minor}"
        arch = "win_amd64" if platform.machine().endswith('64') else "win32"
        
        self.log(f"3. For Python {py_version} ({arch}): Look for PyAudio-*-cp{py_version.replace('.', '')}-*-{arch}.whl")
        self.log("4. Download the wheel file")
        self.log(f"5. Run: {python_cmd} -m pip install [downloaded_wheel_file.whl]")
        self.log("\nAlternatively, install Microsoft Visual C++ Build Tools and try again.")
        
        self.progress.stop()
        self.fix_button.config(state='normal', text="Try Again")
    
    def run_command(self, cmd):
        """Run a command and log output"""
        try:
            self.log(f"Running: {' '.join(cmd)}")
            
            process = subprocess.Popen(
                cmd, 
                stdout=subprocess.PIPE, 
                stderr=subprocess.STDOUT,
                text=True,
                creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0
            )
            
            for line in process.stdout:
                self.log(line.strip())
            
            process.wait()
            return process.returncode
            
        except Exception as e:
            self.log(f"Error running command: {e}")
            return 1
    
    def installation_complete(self):
        """Handle successful installation"""
        self.progress.stop()
        self.log("\n" + "="*50)
        self.log("✓ Installation completed! Testing speech recognition...")
        
        # Test the installation
        threading.Thread(target=self.test_after_install, daemon=True).start()
    
    def test_after_install(self):
        """Test speech recognition after installation"""
        try:
            import importlib
            # Reload speech_recognition to pick up new PyAudio
            if 'speech_recognition' in sys.modules:
                importlib.reload(sys.modules['speech_recognition'])
            
            import speech_recognition as sr
            recognizer = sr.Recognizer()
            mic = sr.Microphone()
            
            with mic as source:
                recognizer.adjust_for_ambient_noise(source, duration=1)
            
            self.log("✓ Speech recognition test successful!")
            self.log("✓ Voice commands should now work in the main application!")
            self.status_label.config(text="✓ Speech recognition is working!", fg='green')
            self.fix_button.config(state='disabled', text="Fixed Successfully")
            
            messagebox.showinfo("Success", "Speech recognition is now working!\n\nYou can close this window and restart the main application.")
            
        except Exception as e:
            self.log(f"✗ Test failed: {e}")
            self.log("Please try the manual installation steps above.")
            self.fix_button.config(state='normal', text="Try Again")
    
    def test_speech(self):
        """Test current speech recognition status"""
        self.log("\n" + "="*30)
        self.log("Testing speech recognition...")
        
        def test():
            try:
                import speech_recognition as sr
                recognizer = sr.Recognizer()
                mic = sr.Microphone()
                
                self.log("Adjusting for ambient noise...")
                with mic as source:
                    recognizer.adjust_for_ambient_noise(source, duration=1)
                
                self.log("✓ Microphone test successful!")
                self.log(f"Available microphones: {sr.Microphone.list_microphone_names()[:3]}")
                self.log("✓ Speech recognition is working correctly!")
                
                messagebox.showinfo("Test Result", "Speech recognition is working!\n\nVoice commands should work in the main application.")
                
            except Exception as e:
                self.log(f"✗ Test failed: {e}")
                messagebox.showerror("Test Failed", f"Speech recognition is not working:\n\n{e}\n\nClick 'Fix Speech Recognition' to resolve this.")
        
        threading.Thread(target=test, daemon=True).start()
    
    def run(self):
        """Start the application"""
        self.root.mainloop()

if __name__ == "__main__":
    app = SpeechRecognitionFixer()
    app.run()