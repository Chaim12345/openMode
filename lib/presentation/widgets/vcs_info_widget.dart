import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// VCS/Git info display widget
class VcsInfoWidget extends StatefulWidget {
  const VcsInfoWidget({Key? key}) : super(key: key);

  @override
  State<VcsInfoWidget> createState() => _VcsInfoWidgetState();
}

class _VcsInfoWidgetState extends State<VcsInfoWidget> {
  String? _branch;
  String? _status;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVcsInfo();
  }

  Future<void> _loadVcsInfo() async {
    setState(() => _isLoading = true);

    try {
      final appProvider = context.read<AppProvider>();
      final response = await http.get(
        Uri.parse('${appProvider.serverUrl}/vcs'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _branch = data['branch'] ?? data['current_branch'];
          _status = data['status'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (_branch == null && _status == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.source, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          if (_branch != null)
            Text(
              _branch!,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          if (_branch != null && _status != null)
            const SizedBox(width: 8),
          if (_status != null)
            Text(
              _status!,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
        ],
      ),
    );
  }
}
