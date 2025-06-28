

import tkinter as tk
from tkinter import filedialog, messagebox, scrolledtext, simpledialog
import speech_recognition as sr
import subprocess
import re
import threading
import os
from tkVideoPlayer import TkinterVideo

class VoiceVideoEditor(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Voice Controlled Video Cutter")
        self.geometry("800x700")

        self.input_file_path = ""
        self.last_cut_times = None

        # --- UI Elements ---
        # Top Frame for File Selection
        self.top_frame = tk.Frame(self)
        self.top_frame.pack(pady=10, padx=10, fill="x")
        self.select_button = tk.Button(self.top_frame, text="Select Video File", command=self.select_file)
        self.select_button.pack(side="left")
        self.file_label = tk.Label(self.top_frame, text="No file selected", wraplength=650)
        self.file_label.pack(side="left", padx=10)

        # Video Player
        self.videoplayer = TkinterVideo(master=self, scaled=True)
        self.videoplayer.pack(expand=True, fill="both", padx=10)

        # Command Instructions
        self.command_label = tk.Label(self, text="Available Voice Commands:", font=("Helvetica", 12, "bold"))
        self.command_label.pack(pady=(10, 0))
        self.command_text = scrolledtext.ScrolledText(self, height=6, wrap=tk.WORD, state="disabled", bg=self.cget('bg'), relief="flat")
        self.command_text.pack(pady=5, padx=10, fill="x")
        self.command_text.configure(state="normal")
        self.command_text.insert(tk.END, '1. Cut Video: "Cut from [X] seconds to [Y] seconds"\n')
        self.command_text.insert(tk.END, '   (e.g., "Cut from 1 minute to 2 minutes 30 seconds")\n')
        self.command_text.insert(tk.END, '2. Save Last Cut: "Save with name [your_filename]"\n')
        self.command_text.insert(tk.END, '3. Exit: "exit"')
        self.command_text.configure(state="disabled")

        # Action Button & Status
        self.action_frame = tk.Frame(self)
        self.action_frame.pack(pady=10, padx=10, fill="x")
        self.listen_button = tk.Button(self.action_frame, text="Click to Give Voice Command", command=self.start_listening_thread, font=("Helvetica", 12, "bold"), bg="lightblue")
        self.listen_button.pack(side="left", fill="x", expand=True)
        self.status_label = tk.Label(self, text="Status: Waiting for video file...", font=("Helvetica", 10), wraplength=780)
        self.status_label.pack(pady=5, padx=10)

    def select_file(self):
        self.input_file_path = filedialog.askopenfilename(title="Select a Video File", filetypes=(("MP4 files", "*.mp4"), ("All files", "*.* sviluppo")))
        if self.input_file_path:
            self.file_label.config(text=os.path.basename(self.input_file_path))
            self.status_label.config(text="Status: Video loaded. Ready for voice command.")
            self.videoplayer.load(self.input_file_path)
            self.videoplayer.play()
        else:
            self.file_label.config(text="No file selected")
            self.status_label.config(text="Status: Waiting for video file...")

    def start_listening_thread(self):
        if not self.input_file_path:
            messagebox.showerror("Error", "Please select a video file first.")
            return
        self.listen_button.config(state="disabled", text="Listening...")
        self.status_label.config(text="Status: Listening for a command...")
        threading.Thread(target=self.listen_for_command, daemon=True).start()

    def listen_for_command(self):
        r = sr.Recognizer()
        with sr.Microphone() as source:
            try:
                audio = r.listen(source, timeout=5, phrase_time_limit=10)
                command = r.recognize_google(audio).lower()
                self.status_label.config(text=f"You said: {command}")
                self.process_command(command)
            except sr.UnknownValueError: self.status_label.config(text="Status: Could not understand audio.")
            except sr.RequestError as e: self.status_label.config(text=f"Status: Speech recognition failed; {e}")
            except sr.WaitTimeoutError: self.status_label.config(text="Status: Listening timed out.")
            finally: self.listen_button.config(state="normal", text="Click to Give Voice Command")

    def process_command(self, command):
        if "cut from" in command and "to" in command:
            self.handle_cut_command(command)
        elif "save with name" in command:
            self.handle_save_command(command)
        elif "exit" in command:
            self.quit()

    def handle_cut_command(self, command):
        try:
            parts = command.split(" to ")
            start_str = parts[0].replace("cut from", "").strip()
            end_str = parts[1].strip()
            start_time = self.parse_time(start_str)
            end_time = self.parse_time(end_str)
            if start_time is None or end_time is None or start_time >= end_time:
                raise ValueError("Invalid time format or start time is after end time.")
            self.last_cut_times = (start_time, end_time)
            self.status_label.config(text=f"Previewing cut from {start_time}s to {end_time}s. Say 'Save with name [filename]' to save.")
            self.videoplayer.seek(int(start_time))
            self.videoplayer.play()
        except Exception as e:
            messagebox.showerror("Error", f"Error processing cut command: {e}")

    def handle_save_command(self, command):
        if not self.last_cut_times:
            messagebox.showerror("Error", "You must first specify a cut using the 'cut from...to...' command.")
            return
        try:
            output_filename = command.replace("save with name", "").strip()
            if not output_filename:
                raise ValueError("Filename cannot be empty.")
            output_dir = os.path.dirname(self.input_file_path)
            _, file_ext = os.path.splitext(self.input_file_path)
            output_file = os.path.join(output_dir, f"{output_filename}{file_ext}")
            self.cut_video(self.input_file_path, output_file, self.last_cut_times[0], self.last_cut_times[1])
        except Exception as e:
            messagebox.showerror("Error", f"Error processing save command: {e}")

    def parse_time(self, time_str):
        total_seconds = 0
        minutes = re.findall(r'(\d+)\s+minute', time_str)
        seconds = re.findall(r'(\d+)\s+second', time_str)
        if minutes: total_seconds += int(minutes[0]) * 60
        if seconds: total_seconds += int(seconds[0])
        if not minutes and not seconds and time_str.strip().isdigit():
            total_seconds += int(time_str.strip())
        return total_seconds

    def cut_video(self, input_f, output_f, start_t, end_t):
        command = ['ffmpeg', '-i', input_f, '-ss', str(start_t), '-to', str(end_t), '-c', 'copy', '-y', output_f]
        try:
            self.status_label.config(text=f"Status: Cutting video... please wait.")
            self.update()
            subprocess.run(command, check=True, creationflags=subprocess.CREATE_NO_WINDOW)
            messagebox.showinfo("Success", f"Successfully saved video to:\n{output_f}")
            self.status_label.config(text="Status: Ready for next command.")
            self.last_cut_times = None # Reset after saving
        except subprocess.CalledProcessError as e:
            messagebox.showerror("FFmpeg Error", f"Error during ffmpeg execution: {e}")
        except FileNotFoundError:
            messagebox.showerror("FFmpeg Error", "FFmpeg not found. Please ensure it's installed and in your system's PATH.")

if __name__ == "__main__":
    app = VoiceVideoEditor()
    app.mainloop()
