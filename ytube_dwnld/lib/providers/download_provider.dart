import 'package:flutter/foundation.dart';
import '../models/download_model.dart';
import '../services/api_service.dart';

class DownloadProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  DownloadModel? _currentDownload;
  List<DownloadModel> _downloadHistory = [];
  bool _isServerConnected = false;

  DownloadModel? get currentDownload => _currentDownload;
  List<DownloadModel> get downloadHistory => _downloadHistory;
  bool get isServerConnected => _isServerConnected;

  DownloadProvider() {
    _initializeProvider();
  }

  void _initializeProvider() {
    _checkServerConnection();
    _apiService.connectSocket();
    _apiService.onDownloadProgress(_onDownloadProgress);
  }

  Future<void> _checkServerConnection() async {
    _isServerConnected = await _apiService.checkServerHealth();
    notifyListeners();
  }

  void _onDownloadProgress(DownloadModel downloadModel) {
    if (_currentDownload?.downloadId == downloadModel.downloadId) {
      _currentDownload = downloadModel;

      // Update history if download is completed
      if (downloadModel.status == 'completed' ||
          downloadModel.status == 'error') {
        _updateDownloadHistory(downloadModel);
      }

      notifyListeners();
    }
  }

  void _updateDownloadHistory(DownloadModel download) {
    final existingIndex = _downloadHistory.indexWhere(
      (d) => d.downloadId == download.downloadId,
    );

    if (existingIndex != -1) {
      _downloadHistory[existingIndex] = download;
    } else {
      _downloadHistory.insert(0, download);
    }

    // Keep only last 10 downloads
    if (_downloadHistory.length > 10) {
      _downloadHistory = _downloadHistory.take(10).toList();
    }
  }

  Future<bool> startDownload(String url, String format, String quality) async {
    if (!_isServerConnected) {
      await _checkServerConnection();
      if (!_isServerConnected) {
        return false;
      }
    }

    final result = await _apiService.startDownload(url, format, quality);
    if (result != null) {
      _currentDownload = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<List<VideoQuality>?> getVideoQualities(String url) async {
    if (!_isServerConnected) {
      await _checkServerConnection();
      if (!_isServerConnected) {
        return null;
      }
    }

    return await _apiService.getVideoQualities(url);
  }

  Future<void> refreshDownloadStatus() async {
    if (_currentDownload != null) {
      final status = await _apiService.getDownloadStatus(
        _currentDownload!.downloadId,
      );
      if (status != null) {
        _currentDownload = status;
        notifyListeners();
      }
    }
  }

  Future<void> loadDownloadedFiles(String downloadId) async {
    final files = await _apiService.getDownloadedFiles(downloadId);
    if (files != null && _currentDownload?.downloadId == downloadId) {
      _currentDownload = _currentDownload!.copyWith(files: files);
      notifyListeners();
    }
  }

  void clearCurrentDownload() {
    _currentDownload = null;
    notifyListeners();
  }

  void clearDownloadHistory() {
    _downloadHistory.clear();
    notifyListeners();
  }

  String getFileUrl(String downloadId, String fileName) {
    return _apiService.getFileUrl(downloadId, fileName);
  }

  Future<bool> pauseDownload() async {
    if (_currentDownload == null) return false;

    final success = await _apiService.pauseDownload(
      _currentDownload!.downloadId,
    );
    if (success) {
      _currentDownload = _currentDownload!.copyWith(status: 'paused');
      notifyListeners();
    }
    return success;
  }

  Future<bool> resumeDownload() async {
    if (_currentDownload == null) return false;

    final success = await _apiService.resumeDownload(
      _currentDownload!.downloadId,
    );
    if (success) {
      _currentDownload = _currentDownload!.copyWith(status: 'downloading');
      notifyListeners();
    }
    return success;
  }

  Future<bool> stopDownload() async {
    if (_currentDownload == null) return false;

    final success = await _apiService.stopDownload(
      _currentDownload!.downloadId,
    );
    if (success) {
      _currentDownload = _currentDownload!.copyWith(status: 'stopped');
      notifyListeners();
    }
    return success;
  }

  @override
  void dispose() {
    _apiService.disconnectSocket();
    super.dispose();
  }
}
