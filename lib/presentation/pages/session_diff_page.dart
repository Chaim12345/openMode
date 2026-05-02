import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/app_provider.dart';

/// Session diff viewer - shows file changes
class SessionDiffPage extends StatefulWidget {
  final String sessionId;
  final String? messageId;

  const SessionDiffPage({
    super.key,
    required this.sessionId,
    this.messageId,
  });

  @override
  State<SessionDiffPage> createState() => _SessionDiffPageState();
}

class FileDiff {
  final String filename;
  final String before;
  final String after;

  const FileDiff({
    required this.filename,
    required this.before,
    required this.after,
  });
}

class _SessionDiffPageState extends State<SessionDiffPage> {
  List<FileDiff> _diffs = [];
  bool _isLoading = true;
  String? _error;
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _loadDiff();
  }

  Future<void> _loadDiff() async {
    setState(() => _isLoading = true);

    try {
      final appProvider = context.read<AppProvider>();
      final url = '${appProvider.serverUrl}/session/${widget.sessionId}/diff';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final diffs = (data['diffs'] as List?)?.map((d) => FileDiff(
          filename: d['filename'] ?? '',
          before: d['before'] ?? '',
          after: d['after'] ?? '',
        )).toList() ?? [];
        setState(() {
          _diffs = diffs;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load diff: ${response.statusCode}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Diff'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDiff,
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
                        onPressed: _loadDiff,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Filter bar
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Filter by filename...',
                          prefixIcon: Icon(Icons.filter_list),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => setState(() => _filter = value),
                      ),
                    ),
                    // Diff list
                    Expanded(
                      child: _diffs.isEmpty
                          ? const Center(child: Text('No changes'))
                          : ListView.builder(
                              itemCount: _diffs.length,
                              itemBuilder: (context, index) {
                                final diff = _diffs[index];
                                if (_filter.isNotEmpty && 
                                    !diff.filename.contains(_filter)) {
                                  return const SizedBox.shrink();
                                }
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: ExpansionTile(
                                    title: Text(diff.filename),
                                    children: [
                                      _buildDiffView(diff),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildDiffView(FileDiff diff) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Before:', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          color: Colors.red.shade50,
          child: SelectableText(
            diff.before,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('After:', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          color: Colors.green.shade50,
          child: SelectableText(
            diff.after,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }
}
