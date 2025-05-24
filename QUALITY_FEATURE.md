# Video Quality Selection Feature

This document describes the video quality selection feature that has been added to the YouTube Chapter Downloader.

## 🎯 Overview

The quality selection feature allows users to choose the video resolution/quality before downloading, providing options from highest quality to lowest quality, including specific resolutions like 1080p, 720p, 480p, and 360p.

## 🔧 Backend Implementation

### API Endpoints

#### 1. Enhanced Download Endpoint

- **Endpoint**: `POST /api/download`
- **New Parameter**: `quality` (string)
- **Example Request**:

```json
{
  "url": "https://youtube.com/watch?v=...",
  "format": "mp4",
  "quality": "720p"
}
```

#### 2. Video Info Endpoint (New)

- **Endpoint**: `POST /api/video-info`
- **Purpose**: Get available video qualities for a specific URL
- **Request**:

```json
{
  "url": "https://youtube.com/watch?v=..."
}
```

- **Response**:

```json
{
  "qualities": [
    {
      "value": "best",
      "label": "Best Quality",
      "description": "Highest available quality"
    },
    {
      "value": "1080p",
      "label": "1080p",
      "description": "Full HD (1920x1080)"
    },
    {
      "value": "720p",
      "label": "720p",
      "description": "HD (1280x720)"
    }
  ]
}
```

### Quality Format Mapping

The backend converts quality selections to yt-dlp format strings:

- **"best"** → `"bestvideo+bestaudio/best"`
- **"worst"** → `"worstvideo+worstaudio/worst"`
- **"1080p"** → `"bestvideo[height<=1080]+bestaudio/best[height<=1080]"`
- **"720p"** → `"bestvideo[height<=720]+bestaudio/best[height<=720]"`
- **"480p"** → `"bestvideo[height<=480]+bestaudio/best[height<=480]"`
- **"360p"** → `"bestvideo[height<=360]+bestaudio/best[height<=360]"`

## 📱 Flutter App Implementation

### 1. Data Models

#### VideoQuality Model

```dart
class VideoQuality {
  final String value;      // "720p", "best", etc.
  final String label;      // "720p", "Best Quality", etc.
  final String description; // "HD (1280x720)", etc.
}
```

### 2. API Service Updates

#### Enhanced Methods

- `startDownload(String url, String format, String quality)` - Now accepts quality parameter
- `getVideoQualities(String url)` - New method to fetch available qualities

### 3. UI Components

#### Quality Selection Dropdown

- **Location**: Download form, between format selection and download button
- **Features**:
  - Dropdown with quality options
  - Each option shows label and description
  - Refresh button to load video-specific qualities
  - Loading indicator during quality fetch

#### Quality Options Display

```dart
DropdownMenuItem(
  value: quality.value,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(quality.label),           // "720p"
      Text(quality.description),     // "HD (1280x720)"
    ],
  ),
)
```

### 4. User Workflow

1. **Enter YouTube URL**
2. **Select Format** (MP4/MKV)
3. **Choose Quality**:
   - Use default options (Best, 1080p, 720p, 480p, 360p, Worst)
   - OR click refresh button to load video-specific qualities
4. **Start Download** with selected quality

## 🎨 UI Features

### Quality Selection Interface

- **Dropdown Menu**: Shows available quality options
- **Refresh Button**: Loads video-specific qualities
- **Loading State**: Shows spinner while fetching qualities
- **Tooltips**: Helpful descriptions for each quality option
- **Error Handling**: User-friendly error messages

### Quality Options

| Value   | Label         | Description               |
| ------- | ------------- | ------------------------- |
| `best`  | Best Quality  | Highest available quality |
| `1080p` | 1080p         | Full HD (1920x1080)       |
| `720p`  | 720p          | HD (1280x720)             |
| `480p`  | 480p          | SD (854x480)              |
| `360p`  | 360p          | Low (640x360)             |
| `worst` | Worst Quality | Lowest available quality  |

## 🔄 Dynamic Quality Loading

### Process

1. User enters YouTube URL
2. User clicks refresh button next to quality dropdown
3. App validates URL format
4. Backend calls `yt-dlp --list-formats` to get available formats
5. Backend parses output to extract available resolutions
6. Backend returns filtered quality list based on actual availability
7. Flutter app updates dropdown with video-specific options

### Error Handling

- **Invalid URL**: Shows warning to enter valid YouTube URL first
- **Network Error**: Shows error message with retry option
- **No Qualities Found**: Falls back to default quality options
- **Server Offline**: Disables quality refresh functionality

## 🚀 Benefits

### For Users

- **Quality Control**: Choose optimal quality for device/bandwidth
- **Storage Management**: Select lower quality to save space
- **Bandwidth Optimization**: Avoid unnecessary high-quality downloads
- **Flexibility**: Options from highest to lowest quality

### For Developers

- **Extensible**: Easy to add new quality options
- **Robust**: Fallback to default options if dynamic loading fails
- **User-Friendly**: Clear labels and descriptions
- **Efficient**: Only loads specific qualities when requested

## 🔧 Configuration

### Default Qualities

The app includes sensible defaults that work for most videos:

- Best Quality (recommended)
- 1080p Full HD
- 720p HD
- 480p Standard Definition
- 360p Low Quality
- Worst Quality (smallest file)

### Server Configuration

No additional server configuration required. The feature uses existing yt-dlp installation.

## 📝 Usage Examples

### Basic Usage

```dart
// Start download with specific quality
await provider.startDownload(
  'https://youtube.com/watch?v=example',
  'mp4',
  '720p'
);
```

### Dynamic Quality Loading

```dart
// Get available qualities for a video
final qualities = await provider.getVideoQualities(url);
if (qualities != null) {
  // Update UI with video-specific options
  setState(() {
    _availableQualities = qualities;
  });
}
```

## 🎯 Future Enhancements

- **Audio Quality Selection**: Separate audio bitrate options
- **Custom Quality**: Allow manual resolution input
- **Quality Presets**: Save user's preferred quality settings
- **Bandwidth Detection**: Auto-suggest quality based on connection speed
- **Preview Mode**: Show estimated file size for each quality option

## 🐛 Troubleshooting

### Common Issues

1. **Quality not available**: Falls back to "best" quality
2. **Slow quality loading**: Network-dependent, shows loading indicator
3. **Server errors**: Graceful fallback to default options

### Debug Information

- Check browser network tab for API calls
- Verify yt-dlp installation on server
- Check server logs for yt-dlp output parsing
