# YouTube Chapter Downloader - Flutter App

A Flutter mobile application for downloading YouTube videos with chapter support. This app works in conjunction with a Node.js backend server.

## Features

- **YouTube Video Download**: Download videos from YouTube with best quality
- **Chapter Support**: Automatically extract and embed chapter information
- **Real-time Progress**: Live progress updates via WebSocket connection
- **Format Selection**: Choose between MP4 and MKV formats
- **Download History**: View and manage previous downloads
- **Server Status**: Real-time connection status with backend server
- **Material Design**: Modern UI with light/dark theme support

## Prerequisites

1. **Flutter SDK** (3.7.2 or higher)
2. **Backend Server**: The Node.js backend must be running (see `../backend/README.md`)

## Setup

1. Navigate to the Flutter app directory:

```bash
cd ytube_dwnld
```

2. Install dependencies:

```bash
flutter pub get
```

3. Update the server URL in `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://YOUR_SERVER_IP:3000';
```

4. Run the app:

```bash
# For development
flutter run

# For Android release
flutter build apk --release

# For iOS release (macOS only)
flutter build ios --release
```

## Configuration

### Server Connection

Update the `baseUrl` in [`lib/services/api_service.dart`](lib/services/api_service.dart:8) to match your backend server:

```dart
static const String baseUrl = 'http://localhost:3000'; // Change this to your server IP
```

For testing on a physical device, use your computer's IP address:

```dart
static const String baseUrl = 'http://192.168.1.100:3000'; // Example IP
```

### Permissions

The app requires internet permissions which are already configured in:

- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

## App Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   └── download_model.dart      # Data models
├── providers/
│   └── download_provider.dart   # State management
├── screens/
│   └── download_screen.dart     # Main screen
├── services/
│   └── api_service.dart         # Backend communication
└── widgets/
    ├── download_form.dart       # URL input form
    ├── download_progress.dart   # Progress display
    ├── download_history.dart    # History list
    └── server_status.dart       # Connection status
```

## Usage

1. **Start Backend**: Ensure the Node.js backend server is running
2. **Check Connection**: The app will show server status in the top-right
3. **Enter URL**: Paste a YouTube video URL
4. **Select Format**: Choose MP4 or MKV format
5. **Download**: Tap "Start Download" to begin
6. **Monitor Progress**: Watch real-time progress updates
7. **View History**: Check the History tab for completed downloads

## Features Overview

### Download Tab

- URL input with validation
- Format selection (MP4/MKV)
- Real-time progress tracking
- Error handling and display

### History Tab

- List of all downloads
- Expandable details for each download
- File management options
- Clear history functionality

### Real-time Updates

- WebSocket connection for live progress
- Automatic status updates
- Server connection monitoring

## Dependencies

- **http**: HTTP requests to backend API
- **socket_io_client**: Real-time communication
- **provider**: State management
- **file_picker**: File selection (future feature)
- **path_provider**: App directories
- **permission_handler**: File permissions
- **url_launcher**: Open downloaded files

## Troubleshooting

### Connection Issues

1. Verify backend server is running
2. Check server URL in `api_service.dart`
3. Ensure device and server are on same network
4. Check firewall settings

### Download Failures

1. Verify YouTube URL is valid
2. Check backend server logs
3. Ensure yt-dlp is installed on server
4. Check internet connection

### Build Issues

1. Run `flutter clean && flutter pub get`
2. Update Flutter SDK if needed
3. Check platform-specific requirements

## Development

### Adding New Features

1. Create models in `models/`
2. Add services in `services/`
3. Update providers in `providers/`
4. Create UI in `widgets/` or `screens/`

### Testing

```bash
# Run tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## Platform Support

- ✅ Android (API 21+)
- ✅ iOS (iOS 12+)
- ⚠️ Web (limited functionality)
- ⚠️ Desktop (experimental)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.
