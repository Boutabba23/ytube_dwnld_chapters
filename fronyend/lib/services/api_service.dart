import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/download_model.dart';

class ApiService {
  static const String baseUrl =
      'http://localhost:3001'; // Change this to your server IP
  static const String apiUrl = '$baseUrl/api';

  late IO.Socket socket;

  ApiService() {
    _initSocket();
  }

  void _initSocket() {
    socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
  }

  void connectSocket() {
    if (!socket.connected) {
      socket.connect();
    }
  }

  void disconnectSocket() {
    if (socket.connected) {
      socket.disconnect();
    }
  }

  void onDownloadProgress(Function(DownloadModel) callback) {
    socket.on('downloadProgress', (data) {
      try {
        final downloadModel = DownloadModel.fromJson(data);
        callback(downloadModel);
      } catch (e) {
        print('Error parsing download progress: $e');
      }
    });
  }

  Future<DownloadModel?> startDownload(
    String url,
    String format,
    String quality,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/download'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': url, 'format': format, 'quality': quality}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DownloadModel.fromJson(data);
      } else {
        print('Failed to start download: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error starting download: $e');
      return null;
    }
  }

  Future<List<VideoQuality>?> getVideoQualities(String url) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/video-info'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': url}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final qualities =
            (data['qualities'] as List)
                .map((quality) => VideoQuality.fromJson(quality))
                .toList();
        return qualities;
      } else {
        print('Failed to get video qualities: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting video qualities: $e');
      return null;
    }
  }

  Future<DownloadModel?> getDownloadStatus(String downloadId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/download/$downloadId/status'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DownloadModel.fromJson(data);
      } else {
        print('Failed to get download status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting download status: $e');
      return null;
    }
  }

  Future<List<DownloadedFile>?> getDownloadedFiles(String downloadId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/download/$downloadId/files'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final files =
            (data['files'] as List)
                .map((file) => DownloadedFile.fromJson(file))
                .toList();
        return files;
      } else {
        print('Failed to get downloaded files: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting downloaded files: $e');
      return null;
    }
  }

  Future<bool> checkServerHealth() async {
    try {
      final response = await http
          .get(
            Uri.parse('$apiUrl/health'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Server health check failed: $e');
      return false;
    }
  }

  String getFileUrl(String downloadId, String fileName) {
    return '$baseUrl/downloads/$downloadId/$fileName';
  }

  Future<bool> pauseDownload(String downloadId) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/download/$downloadId/pause'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error pausing download: $e');
      return false;
    }
  }

  Future<bool> resumeDownload(String downloadId) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/download/$downloadId/resume'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error resuming download: $e');
      return false;
    }
  }

  Future<bool> stopDownload(String downloadId) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/download/$downloadId/stop'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error stopping download: $e');
      return false;
    }
  }
}
