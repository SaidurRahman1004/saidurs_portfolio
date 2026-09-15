import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:futter_portfileo_website/screens/admin/auth/login_screen.dart';
import 'package:futter_portfileo_website/screens/admin/dashboard/admin_layout.dart';
import 'package:futter_portfileo_website/screens/public/home_screen.dart';
import 'package:futter_portfileo_website/widgets/admin/auth_guard.dart';
import 'package:futter_portfileo_website/widgets/comon/error_boundary.dart';
import 'firebase_options.dart';
import 'config/theme.dart';
import 'providers/portfolio_provider.dart';
import 'providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'providers/admin_provider.dart';
import 'config/env.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Url Strategy Clean Url
  usePathUrlStrategy();

  //Env
  Env.validateConfig();

  // Firebase Initialize
  bool isFirebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    isFirebaseInitialized = true;
  } catch (error) {
    debugPrint('Firebase init error: $error');
  }

  runApp(MyApp(isFirebaseInitialized: isFirebaseInitialized));
}

class MyApp extends StatelessWidget {
  final bool isFirebaseInitialized;

  const MyApp({super.key, required this.isFirebaseInitialized});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = PortfolioProvider();
            provider.loadAllData();
            return provider;
          },
          lazy: false,
        ),
        ChangeNotifierProvider(create: (_) => AdminProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => ThemeProvider(), lazy: false),
      ],
      child: ErrorBoundary(
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp(
              title: 'Saidur- Flutter Developer',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              themeMode: themeProvider.themeMode,
              initialRoute: '/',
              routes: {
                '/': (context) => const HomeScreen(),
                '/admin/login': (context) => const LoginScreen(),
                '/admin': (context) => const AuthGuard(child: AdminLayout()),
                // Protected by AuthGuard
              },
              onUnknownRoute: (settings) {
                return MaterialPageRoute(builder: (_) => const HomeScreen());
              },
            );
          },
        ),
      ),
    );
  }
}
