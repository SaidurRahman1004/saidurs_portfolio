import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:futter_portfileo_website/screens/public/home_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [

    ],
      child: MaterialApp(
        title: 'Saidur Rahman - Flutter Developer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: HomeScreen(),
      ),
    );
  }
}
