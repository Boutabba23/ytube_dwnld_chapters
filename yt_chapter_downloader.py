
import tkinter as tk
from tkinter import filedialog, messagebox, ttk
import subprocess
import os
import threading
import json

def browse_folder():
    folder_selected.set(filedialog.askdirectory())

def download_video():
    url = url_entry.get()
    folder = folder_selected.get()
    format_choice = format_var.get()

    if not url or not folder:
        messagebox.showwarning("Missing Info", "Please enter URL and select folder.")
        return

    progress["value"] = 0
    root.update_idletasks()

    threading.Thread(target=download_thread, args=(url, folder, format_choice)).start()

def download_thread(url, folder, format_choice):
    try:
        cmd = [
            "yt-dlp",
            "-f", "bestvideo+bestaudio/best",
            "--merge-output-format", format_choice,
            "--write-info-json",
            "--write-description",
            "-o", os.path.join(folder, "%(title)s.%(ext)s"),
            url
        ]
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            raise Exception(result.stderr)

        progress["value"] = 50
        root.update_idletasks()
        process_latest_file(folder, format_choice)

        progress["value"] = 100
        messagebox.showinfo("Success", "Download and chapter embedding complete.")
    except Exception as e:
        messagebox.showerror("Download Error", str(e))

def process_latest_file(folder, format_choice):
    files = sorted(Path(folder).glob(f"*.{format_choice}"), key=os.path.getmtime, reverse=True)
    if not files:
        return
    video_path = files[0]
    json_path = video_path.with_suffix(".info.json")

    if not json_path.exists():
        return

    with open(json_path, "r", encoding="utf-8") as f:
        info = json.load(f)

    chapters = info.get("chapters")
    if not chapters:
        return

    metadata = []
    for chapter in chapters:
        start = chapter["start_time"]
        title = chapter["title"].replace('"', '\"')
        metadata.extend(["-metadata", f"chapter={title}"])

    temp_file = str(video_path) + ".temp." + format_choice

    cmd = [
        "ffmpeg", "-i", str(video_path), "-map", "0", "-c", "copy",
        "-f", format_choice, "-y", temp_file
    ]
    subprocess.run(cmd, check=True)
    os.replace(temp_file, video_path)

root = tk.Tk()
root.title("YouTube Chapter Downloader")
root.geometry("500x300")

tk.Label(root, text="YouTube URL:").pack()
url_entry = tk.Entry(root, width=60)
url_entry.pack(pady=5)

tk.Label(root, text="Save Folder:").pack()
folder_selected = tk.StringVar()
folder_frame = tk.Frame(root)
folder_frame.pack(pady=5)
folder_entry = tk.Entry(folder_frame, textvariable=folder_selected, width=40)
folder_entry.pack(side="left")
tk.Button(folder_frame, text="Browse", command=browse_folder).pack(side="left", padx=5)

tk.Label(root, text="Format:").pack(pady=5)
format_var = tk.StringVar(value="mp4")
format_menu = ttk.Combobox(root, textvariable=format_var, values=["mp4", "mkv"])
format_menu.pack()

tk.Button(root, text="Download", command=download_video).pack(pady=10)
progress = ttk.Progressbar(root, orient="horizontal", length=400, mode="determinate")
progress.pack(pady=10)

root.mainloop()
