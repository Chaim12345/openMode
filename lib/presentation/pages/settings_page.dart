import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../../core/constants/app_constants.dart';
import 'server_settings_page.dart';

/// Enhanced settings page with multiple sections
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Server Settings Section
          _buildSectionHeader('Server'),
          ListTile(
            leading: const Icon(Icons.cloud),
            title: const Text('Server Configuration'),
            subtitle: const Text('Host, port, authentication'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ServerSettingsPage(),
                ),
              );
            },
          ),
          const Divider(),
          
          // Appearance Section
          _buildSectionHeader('Appearance'),
          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.brightness_6),
                    title: const Text('Theme'),
                    subtitle: Text(_getThemeName(appProvider.themeMode)),
                    trailing: DropdownButton<ThemeMode>(
                      value: appProvider.themeMode,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('System'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Light'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Dark'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          appProvider.setThemeMode(value);
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          const Divider(),
          
          // About Section
          _buildSectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('OpenMode'),
            subtitle: const Text('Mobile App for OpenCode'),
          ),
          const Divider(),
          
          // Advanced Section
          _buildSectionHeader('Advanced'),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear Cache'),
            subtitle: const Text('Clear local cached data'),
            onTap: () {
              _showConfirmDialog(
                'Clear Cache',
                'Are you sure you want to clear all cached data?',
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cache cleared')),
                  );
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Reset to Defaults'),
            subtitle: const Text('Restore all settings to default'),
            onTap: () {
              _showConfirmDialog(
                'Reset Settings',
                'Are you sure you want to reset all settings to default?',
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings reset')),
                  );
                },
              );
            },
          ),
          const Divider(),
          
          // Connection Status
          _buildSectionHeader('Connection'),
          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              return ListTile(
                leading: Icon(
                  appProvider.isConnected
                      ? Icons.cloud_done
                      : Icons.cloud_off,
                  color: appProvider.isConnected ? Colors.green : Colors.red,
                ),
                title: Text(
                  appProvider.isConnected ? 'Connected' : 'Disconnected',
                ),
                subtitle: Text('${appProvider.serverHost}:${appProvider.serverPort}'),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () async {
                    await appProvider.checkConnection();
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showConfirmDialog(String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
