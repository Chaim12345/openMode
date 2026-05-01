import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/injection_container.dart' as di;
import 'presentation/theme/app_theme.dart';
import 'presentation/providers/app_provider.dart';
import 'presentation/providers/project_provider.dart';
import 'presentation/pages/main_page.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await di.init();
  
  // Load saved theme mode
  final appProvider = di.sl<AppProvider>();
  await appProvider.loadThemeMode();
  
  runApp(MyApp(appProvider: appProvider));
}

class MyApp extends StatelessWidget {
  final AppProvider appProvider;
  
  const MyApp({super.key, required this.appProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appProvider),
        ChangeNotifierProvider(create: (_) => di.sl<ProjectProvider>()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.themeMode,
            home: const MainPage(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
