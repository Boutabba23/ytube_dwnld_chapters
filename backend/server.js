const express = require("express");
const cors = require("cors");
const { spawn } = require("child_process");
const fs = require("fs-extra");
const path = require("path");
const { v4: uuidv4 } = require("uuid");
const http = require("http");
const socketIo = require("socket.io");

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
  },
});

const PORT = process.env.PORT || 3001;
const DOWNLOADS_DIR = path.join(__dirname, "downloads");

// Middleware
app.use(cors());
app.use(express.json());
app.use("/downloads", express.static(DOWNLOADS_DIR));

// Ensure downloads directory exists
fs.ensureDirSync(DOWNLOADS_DIR);

// Store active downloads
const activeDownloads = new Map();

// Store download processes for control
const downloadProcesses = new Map();

// Socket.io connection handling
io.on("connection", (socket) => {
  console.log("Client connected:", socket.id);

  socket.on("disconnect", () => {
    console.log("Client disconnected:", socket.id);
  });
});

// Download endpoint
app.post("/api/download", async (req, res) => {
  const { url, format = "mp4", quality = "best" } = req.body;

  if (!url) {
    return res.status(400).json({ error: "URL is required" });
  }

  const downloadId = uuidv4();
  const downloadDir = path.join(DOWNLOADS_DIR, downloadId);

  try {
    // Create download directory
    await fs.ensureDir(downloadDir);

    // Start download process
    const downloadProcess = startDownload(
      url,
      downloadDir,
      format,
      quality,
      downloadId
    );
    activeDownloads.set(downloadId, downloadProcess);

    res.json({
      downloadId,
      message: "Download started",
      status: "started",
    });
  } catch (error) {
    console.error("Download error:", error);
    res.status(500).json({ error: "Failed to start download" });
  }
});

// Get download status
app.get("/api/download/:id/status", (req, res) => {
  const { id } = req.params;
  const download = activeDownloads.get(id);

  if (!download) {
    return res.status(404).json({ error: "Download not found" });
  }

  res.json({
    downloadId: id,
    status: download.status,
    progress: download.progress,
    message: download.message,
    error: download.error,
  });
});

// Pause download
app.post("/api/download/:id/pause", (req, res) => {
  const { id } = req.params;
  const process = downloadProcesses.get(id);
  const download = activeDownloads.get(id);

  if (!process || !download) {
    return res.status(404).json({ error: "Download not found" });
  }

  if (process.kill("SIGSTOP")) {
    download.status = "paused";
    download.message = "Download paused";

    io.emit("downloadProgress", {
      downloadId: id,
      status: download.status,
      message: download.message,
      progress: download.progress,
    });

    res.json({ message: "Download paused" });
  } else {
    res.status(500).json({ error: "Failed to pause download" });
  }
});

// Resume download
app.post("/api/download/:id/resume", (req, res) => {
  const { id } = req.params;
  const process = downloadProcesses.get(id);
  const download = activeDownloads.get(id);

  if (!process || !download) {
    return res.status(404).json({ error: "Download not found" });
  }

  if (process.kill("SIGCONT")) {
    download.status = "downloading";
    download.message = "Download resumed";

    io.emit("downloadProgress", {
      downloadId: id,
      status: download.status,
      message: download.message,
      progress: download.progress,
    });

    res.json({ message: "Download resumed" });
  } else {
    res.status(500).json({ error: "Failed to resume download" });
  }
});

// Stop download
app.post("/api/download/:id/stop", (req, res) => {
  const { id } = req.params;
  const process = downloadProcesses.get(id);
  const download = activeDownloads.get(id);

  if (!process || !download) {
    return res.status(404).json({ error: "Download not found" });
  }

  if (process.kill("SIGTERM")) {
    download.status = "stopped";
    download.message = "Download stopped";

    io.emit("downloadProgress", {
      downloadId: id,
      status: download.status,
      message: download.message,
      progress: download.progress,
    });

    // Clean up
    downloadProcesses.delete(id);

    res.json({ message: "Download stopped" });
  } else {
    res.status(500).json({ error: "Failed to stop download" });
  }
});

