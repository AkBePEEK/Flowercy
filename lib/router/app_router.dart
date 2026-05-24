import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/mainScreen.dart';
import '../screens/authorizationScreens/signUp.dart';
import '../screens/authorizationScreens/signIn.dart';
import '../screens/authorizationScreens/signUpEmail.dart';

// 🔹 Имена маршрутов
abstract class AppRoute {
  static const String signIn = '/';              // ← Корневой путь = Вход
  static const String signUp = '/sign-up';       // Регистрация
  static const String signUpEmail = '/sign-up/email';
  static const String main = '/home';            // ← Главная (после входа)
}

// 🔹 Конфигурация роутера с защитой маршрутов
final GoRouter router = GoRouter(
  initialLocation: AppRoute.signIn,  // ← Начинаем с входа

  // ✅ refreshListenable обновляет роутер когда меняется auth состояние
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),

  // 🔐 Проверка авторизации перед каждым переходом
  redirect: (context, state) {
    // ✅ currentUser теперь актуален — Firebase уже обновил состояние
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    print('🔀 redirect вызван: isLoggedIn=$isLoggedIn, path=${state.matchedLocation}');
    final isAuthRoute =
        state.matchedLocation == AppRoute.signIn ||
            state.matchedLocation == AppRoute.signUp ||
            state.matchedLocation == AppRoute.signUpEmail;

    if (!isLoggedIn && !isAuthRoute) return AppRoute.signIn;
    if (isLoggedIn && isAuthRoute)   return AppRoute.main;
    return null;
  },

  routes: [
    // 🔹 Вход (корневой путь)
    GoRoute(
      path: AppRoute.signIn,
      name: AppRoute.signIn,
      builder: (context, state) => const SignInScreen(),
    ),

    // 🔹 Регистрация (основная)
    GoRoute(
      path: AppRoute.signUp,
      name: AppRoute.signUp,
      builder: (context, state) => const SignUpScreen(),
    ),

    // 🔹 Регистрация через Email
    GoRoute(
      path: AppRoute.signUpEmail,
      name: AppRoute.signUpEmail,
      builder: (context, state) => const SignUpEmailScreen(),
    ),

    // 🔹 Главная (после авторизации)
    GoRoute(
      path: AppRoute.main,
      name: AppRoute.main,
      builder: (context, state) => const MainScreen(),
    ),
  ],
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}