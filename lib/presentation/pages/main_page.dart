import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/project_provider.dart';
import 'chat_page.dart';
import 'settings_page.dart';
import 'server_settings_page.dart';
import 'file_browser_page.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/injection_container.dart';

/// Main page with bottom navigation
class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Pages to preserve state using IndexedStack
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ChangeNotifierProvider(
        create: (_) => sl<ChatProvider>(),
        child: const ChatPage(),
      ),
      const FileBrowserPage(),
      const SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            // activeIcon removed - not supported in this Flutter version
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            // activeIcon removed - not supported in this Flutter version
            label: 'Files',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            // activeIcon removed - not supported in this Flutter version
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
