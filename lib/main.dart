import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/theme.dart';
import 'screens/public/home_screen.dart';
import 'providers/portfolio_provider.dart';
import 'package:provider/provider.dart';

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
    return ChangeNotifierProvider(
      create: (context) {
        final provider = PortfolioProvider();
        provider.loadAllData(); //Provider data initial load
        return provider;
      },
      child: MaterialApp(
        title: 'Saidur Rahman - Flutter Developer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme(),
        home: HomeScreen(),
      ),
    );
  }
}