// Get downloaded files
app.get("/api/download/:id/files", async (req, res) => {
  const { id } = req.params;
  const downloadDir = path.join(DOWNLOADS_DIR, id);

  try {
    if (!(await fs.pathExists(downloadDir))) {
      return res.status(404).json({ error: "Download directory not found" });
    }

    const files = await fs.readdir(downloadDir);
    const videoFiles = files.filter(
      (file) => file.endsWith(".mp4") || file.endsWith(".mkv")
    );

    const fileList = videoFiles.map((file) => ({
      name: file,
      url: `/downloads/${id}/${file}`,
      size: fs.statSync(path.join(downloadDir, file)).size,
    }));

    res.json({ files: fileList });
  } catch (error) {
    console.error("Error getting files:", error);
    res.status(500).json({ error: "Failed to get files" });
  }
});

// Get available video qualities
app.post("/api/video-info", async (req, res) => {
  const { url } = req.body;

  if (!url) {
    return res.status(400).json({ error: "URL is required" });
  }

  try {
    // Use yt-dlp to get video information
    const ytDlpProcess = spawn("yt-dlp", [
      "--list-formats",
      "--no-download",
      url,
    ]);

    let output = "";
    let errorOutput = "";

    ytDlpProcess.stdout.on("data", (data) => {
      output += data.toString();
    });

    ytDlpProcess.stderr.on("data", (data) => {
      errorOutput += data.toString();
    });

    ytDlpProcess.on("close", (code) => {
      if (code !== 0) {
        return res.status(500).json({
          error: "Failed to get video info",
          details: errorOutput,
        });
      }

      // Parse available qualities from yt-dlp output
      const qualities = parseAvailableQualities(output);
      res.json({ qualities });
    });
  } catch (error) {
    console.error("Error getting video info:", error);
    res.status(500).json({ error: "Failed to get video info" });
  }
});

function parseAvailableQualities(output) {
  const qualities = [
    {
      value: "best",
      label: "Best Quality",
      description: "Highest available quality",
    },
    { value: "1080p", label: "1080p", description: "Full HD (1920x1080)" },
    { value: "720p", label: "720p", description: "HD (1280x720)" },
    { value: "480p", label: "480p", description: "SD (854x480)" },
    { value: "360p", label: "360p", description: "Low (640x360)" },
    {
      value: "worst",
      label: "Worst Quality",
      description: "Lowest available quality",
    },
  ];

  // Parse the yt-dlp output to find actually available qualities
  const lines = output.split("\n");
  const availableHeights = new Set();

  for (const line of lines) {
    // Look for format lines that contain resolution info
    const match = line.match(/(\d+)x(\d+)/);
    if (match) {
      const height = parseInt(match[2]);
      availableHeights.add(height);
    }
  }

  // Filter qualities based on what's actually available
  return qualities.filter((quality) => {
    if (quality.value === "best" || quality.value === "worst") {
      return true;
    }
    const height = parseInt(quality.value.replace("p", ""));
    return availableHeights.has(height) || availableHeights.size === 0; // Show all if we can't parse
  });
}

function startDownload(url, downloadDir, format, quality, downloadId) {
  const download = {
    status: "downloading",
    progress: 0,
    message: "Starting download...",
    error: null,
    speed: null,
    eta: null,
    elapsed: null,
    downloadedBytes: 0,
    totalBytes: 0,
    startTime: Date.now(),
  };

  // Build quality format string for yt-dlp
  let formatString;
  if (quality === "best") {
    formatString = "bestvideo+bestaudio/best";
  } else if (quality === "worst") {
    formatString = "worstvideo+worstaudio/worst";
  } else {
    // For specific resolutions like 1080p, 720p, etc.
    formatString = `bestvideo[height<=${quality.replace(
      "p",
      ""
    )}]+bestaudio/best[height<=${quality.replace("p", "")}]`;
  }

  // yt-dlp command
  const ytDlpArgs = [
    "-f",
    formatString,
    "--merge-output-format",
    format,
    "--write-info-json",
    "--write-description",
    "-o",
    path.join(downloadDir, "%(title)s.%(ext)s"),
    url,
  ];

  const ytDlpProcess = spawn("yt-dlp", ytDlpArgs);

  // Store process for control
  downloadProcesses.set(downloadId, ytDlpProcess);

  ytDlpProcess.stdout.on("data", (data) => {
    const output = data.toString();
    console.log("yt-dlp stdout:", output);

    // Parse comprehensive progress from yt-dlp output
    parseYtDlpProgress(output, download, downloadId);
  });

  ytDlpProcess.stderr.on("data", (data) => {
    const error = data.toString();
    console.error("yt-dlp stderr:", error);

    if (!error.includes("WARNING")) {
      download.error = error;
      download.status = "error";
      download.message = "Download failed";

      io.emit("downloadProgress", {
        downloadId,
        error: download.error,
        status: download.status,
        message: download.message,
      });
    }
  });

  ytDlpProcess.on("close", (code) => {
    // Clean up process reference
    downloadProcesses.delete(downloadId);

    if (code === 0) {
      download.progress = 90;
      download.message = "Processing chapters...";
      download.status = "processing";

      io.emit("downloadProgress", {
        downloadId,
        progress: download.progress,
        message: download.message,
        status: download.status,
        speed: download.speed,
        eta: download.eta,
        elapsed: download.elapsed,
      });

      // Process chapters
      processChapters(downloadDir, format, download, downloadId);
    } else if (code === null) {
      // Process was killed (stopped by user)
      download.status = "stopped";
      download.message = "Download stopped by user";
    } else {
      download.status = "error";
      download.message = "Download failed";
      download.error = `yt-dlp exited with code ${code}`;

      io.emit("downloadProgress", {
        downloadId,
        error: download.error,
        status: download.status,
        message: download.message,
      });
    }
  });

  return download;
}

