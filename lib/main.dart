import 'package:flutter/material.dart';
import 'screens/signUp.dart';
import 'screens/signIn.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flowery',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      // Начальный экран
      home: const SignUpScreen(),

      // Маршруты для навигации
      routes: {
        '/signup': (context) => const SignUpScreen(),
        '/signin': (context) => const SignInScreen(),
      },
    );
  }
}