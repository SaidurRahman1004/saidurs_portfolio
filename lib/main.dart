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
import 'package:flutter/foundation.dart';
import 'services/analytics/analytics_service.dart';
import 'services/crashlytics/crashlytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure Flutter framework error capture (widget render pipeline)
  FlutterError.onError = (FlutterErrorDetails details) {
    CrashlyticsService.instance.recordFlutterError(details, fatal: true);
    FlutterError.presentError(details);
  };

  // Configure unhandled asynchronous platform error capture
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    // Gracefully ignore Flutter Web CanvasKit context-loss hot-restart artifact
    if (error.toString().contains('_handledContextLostEvent')) {
      return true;
    }
    CrashlyticsService.instance.recordError(
      error,
      stack,
      fatal: true,
      reason: 'Unhandled asynchronous platform error',
    );
    return true;
  };

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
    // Safely initialize Analytics without blocking startup or crashing on error
    await AnalyticsService.instance.initialize();
    // Safely initialize Crashlytics without blocking startup or crashing on error
    await CrashlyticsService.instance.initialize();
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
    if (!isFirebaseInitialized) {
      return MaterialApp(
        title: 'Saidur - Portfolio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme(),
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 56, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text(
                    'Unable to connect to cloud services.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please check your internet connection and refresh the page.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final observer = AnalyticsService.instance.navigatorObserver;

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
              navigatorObservers: [
                if (observer != null) observer,
              ],
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
