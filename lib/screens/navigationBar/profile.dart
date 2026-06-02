import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../main.dart';
import '../../services/language_service.dart';
import '../../services/userService.dart';
import '../admin/adminPanel.dart';
import '../notificationsScreen.dart';
import '../orderScreens/myOrder.dart';
import '../../models/user.dart'; // Ваша модель
import '../aboutUsScreen.dart';
import '../savedAddresses.dart';
import '../authorizationScreens/signIn.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with LanguageStateMixin{

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
    final t = getTranslations();
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
        _error = t('error_load_profile');
        _isLoading = false;
      });
    }
  }

  // ✅ Выход из аккаунта
  Future<void> _handleSignOut() async {
    final t = getTranslations();
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
      _showError(t('error_sign_out'));
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
    final t = getTranslations();
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
                      child: Text(t('retry')),
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
    final t = getTranslations();
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
                      email.isNotEmpty ? email : t('settings'),
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
    final t = getTranslations();
    final bool isAdmin = _firestoreUser?.isAdmin ?? false;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          if (isAdmin)
            _buildMenuItem(
              t('admin_panel'),
              hasArrow: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminPanelScreen(),
                  ),
                );
              },
            ),
          const Divider(height: 1, indent: 16),
          _buildMenuItem(
            t.myOrders,
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
            t('notifications'),
            hasArrow: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
          const Divider(height: 1, indent: 16),
          _buildMenuItem(
            t.language,
            trailing: ValueListenableBuilder<String>(
              valueListenable: appLanguageNotifier,
              builder: (_, code, __) => Text(code.toUpperCase()),
            ),
            onTap: () => _showLanguageSelector(),  // ← вернись к оригинальному методу
          ),
          const Divider(height: 1, indent: 16),
          _buildMenuItem(
            t.savedAddresses,
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
            t('about_us'),
            hasArrow: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutUsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // ✅ Выбор языка — рабочая реализация через AppLanguage
  void _showLanguageSelector() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        barrierDismissible: true,
        pageBuilder: (ctx, _, __) => _LanguageSelectorSheet(
          currentCode: appLanguageNotifier.value,
          onSelect: (code) async {
            await setAppLanguage(code);
            if (mounted) setState(() {});
          },
        ),
      ),
    );
  }

  // ✅ Диалог "О приложении" (заглушка)
  void _showAboutDialog() {
    final t = getTranslations();
    showAboutDialog(
      context: context,
      applicationName: t('app_name'),
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.local_florist, color: Color(0xFFB07183)),
      children: [
        Text(t('about_app_description')),
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
    final t = getTranslations();
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
              : Text(
            t('logout'),
            style: const TextStyle(
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

class _LanguageSelectorSheet extends StatefulWidget {
  final String currentCode;
  final void Function(String) onSelect;

  const _LanguageSelectorSheet({
    required this.currentCode,
    required this.onSelect,
  });

  @override
  State<_LanguageSelectorSheet> createState() => _LanguageSelectorSheetState();
}

class _LanguageSelectorSheetState extends State<_LanguageSelectorSheet> with LanguageStateMixin{
  late String _selected;

  final _languages = const [
    {'code': 'en', 'name': 'English',  'flag': '🇬🇧'},
    {'code': 'ru', 'name': 'Русский',  'flag': '🇷🇺'},
    {'code': 'kk', 'name': 'Қазақша', 'flag': '🇰🇿'},
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.currentCode;
  }

  @override
  Widget build(BuildContext context) {
    final t = getTranslations();
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                t('selectLanguage'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ..._languages.map((lang) {
                final isSelected = _selected == lang['code'];
                return GestureDetector(
                  onTap: () {
                    setState(() => _selected = lang['code']!);
                    widget.onSelect(lang['code']!);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFB07183).withValues(alpha: 0.08)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFB07183)
                            : Colors.grey[200]!,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Text(
                          lang['name']!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? const Color(0xFFB07183)
                                : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFFB07183),
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}