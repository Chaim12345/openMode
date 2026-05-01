import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/app_provider.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/file_info.dart';
import 'code_viewer_page.dart';

/// File search page - search by filename or text pattern
class FileSearchPage extends StatefulWidget {
  const FileSearchPage({Key? key}) : super(key: key);

  @override
  State<FileSearchPage> createState() => _FileSearchPageState();
}

enum SearchType { filename, text }

class _FileSearchPageState extends State<FileSearchPage> {
  final TextEditingController _controller = TextEditingController();
  SearchType _searchType = SearchType.filename;
  List<FileInfo> _results = [];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _results = [];
    });

    try {
      final appProvider = context.read<AppProvider>();
      final queryType = _searchType == SearchType.filename ? 'file' : 'pattern';
      final url = '${appProvider.serverUrl}${ApiConstants.findEndpoint}';
      
      final response = await http.get(
        Uri.parse('$url?$queryType=${Uri.encodeComponent(_controller.text)}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final files = (data['files'] as List?)?.map((f) => _parseFileInfo(f)).toList() ?? [];
        setState(() {
          _results = files;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Search failed: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  FileInfo _parseFileInfo(Map<String, dynamic> data) {
    return FileInfo(
      name: data['name'] ?? '',
      path: data['path'] ?? '',
      isDirectory: data['is_directory'] ?? false,
      size: data['size'],
      modified: data['modified'] != null 
          ? DateTime.tryParse(data['modified'].toString()) 
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Files'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search type selector
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<SearchType>(
                        segments: const [
                          ButtonSegment(
                            value: SearchType.filename,
                            label: Text('Filename'),
                            icon: Icon(Icons.file_present),
                          ),
                          ButtonSegment(
                            value: SearchType.text,
                            label: Text('Text'),
                            icon: Icon(Icons.search),
                          ),
                        ],
                        selected: {_searchType},
                        onSelectionChanged: (selected) {
                          setState(() => _searchType = selected.first);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: _searchType == SearchType.filename
                              ? 'Search by filename...'
                              : 'Search text pattern...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _performSearch(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _performSearch,
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                            const SizedBox(height: 16),
                            Text(_error!),
                          ],
                        ),
                      )
                    : _results.isEmpty
                        ? const Center(child: Text('No results found'))
                        : ListView.builder(
                            itemCount: _results.length,
                            itemBuilder: (context, index) {
                              final file = _results[index];
                              return ListTile(
                                leading: Icon(
                                  file.isDirectory
                                      ? Icons.folder
                                      : Icons.insert_drive_file,
                                  color: file.isDirectory
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                                title: Text(file.name),
                                subtitle: Text(file.path),
                                trailing: file.size != null
                                    ? Text(_formatSize(file.size!))
                                    : null,
                                onTap: () {
                                  if (!file.isDirectory) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CodeViewerPage(
                                          filePath: file.path,
                                          fileName: file.name,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${bytes ~/ 1024} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