function parseYtDlpProgress(output, download, downloadId) {
  // Parse different types of yt-dlp progress output
  const lines = output.split("\n");

  for (const line of lines) {
    // Match progress line: [download]  45.2% of 123.45MiB at 1.23MiB/s ETA 00:45
    const progressMatch = line.match(
      /\[download\]\s+(\d+\.?\d*)%\s+of\s+([\d.]+\w+)\s+at\s+([\d.]+\w+\/s)(?:\s+ETA\s+(\d+:\d+))?/
    );

    if (progressMatch) {
      const percent = parseFloat(progressMatch[1]);
      const totalSize = progressMatch[2];
      const speed = progressMatch[3];
      const eta = progressMatch[4];

      // Scale progress to 0-85% for download phase (leave room for chapter processing)
      download.progress = Math.min(percent * 0.85, 85);
      download.speed = speed;
      download.eta = eta;
      download.elapsed = formatElapsedTime(Date.now() - download.startTime);
      download.message = `Downloading... ${percent.toFixed(1)}%`;

      // Emit progress update
      io.emit("downloadProgress", {
        downloadId,
        progress: download.progress,
        message: download.message,
        status: download.status,
        speed: download.speed,
        eta: download.eta,
        elapsed: download.elapsed,
      });
    }

    // Match simple progress: 45.2%
    else if (line.includes("%") && !progressMatch) {
      const simpleMatch = line.match(/(\d+\.?\d*)%/);
      if (simpleMatch) {
        const percent = parseFloat(simpleMatch[1]);
        download.progress = Math.min(percent * 0.85, 85);
        download.elapsed = formatElapsedTime(Date.now() - download.startTime);
        download.message = `Downloading... ${percent.toFixed(1)}%`;

        io.emit("downloadProgress", {
          downloadId,
          progress: download.progress,
          message: download.message,
          status: download.status,
          elapsed: download.elapsed,
        });
      }
    }
  }
}

function formatElapsedTime(milliseconds) {
  const seconds = Math.floor(milliseconds / 1000);
  const minutes = Math.floor(seconds / 60);
  const hours = Math.floor(minutes / 60);

  if (hours > 0) {
    return `${hours}:${(minutes % 60).toString().padStart(2, "0")}:${(
      seconds % 60
    )
      .toString()
      .padStart(2, "0")}`;
  } else {
    return `${minutes}:${(seconds % 60).toString().padStart(2, "0")}`;
  }
}

