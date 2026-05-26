import 'package:flowery_app/router/app_router.dart';
import 'package:flowery_app/services/language_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GoogleSignIn.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLanguageProvider(
        builder: (languageCode) {
          return MaterialApp.router(
            title: 'Flowery',
            locale: Locale(languageCode),
            supportedLocales: const [
              Locale('en'),
              Locale('ru'),
              Locale('kz'),
            ],
            theme: ThemeData(
              primarySwatch: Colors.pink,
              useMaterial3: true,
            ),
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        });
  }
}