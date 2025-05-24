import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/download_provider.dart';
import '../models/download_model.dart';

class DownloadForm extends StatefulWidget {
  const DownloadForm({super.key});

  @override
  State<DownloadForm> createState() => _DownloadFormState();
}

class _DownloadFormState extends State<DownloadForm> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  String _selectedFormat = 'mp4';
  String _selectedQuality = 'best';
  bool _isLoading = false;
  bool _isLoadingQualities = false;
  List<VideoQuality> _availableQualities = [
    VideoQuality(
      value: 'best',
      label: 'Best Quality',
      description: 'Highest available',
    ),
    VideoQuality(value: '1080p', label: '1080p', description: 'Full HD'),
    VideoQuality(value: '720p', label: '720p', description: 'HD'),
    VideoQuality(value: '480p', label: '480p', description: 'Standard'),
    VideoQuality(value: '360p', label: '360p', description: 'Low'),
    VideoQuality(
      value: 'worst',
      label: 'Worst Quality',
      description: 'Smallest file',
    ),
  ];

  final List<String> _formats = ['mp4', 'mkv'];

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Download YouTube Video',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'YouTube URL',
                  hintText: 'https://youtube.com/watch?v=...',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a YouTube URL';
                  }
                  if (!_isValidYouTubeUrl(value)) {
                    return 'Please enter a valid YouTube URL';
                  }
                  return null;
                },
                maxLines: 2,
                minLines: 1,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedFormat,
                decoration: const InputDecoration(
                  labelText: 'Video Format',
                  prefixIcon: Icon(Icons.video_file),
                  border: OutlineInputBorder(),
                ),
                items:
                    _formats.map((format) {
                      return DropdownMenuItem(
                        value: format,
                        child: Text(format.toUpperCase()),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFormat = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedQuality,
                      decoration: const InputDecoration(
                        labelText: 'Video Quality',
                        prefixIcon: Icon(Icons.high_quality),
                        border: OutlineInputBorder(),
                      ),
                      items:
                          _availableQualities.map((quality) {
                            return DropdownMenuItem(
                              value: quality.value,
                              child: Text(
                                '${quality.label} - ${quality.description}',
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedQuality = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isLoadingQualities ? null : _loadVideoQualities,
                    icon:
                        _isLoadingQualities
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.refresh),
                    tooltip: 'Load available qualities',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Consumer<DownloadProvider>(
                builder: (context, provider, child) {
                  final isDownloading =
                      provider.currentDownload != null &&
                      (provider.currentDownload!.status == 'downloading' ||
                          provider.currentDownload!.status == 'started');

                  return ElevatedButton.icon(
                    onPressed:
                        (_isLoading ||
                                isDownloading ||
                                !provider.isServerConnected)
                            ? null
                            : _startDownload,
                    icon:
                        _isLoading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.download),
                    label: Text(_getButtonText(provider, isDownloading)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Consumer<DownloadProvider>(
                builder: (context, provider, child) {
                  if (!provider.isServerConnected) {
                    return const Text(
                      'Server is not connected. Please check your backend server.',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.center,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getButtonText(DownloadProvider provider, bool isDownloading) {
    if (_isLoading) return 'Starting...';
    if (isDownloading) return 'Downloading...';
    if (!provider.isServerConnected) return 'Server Offline';
    return 'Start Download';
  }

  bool _isValidYouTubeUrl(String url) {
    final youtubeRegex = RegExp(
      r'^(https?://)?(www\.)?(youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/|youtube\.com/v/)',
      caseSensitive: false,
    );
    return youtubeRegex.hasMatch(url);
  }

  Future<void> _startDownload() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<DownloadProvider>(context, listen: false);
    final success = await provider.startDownload(
      _urlController.text.trim(),
      _selectedFormat,
      _selectedQuality,
    );

    setState(() {
      _isLoading = false;
    });

    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to start download. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Clear the URL field after successful start
      _urlController.clear();
    }
  }

  Future<void> _loadVideoQualities() async {
    final url = _urlController.text.trim();
    if (url.isEmpty || !_isValidYouTubeUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid YouTube URL first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoadingQualities = true;
    });

    try {
      final provider = Provider.of<DownloadProvider>(context, listen: false);
      final qualities = await provider.getVideoQualities(url);

      if (qualities != null && qualities.isNotEmpty) {
        setState(() {
          _availableQualities = qualities;
          // Reset to best quality if current selection is not available
          if (!qualities.any((q) => q.value == _selectedQuality)) {
            _selectedQuality = 'best';
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Found ${qualities.length} available qualities'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not load video qualities. Using default options.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading qualities: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingQualities = false;
      });
    }
  }
}