async function processChapters(downloadDir, format, download, downloadId) {
  try {
    download.progress = 90;
    download.message = "Processing chapters...";

    io.emit("downloadProgress", {
      downloadId,
      progress: download.progress,
      message: download.message,
      status: download.status,
    });

    // Find the latest video file
    const files = await fs.readdir(downloadDir);
    const videoFiles = files.filter((file) => file.endsWith(`.${format}`));

    if (videoFiles.length === 0) {
      throw new Error("No video file found");
    }

    const videoFile = videoFiles[0];
    const videoPath = path.join(downloadDir, videoFile);
    const jsonPath = path.join(
      downloadDir,
      videoFile.replace(`.${format}`, ".info.json")
    );

    // Check if info.json exists
    if (!(await fs.pathExists(jsonPath))) {
      download.progress = 100;
      download.status = "completed";
      download.message = "Download completed (no chapters found)";

      io.emit("downloadProgress", {
        downloadId,
        progress: download.progress,
        status: download.status,
        message: download.message,
        elapsed: download.elapsed,
      });
      return;
    }

    // Read video info
    const infoData = await fs.readJson(jsonPath);
    const chapters = infoData.chapters;

    if (!chapters || chapters.length === 0) {
      download.progress = 100;
      download.status = "completed";
      download.message = "Download completed (no chapters found)";

      io.emit("downloadProgress", {
        downloadId,
        progress: download.progress,
        status: download.status,
        message: download.message,
        elapsed: download.elapsed,
      });
      return;
    }

    download.progress = 95;
    download.message = `Embedding ${chapters.length} chapters...`;

    io.emit("downloadProgress", {
      downloadId,
      progress: download.progress,
      message: download.message,
      status: download.status,
    });

    // Create chapter metadata file for FFmpeg
    const chapterFile = path.join(downloadDir, "chapters.txt");
    let chapterContent = ";FFMETADATA1\n";

    chapters.forEach((chapter, index) => {
      const startTime = Math.floor(chapter.start_time * 1000); // Convert to milliseconds
      const endTime = chapter.end_time
        ? Math.floor(chapter.end_time * 1000)
        : null;

      chapterContent += `[CHAPTER]\n`;
      chapterContent += `TIMEBASE=1/1000\n`;
      chapterContent += `START=${startTime}\n`;
      if (endTime) {
        chapterContent += `END=${endTime}\n`;
      }
      chapterContent += `title=${chapter.title}\n\n`;
    });

    await fs.writeFile(chapterFile, chapterContent);

    const tempFile = path.join(downloadDir, `temp_${videoFile}`);

    // FFmpeg command to embed chapters properly
    const ffmpegArgs = [
      "-i",
      videoPath,
      "-i",
      chapterFile,
      "-map_metadata",
      "1",
      "-map_chapters",
      "1",
      "-c",
      "copy",
      "-y",
      tempFile,
    ];

    const ffmpegProcess = spawn("ffmpeg", ffmpegArgs);

    ffmpegProcess.on("close", async (code) => {
      try {
        // Clean up chapter file
        await fs.remove(chapterFile);

        if (code === 0) {
          // Replace original file with processed file
          await fs.move(tempFile, videoPath, { overwrite: true });

          download.progress = 100;
          download.status = "completed";
          download.message = `Download completed with ${chapters.length} chapters embedded`;
        } else {
          // If chapter embedding failed, keep original file
          await fs.remove(tempFile).catch(() => {});

          download.progress = 100;
          download.status = "completed";
          download.message = `Download completed (${chapters.length} chapters found but embedding failed)`;
        }

        io.emit("downloadProgress", {
          downloadId,
          progress: download.progress,
          status: download.status,
          message: download.message,
          elapsed: formatElapsedTime(Date.now() - download.startTime),
        });
      } catch (error) {
        console.error("Error in chapter processing cleanup:", error);
      }
    });

    ffmpegProcess.stderr.on("data", (data) => {
      const output = data.toString();
      console.log("FFmpeg stderr:", output);

      // Update progress during chapter processing
      if (output.includes("time=")) {
        download.progress = Math.min(download.progress + 1, 99);

        io.emit("downloadProgress", {
          downloadId,
          progress: download.progress,
          message: download.message,
          status: download.status,
        });
      }
    });
  } catch (error) {
    console.error("Chapter processing error:", error);
    download.progress = 100;
    download.status = "completed";
    download.message = "Download completed (chapter processing failed)";

    io.emit("downloadProgress", {
      downloadId,
      progress: download.progress,
      status: download.status,
      message: download.message,
      elapsed: formatElapsedTime(Date.now() - download.startTime),
    });
  }
}

// Health check endpoint
app.get("/api/health", (req, res) => {
  res.json({ status: "OK", message: "Server is running" });
});

server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Downloads directory: ${DOWNLOADS_DIR}`);
});
