import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/download_provider.dart';
import '../models/download_model.dart';

class DownloadProgressWidget extends StatelessWidget {
  const DownloadProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadProvider>(
      builder: (context, provider, child) {
        final download = provider.currentDownload;

        if (download == null) {
          return const SizedBox.shrink();
        }

        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status
                Row(
                  children: [
                    _getStatusIcon(download.status),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getStatusTitle(download.status),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (_canShowControls(download.status))
                      _buildControlButtons(context, provider, download),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress bar
                LinearProgressIndicator(
                  value: download.progress / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(download.status),
                  ),
                ),

                const SizedBox(height: 8),

                // Progress percentage
                Text(
                  '${download.progress.toStringAsFixed(1)}%',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 8),

                // Status message
                Text(
                  download.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                // Download statistics
                if (_shouldShowStats(download))
                  _buildDownloadStats(context, download),

                // Error message
                if (download.error != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red[600], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            download.error!,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDownloadStats(BuildContext context, DownloadModel download) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Speed',
                  download.speed ?? 'N/A',
                  Icons.speed,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  'ETA',
                  download.eta ?? 'N/A',
                  Icons.schedule,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Elapsed',
                  download.elapsed ?? 'N/A',
                  Icons.timer,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Status',
                  _getStatusDisplayName(download.status),
                  Icons.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButtons(
    BuildContext context,
    DownloadProvider provider,
    DownloadModel download,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (download.status == 'downloading' || download.status == 'started')
          IconButton(
            onPressed: () => provider.pauseDownload(),
            icon: const Icon(Icons.pause),
            tooltip: 'Pause Download',
            iconSize: 20,
          ),

        if (download.status == 'paused')
          IconButton(
            onPressed: () => provider.resumeDownload(),
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Resume Download',
            iconSize: 20,
          ),

        if (download.status == 'downloading' ||
            download.status == 'started' ||
            download.status == 'paused')
          IconButton(
            onPressed: () => _showStopConfirmation(context, provider),
            icon: const Icon(Icons.stop),
            tooltip: 'Stop Download',
            iconSize: 20,
          ),
      ],
    );
  }

  void _showStopConfirmation(BuildContext context, DownloadProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Stop Download'),
          content: const Text(
            'Are you sure you want to stop this download? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                provider.stopDownload();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Stop'),
            ),
          ],
        );
      },
    );
  }

  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'downloading':
      case 'started':
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case 'processing':
        return const Icon(Icons.settings, color: Colors.orange, size: 20);
      case 'completed':
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      case 'error':
        return const Icon(Icons.error, color: Colors.red, size: 20);
      case 'paused':
        return const Icon(Icons.pause_circle, color: Colors.orange, size: 20);
      case 'stopped':
        return const Icon(Icons.stop_circle, color: Colors.grey, size: 20);
      default:
        return const Icon(Icons.info, color: Colors.blue, size: 20);
    }
  }

  String _getStatusTitle(String status) {
    switch (status) {
      case 'downloading':
      case 'started':
        return 'Downloading';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'error':
        return 'Error';
      case 'paused':
        return 'Paused';
      case 'stopped':
        return 'Stopped';
      default:
        return 'Unknown';
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'downloading':
      case 'started':
        return 'Downloading';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'error':
        return 'Error';
      case 'paused':
        return 'Paused';
      case 'stopped':
        return 'Stopped';
      default:
        return status;
    }
  }

  Color _getProgressColor(String status) {
    switch (status) {
      case 'downloading':
      case 'started':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'error':
        return Colors.red;
      case 'paused':
        return Colors.orange;
      case 'stopped':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  bool _canShowControls(String status) {
    return ['downloading', 'started', 'paused', 'processing'].contains(status);
  }

  bool _shouldShowStats(DownloadModel download) {
    return [
          'downloading',
          'started',
          'paused',
          'processing',
        ].contains(download.status) &&
        (download.speed != null ||
            download.eta != null ||
            download.elapsed != null);
  }
}
