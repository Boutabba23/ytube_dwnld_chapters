import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/download_model.dart';
import '../providers/download_provider.dart';

class DownloadProgress extends StatelessWidget {
  final DownloadModel download;

  const DownloadProgress({super.key, required this.download});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Download Progress',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: download.progress / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  download.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${download.progress.toStringAsFixed(1)}%',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (download.error != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  'Error: ${download.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
            if (download.status == 'completed') ...[
              const SizedBox(height: 16),
              _buildCompletedActions(),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => _refreshStatus(context),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
                TextButton.icon(
                  onPressed: () => _clearDownload(context),
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color chipColor;
    IconData chipIcon;

    switch (download.status) {
      case 'downloading':
      case 'started':
        chipColor = Colors.blue;
        chipIcon = Icons.download;
        break;
      case 'completed':
        chipColor = Colors.green;
        chipIcon = Icons.check_circle;
        break;
      case 'error':
        chipColor = Colors.red;
        chipIcon = Icons.error;
        break;
      default:
        chipColor = Colors.grey;
        chipIcon = Icons.help;
    }

    return Chip(
      avatar: Icon(chipIcon, color: Colors.white, size: 16),
      label: Text(
        download.status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
    );
  }

  Color _getProgressColor() {
    switch (download.status) {
      case 'downloading':
      case 'started':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildCompletedActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => _loadFiles(),
          icon: const Icon(Icons.folder),
          label: const Text('View Downloaded Files'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        if (download.files != null && download.files!.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...download.files!.map((file) => _buildFileItem(file)),
        ],
      ],
    );
  }

  Widget _buildFileItem(DownloadedFile file) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.video_file),
        title: Text(file.name, style: const TextStyle(fontSize: 14)),
        subtitle: Text(file.formattedSize),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: () => _openFile(file),
        ),
      ),
    );
  }

  void _refreshStatus(BuildContext context) {
    final provider = Provider.of<DownloadProvider>(context, listen: false);
    provider.refreshDownloadStatus();
  }

  void _clearDownload(BuildContext context) {
    final provider = Provider.of<DownloadProvider>(context, listen: false);
    provider.clearCurrentDownload();
  }

  void _loadFiles() {
    // This would be called from the provider context
    // provider.loadDownloadedFiles(download.downloadId);
  }

  void _openFile(DownloadedFile file) {
    // This would open the file using url_launcher
    // launch(file.url);
  }
}
