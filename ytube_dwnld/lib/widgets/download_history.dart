import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/download_model.dart';
import '../providers/download_provider.dart';

class DownloadHistory extends StatelessWidget {
  final List<DownloadModel> downloads;

  const DownloadHistory({super.key, required this.downloads});

  @override
  Widget build(BuildContext context) {
    if (downloads.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No download history',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Your completed downloads will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Download History (${downloads.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton.icon(
                onPressed: () => _clearHistory(context),
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear All'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: downloads.length,
            itemBuilder: (context, index) {
              final download = downloads[index];
              return _buildHistoryItem(context, download);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(BuildContext context, DownloadModel download) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: _buildStatusIcon(download.status),
        title: Text(
          'Download ${download.downloadId.substring(0, 8)}...',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(download.message),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: download.progress / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStatusColor(download.status),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDetailRow('Status', download.status.toUpperCase()),
                _buildDetailRow(
                  'Progress',
                  '${download.progress.toStringAsFixed(1)}%',
                ),
                _buildDetailRow('Download ID', download.downloadId),
                if (download.error != null)
                  _buildDetailRow('Error', download.error!, isError: true),
                if (download.files != null && download.files!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Downloaded Files:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...download.files!.map(
                    (file) => _buildFileItem(context, file),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (download.status == 'completed')
                      ElevatedButton.icon(
                        onPressed:
                            () => _loadFiles(context, download.downloadId),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Files'),
                      ),
                    OutlinedButton.icon(
                      onPressed: () => _removeFromHistory(context, download),
                      icon: const Icon(Icons.delete),
                      label: const Text('Remove'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData icon;
    Color color;

    switch (status) {
      case 'downloading':
      case 'started':
        icon = Icons.download;
        color = Colors.blue;
        break;
      case 'completed':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'error':
        icon = Icons.error;
        color = Colors.red;
        break;
      default:
        icon = Icons.help;
        color = Colors.grey;
    }

    return Icon(icon, color: color);
  }

  Color _getStatusColor(String status) {
    switch (status) {
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

  Widget _buildDetailRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: isError ? Colors.red : null),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(BuildContext context, DownloadedFile file) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.video_file, size: 20),
        title: Text(file.name, style: const TextStyle(fontSize: 12)),
        subtitle: Text(
          file.formattedSize,
          style: const TextStyle(fontSize: 10),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new, size: 16),
          onPressed: () => _openFile(file),
        ),
      ),
    );
  }

  void _clearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear History'),
          content: const Text(
            'Are you sure you want to clear all download history?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final provider = Provider.of<DownloadProvider>(
                  context,
                  listen: false,
                );
                provider.clearDownloadHistory();
                Navigator.of(context).pop();
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _removeFromHistory(BuildContext context, DownloadModel download) {
    // This would remove a specific download from history
    // For now, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Remove individual items feature coming soon'),
      ),
    );
  }

  void _loadFiles(BuildContext context, String downloadId) {
    final provider = Provider.of<DownloadProvider>(context, listen: false);
    provider.loadDownloadedFiles(downloadId);
  }

  void _openFile(DownloadedFile file) {
    // This would open the file using url_launcher
    // launch(file.url);
  }
}
