class DownloadModel {
  final String downloadId;
  final String status;
  final double progress;
  final String message;
  final String? error;
  final List<DownloadedFile>? files;
  final String? speed;
  final String? eta;
  final String? elapsed;

  DownloadModel({
    required this.downloadId,
    required this.status,
    required this.progress,
    required this.message,
    this.error,
    this.files,
    this.speed,
    this.eta,
    this.elapsed,
  });

  factory DownloadModel.fromJson(Map<String, dynamic> json) {
    return DownloadModel(
      downloadId: json['downloadId'] ?? '',
      status: json['status'] ?? 'unknown',
      progress: (json['progress'] ?? 0).toDouble(),
      message: json['message'] ?? '',
      error: json['error'],
      speed: json['speed'],
      eta: json['eta'],
      elapsed: json['elapsed'],
      files:
          json['files'] != null
              ? (json['files'] as List)
                  .map((file) => DownloadedFile.fromJson(file))
                  .toList()
              : null,
    );
  }

  DownloadModel copyWith({
    String? downloadId,
    String? status,
    double? progress,
    String? message,
    String? error,
    List<DownloadedFile>? files,
    String? speed,
    String? eta,
    String? elapsed,
  }) {
    return DownloadModel(
      downloadId: downloadId ?? this.downloadId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      error: error ?? this.error,
      files: files ?? this.files,
      speed: speed ?? this.speed,
      eta: eta ?? this.eta,
      elapsed: elapsed ?? this.elapsed,
    );
  }
}

class DownloadedFile {
  final String name;
  final String url;
  final int size;

  DownloadedFile({required this.name, required this.url, required this.size});

  factory DownloadedFile.fromJson(Map<String, dynamic> json) {
    return DownloadedFile(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      size: json['size'] ?? 0,
    );
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class VideoQuality {
  final String value;
  final String label;
  final String description;

  VideoQuality({
    required this.value,
    required this.label,
    required this.description,
  });

  factory VideoQuality.fromJson(Map<String, dynamic> json) {
    return VideoQuality(
      value: json['value'] ?? '',
      label: json['label'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
