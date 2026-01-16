import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:futter_portfileo_website/screens/admin/auth/login_screen.dart';
import 'firebase_options.dart';
import 'config/theme.dart';
import 'screens/public/home_screen.dart';
import 'providers/portfolio_provider.dart';
import 'package:provider/provider.dart';
import 'providers/admin_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase Initialize
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
        ),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'Saidur- Flutter Developer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme(),
        home: const LoginScreen(), //HomeScreen //LoginScreen
      ),
    );
  }
}
