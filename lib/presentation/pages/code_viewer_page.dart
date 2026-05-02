import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/app_provider.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_constants.dart';

/// Code viewer page with syntax highlighting
class CodeViewerPage extends StatefulWidget {
  final String filePath;
  final String fileName;

  const CodeViewerPage({
    super.key,
    required this.filePath,
    required this.fileName,
  });

  @override
  State<CodeViewerPage> createState() => _CodeViewerPageState();
}

class _CodeViewerPageState extends State<CodeViewerPage> {
  String _content = '';
  bool _isLoading = true;
  String? _error;
  int _lineCount = 1;

  @override
  void initState() {
    super.initState();
    _loadFileContent();
  }

  Future<void> _loadFileContent() async {
    setState(() => _isLoading = true);

    try {
      final appProvider = context.read<AppProvider>();
      final url = '${appProvider.serverUrl}${ApiConstants.fileEndpoint}';
      
      final response = await http.get(
        Uri.parse('$url?path=${widget.filePath}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['content'] ?? '';
        setState(() {
          _content = content;
          _lineCount = content.split('\n').length;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load file: ${response.statusCode}';
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

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Content copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy',
            onPressed: _copyToClipboard,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: _loadFileContent,
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
                        onPressed: _loadFileContent,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildCodeView(),
    );
  }

  Widget _buildCodeView() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Line numbers
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: ListView.builder(
              itemCount: _lineCount,
              itemBuilder: (context, index) {
                return Text(
                  '${index + 1}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.right,
                );
              },
            ),
          ),
          // Code content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                _content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
