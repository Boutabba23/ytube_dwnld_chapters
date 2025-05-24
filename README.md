# YouTube Chapter Downloader

A complete solution for downloading YouTube videos with chapter support, consisting of a Flutter mobile app and Node.js backend server. This project recreates the functionality of the original Python GUI application in a modern mobile-first architecture.

## 🎯 Features

- **YouTube Video Download**: Download videos with best available quality
- **Chapter Extraction**: Automatically extract and embed chapter information from YouTube
- **Real-time Progress**: Live progress updates via WebSocket connection
- **Multiple Formats**: Support for MP4 and MKV video formats
- **Mobile-First**: Native Flutter app for Android and iOS
- **Cross-Platform Backend**: Node.js server that can run on any platform
- **Download History**: Track and manage previous downloads
- **Server Status Monitoring**: Real-time connection status

## 🏗️ Architecture

```
YouTube Chapter Downloader/
├── backend/                 # Node.js Backend Server
│   ├── server.js           # Main server file
│   ├── package.json        # Dependencies
│   ├── downloads/          # Downloaded files (auto-created)
│   └── README.md          # Backend documentation
├── ytube_dwnld/           # Flutter Mobile App
│   ├── lib/               # Dart source code
│   ├── pubspec.yaml       # Flutter dependencies
│   └── README.md          # App documentation
├── yt_chapter_downloader.py # Original Python GUI (reference)
└── README.md              # This file
```

## 🚀 Quick Start

### 1. Backend Setup

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Start the server
npm run dev
```

The backend server will start on `http://localhost:3000`

### 2. Flutter App Setup

```bash
# Navigate to Flutter app directory
cd ytube_dwnld

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 📋 Prerequisites

### Backend Requirements

- **Node.js** (v16 or higher)
- **yt-dlp** - YouTube downloader tool
- **ffmpeg** - Video processing tool

### Flutter Requirements

- **Flutter SDK** (3.7.2 or higher)
- **Android Studio** or **Xcode** for mobile development

### Installing System Dependencies

#### Ubuntu/Debian

```bash
# Install yt-dlp and ffmpeg
sudo apt update
sudo apt install yt-dlp ffmpeg

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

#### macOS

```bash
# Install using Homebrew
brew install yt-dlp ffmpeg node
```

#### Windows

```bash
# Install using Chocolatey
choco install yt-dlp ffmpeg nodejs

# Or using Scoop
scoop install yt-dlp ffmpeg nodejs
```

## 🔧 Configuration

### Backend Configuration

The backend server runs on port 3000 by default. You can change this by setting the `PORT` environment variable:

```bash
PORT=8080 npm start
```

### Flutter App Configuration

Update the server URL in [`ytube_dwnld/lib/services/api_service.dart`](ytube_dwnld/lib/services/api_service.dart):

```dart
static const String baseUrl = 'http://YOUR_SERVER_IP:3000';
```

For local development:

```dart
static const String baseUrl = 'http://localhost:3000';
```

For testing on physical devices:

```dart
static const String baseUrl = 'http://192.168.1.100:3000'; // Your computer's IP
```

## 📱 Usage

1. **Start the Backend Server**:

   ```bash
   cd backend && npm run dev
   ```

2. **Launch the Flutter App**:

   ```bash
   cd ytube_dwnld && flutter run
   ```

3. **Download Videos**:
   - Enter a YouTube URL
   - Select video format (MP4/MKV)
   - Tap "Start Download"
   - Monitor real-time progress
   - View completed downloads in History tab

## 🔄 API Endpoints

### REST API

- `POST /api/download` - Start a new download
- `GET /api/download/:id/status` - Get download status
- `GET /api/download/:id/files` - Get downloaded files
- `GET /api/health` - Server health check

### WebSocket Events

- `downloadProgress` - Real-time progress updates

## 🎨 Screenshots

### Flutter App

- **Download Tab**: URL input, format selection, progress tracking
- **History Tab**: Previous downloads with expandable details
- **Real-time Updates**: Live progress via WebSocket connection

### Original Python GUI

The original Python application ([`yt_chapter_downloader.py`](yt_chapter_downloader.py)) provides the same core functionality with a desktop GUI using tkinter.

## 🔍 Comparison with Original

| Feature           | Python GUI   | Flutter + Node.js         |
| ----------------- | ------------ | ------------------------- |
| Platform          | Desktop only | Mobile + Web              |
| UI Framework      | tkinter      | Flutter (Material Design) |
| Real-time Updates | Threading    | WebSocket                 |
| Architecture      | Monolithic   | Client-Server             |
| Scalability       | Single user  | Multi-user capable        |
| Deployment        | Local only   | Cloud deployable          |

## 🛠️ Development

### Backend Development

```bash
cd backend
npm run dev  # Auto-restart on changes
```

### Flutter Development

```bash
cd ytube_dwnld
flutter run  # Hot reload enabled
```

### Testing

```bash
# Backend tests
cd backend && npm test

# Flutter tests
cd ytube_dwnld && flutter test
```

## 📦 Deployment

### Backend Deployment

- Deploy to any Node.js hosting service (Heroku, DigitalOcean, AWS, etc.)
- Ensure yt-dlp and ffmpeg are available on the server
- Set environment variables for production

### Flutter App Deployment

```bash
# Android APK
flutter build apk --release

# iOS (macOS only)
flutter build ios --release

# Web
flutter build web
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **yt-dlp** - Powerful YouTube downloader
- **FFmpeg** - Video processing capabilities
- **Flutter** - Cross-platform mobile framework
- **Node.js** - Backend runtime environment

## 📞 Support

If you encounter any issues:

1. Check the [Backend README](backend/README.md) for server setup
2. Check the [Flutter README](ytube_dwnld/README.md) for app setup
3. Ensure all prerequisites are installed
4. Verify network connectivity between app and server
5. Check server logs for error details

## 🔮 Future Enhancements

- [ ] Playlist download support
- [ ] Audio-only download option
- [ ] Download queue management
- [ ] User authentication
- [ ] Cloud storage integration
- [ ] Subtitle download
- [ ] Video quality selection
- [ ] Batch download operations
