# YouTube Chapter Downloader Backend

A Node.js backend server for downloading YouTube videos with chapter support using yt-dlp.

## Prerequisites

Before running the server, make sure you have the following installed:

1. **Node.js** (v16 or higher)
2. **yt-dlp** - YouTube downloader
3. **ffmpeg** - Video processing tool

### Installing yt-dlp

```bash
# On Ubuntu/Debian
sudo apt update
sudo apt install yt-dlp

# On macOS with Homebrew
brew install yt-dlp

# Using pip
pip install yt-dlp
```

### Installing ffmpeg

```bash
# On Ubuntu/Debian
sudo apt install ffmpeg

# On macOS with Homebrew
brew install ffmpeg
```

## Setup

1. Navigate to the backend directory:

```bash
cd backend
```

2. Install dependencies:

```bash
npm install
```

3. Start the server:

```bash
# Development mode with auto-restart
npm run dev

# Production mode
npm start
```

The server will start on port 3000 by default.

## API Endpoints

### POST /api/download

Start a new download.

**Request Body:**

```json
{
  "url": "https://youtube.com/watch?v=...",
  "format": "mp4"
}
```

**Response:**

```json
{
  "downloadId": "uuid-string",
  "message": "Download started",
  "status": "started"
}
```

### GET /api/download/:id/status

Get download status and progress.

**Response:**

```json
{
  "downloadId": "uuid-string",
  "status": "downloading|completed|error",
  "progress": 75,
  "message": "Processing chapters...",
  "error": null
}
```

### GET /api/download/:id/files

Get list of downloaded files.

**Response:**

```json
{
  "files": [
    {
      "name": "video.mp4",
      "url": "/downloads/uuid/video.mp4",
      "size": 1234567
    }
  ]
}
```

## WebSocket Events

The server uses Socket.IO for real-time progress updates:

### Event: downloadProgress

```json
{
  "downloadId": "uuid-string",
  "progress": 75,
  "message": "Processing chapters...",
  "status": "downloading"
}
```

## Features

- Download YouTube videos with best quality
- Extract and embed chapter information
- Real-time progress updates via WebSocket
- Support for MP4 and MKV formats
- RESTful API for integration with mobile apps
- File serving for downloaded content

## Directory Structure

```
backend/
├── server.js          # Main server file
├── package.json       # Dependencies
├── downloads/         # Downloaded files (auto-created)
└── README.md         # This file
```
