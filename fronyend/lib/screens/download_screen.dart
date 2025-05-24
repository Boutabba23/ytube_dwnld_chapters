import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/download_provider.dart';
import '../widgets/download_form.dart';
import '../widgets/download_progress_widget.dart';
import '../widgets/download_history.dart';
import '../widgets/server_status.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Chapter Downloader'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.download), text: 'Download'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        ),
        actions: [
          Consumer<DownloadProvider>(
            builder: (context, provider, child) {
              return ServerStatus(isConnected: provider.isServerConnected);
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildDownloadTab(), _buildHistoryTab()],
      ),
    );
  }

  Widget _buildDownloadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DownloadForm(),
          const SizedBox(height: 20),
          const DownloadProgressWidget(),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<DownloadProvider>(
      builder: (context, provider, child) {
        return DownloadHistory(downloads: provider.downloadHistory);
      },
    );
  }
}
