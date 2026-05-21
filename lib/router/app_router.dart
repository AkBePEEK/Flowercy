import 'package:go_router/go_router.dart';
import '../screens/mainScreen.dart';
import '../screens/authorizationScreens/signUp.dart';
import '../screens/authorizationScreens/signIn.dart';
import '../screens/authorizationScreens/signUpEmail.dart';
import '../services/auth_service.dart';

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

  // 🔐 Проверка авторизации перед каждым переходом
  redirect: (context, state) {
    final isLoggedIn = AuthService().getCurrentUser() != null;
    final isAuthRoute = state.matchedLocation == AppRoute.signIn ||
        state.matchedLocation == AppRoute.signUp ||
        state.matchedLocation == AppRoute.signUpEmail;

    // Если не авторизован и пытается зайти на защищённый маршрут
    if (!isLoggedIn && !isAuthRoute) {
      return AppRoute.signIn;  // ← Перенаправить на вход
    }

    // Если авторизован и пытается зайти на вход/регистрацию
    if (isLoggedIn && isAuthRoute) {
      return AppRoute.main;  // ← Перенаправить на главную
    }

    return null;  // Разрешить навигацию
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