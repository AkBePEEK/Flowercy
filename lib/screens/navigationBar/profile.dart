import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../services/userService.dart';
import '../orderScreens/myOrder.dart';
import '../../models/user.dart'; // Ваша модель
import '../savedAddresses.dart';
import '../signIn.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  // ✅ Состояния для данных пользователя
  firebase_auth.User? _authUser;           // Пользователь из Firebase Auth
  User? _firestoreUser;      // Дополнительные данные из Firestore
  bool _isLoading = true;    // Индикатор загрузки
  String? _error;            // Ошибка загрузки

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ✅ Загрузка данных пользователя
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. Получаем пользователя из Auth
      final authUser = firebase_auth.FirebaseAuth.instance.currentUser;

      if (authUser == null) {
        // Если не авторизован — переходим на вход
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
          );
        }
        return;
      }

      // 2. Получаем дополнительные данные из Firestore
      final userService = UserService();
      final firestoreUser = await userService.getCurrentUser();

      setState(() {
        _authUser = authUser;
        _firestoreUser = firestoreUser;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load profile';
        _isLoading = false;
      });
      print('❌ Error loading user data: $e');
    }
  }

  // ✅ Выход из аккаунта
  Future<void> _handleSignOut() async {
    try {
      // 1. Показываем индикатор загрузки
      setState(() => _isLoading = true);

      // 2. Выход из Firebase Auth
      await firebase_auth.FirebaseAuth.instance.signOut();

      // 3. Переход на экран входа
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to sign out. Please try again.');
      print('❌ Error signing out: $e');
    }
  }

  // ✅ Показать ошибку
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadUserData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
                  : SingleChildScrollView(
                child: Column(
                  children: [
                    // Header с профилем
                    _buildProfileHeader(),
                    const SizedBox(height: 16),

                    // Меню
                    _buildMenuSection(),
                    const SizedBox(height: 24),

                    // Кнопка Sign out
                    _buildSignOutButton(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Header с профилем (динамические данные)
  Widget _buildProfileHeader() {
    // Получаем имя: из Firestore > из Auth email > заглушка
    final displayName = _firestoreUser?.name ??
        _authUser?.email?.split('@').first ??
        'User';

// Получаем email
    final email = _authUser?.email ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          // Аватар (с заглушкой или URL из Firestore)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
              // ✅ Если есть аватар — показываем изображение
              image: _firestoreUser?.avatarUrl != null
                  ? DecorationImage(
                image: NetworkImage(_firestoreUser!.avatarUrl!),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: _firestoreUser?.avatarUrl == null
                ? const Icon(Icons.person, size: 35, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          // Имя и настройки
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // ✅ Показываем email если нет имени в Firestore
                    Text(
                      email.isNotEmpty ? email : 'Settings',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Меню
  Widget _buildMenuSection() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildMenuItem(
            'My orders',
            hasArrow: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyOrdersScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 16),
          _buildMenuItem(
            'Notifications',
            trailing: Transform.scale(
              scale: 0.8,
              child: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  // 🔹 Здесь можно сохранить настройку в Firestore
                },
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFFB07183),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey[300],
              ),
            ),
          ),
          const Divider(height: 1, indent: 16),
          _buildMenuItem(
            'Language',
            trailing: const Text('EN'),
            onTap: () {
              // 🔹 Открыть выбор языка
              _showLanguageSelector();
            },
          ),
          const Divider(height: 1, indent: 16),
          _buildMenuItem(
            'Saved addresses',
            hasArrow: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedAddressesScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 16),
          _buildMenuItem(
            'About us',
            hasArrow: true,
            onTap: () {
              // 🔹 Показать информацию о приложении
              _showAboutDialog();
            },
          ),
        ],
      ),
    );
  }

  // ✅ Выбор языка (заглушка)
  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Language',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('English'),
              trailing: const Text('EN') == const Text('EN')
                  ? const Icon(Icons.check, color: Color(0xFFB07183))
                  : null,
              onTap: () {
                Navigator.pop(context);
                // 🔹 Сохранить выбор языка
              },
            ),
            ListTile(
              title: const Text('Русский'),
              trailing: const Text('EN') != const Text('RU')
                  ? null
                  : const Icon(Icons.check, color: Color(0xFFB07183)),
              onTap: () {
                Navigator.pop(context);
                // 🔹 Сохранить выбор языка
              },
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Диалог "О приложении" (заглушка)
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Flowery App',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.local_florist, color: Color(0xFFB07183)),
      children: [
        const Text(
          'Your favorite flower delivery app. Made with ❤️ in Astana.',
        ),
      ],
    );
  }

  // Элемент меню
  Widget _buildMenuItem(
      String title, {
        bool hasArrow = false,
        Widget? trailing,
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (trailing != null)
              trailing
            else if (hasArrow)
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }

  // ✅ Кнопка Sign out (с подтверждением)
  Widget _buildSignOutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: _isLoading ? null : _handleSignOut,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text(
            'Sign out',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Color(0xFFFE0202),
            ),
          ),
        ),
      ),
    );
  }
}