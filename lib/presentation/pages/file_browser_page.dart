import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/app_provider.dart';
import '../../domain/entities/file_info.dart';
import '../../core/constants/api_constants.dart';
import 'code_viewer_page.dart';
import 'file_search_page.dart';
import 'chat_page.dart';

/// File browser page for navigating directory tree
class FileBrowserPage extends StatefulWidget {
  const FileBrowserPage({super.key});

  @override
  State<FileBrowserPage> createState() => _FileBrowserPageState();
}

class _FileBrowserPageState extends State<FileBrowserPage> {
  List<FileInfo> _files = [];
  String _currentPath = '/';
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFiles('/');
  }

  Future<void> _loadFiles(String path) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final appProvider = context.read<AppProvider>();
      final url = '${appProvider.serverUrl}${ApiConstants.fileEndpoint}';
      
      final response = await http.get(
        Uri.parse('$url?path=$path'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final files = (data['files'] as List?)?.map((f) => _parseFileInfo(f)).toList() ?? [];
        setState(() {
          _files = files;
          _currentPath = path;
        });
      } else {
        setState(() {
          _error = 'Failed to load files: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
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

  void _navigateTo(String path) {
    _loadFiles(path);
  }

  void _navigateUp() {
    if (_currentPath != '/') {
      final parent = _currentPath.substring(0, _currentPath.lastIndexOf('/'));
      _loadFiles(parent.isEmpty ? '/' : parent);
    }
  }

  void _attachFileToChat(FileInfo file) {
    // Navigate to chat page with file attachment
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          initialAttachment: file,
        ),
      ),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Attached: ${file.name}')),
    );
  }

  void _showFileOptions(FileInfo file) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View File'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CodeViewerPage(
                      filePath: file.path,
                      fileName: file.name,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Attach to Chat'),
              onTap: () {
                Navigator.pop(context);
                _attachFileToChat(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('Copy Path'),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: file.path));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Path copied to clipboard')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Files'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FileSearchPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadFiles(_currentPath),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _loadFiles(_currentPath),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildFileList(),
    );
  }

  Widget _buildFileList() {
    return Column(
      children: [
        // Path breadcrumb
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              if (_currentPath != '/')
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: _navigateUp,
                ),
              Expanded(
                child: Text(
                  _currentPath,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // File list
        Expanded(
          child: _files.isEmpty
              ? const Center(child: Text('No files'))
              : ListView.builder(
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    final file = _files[index];
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
                      subtitle: file.size != null
                          ? Text(_formatSize(file.size!))
                          : null,
                      trailing: !file.isDirectory
                          ? IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () => _showFileOptions(file),
                            )
                          : null,
                      onTap: () {
                        if (file.isDirectory) {
                          _navigateTo(file.path);
                        } else {
                          _showFileOptions(file);
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${bytes ~/ 1024} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
