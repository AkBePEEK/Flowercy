import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowery_app/screens/navigationBar/search.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/user.dart';
import '../services/language_service.dart';
import '../services/userService.dart';
import 'navigationBar/cart.dart';
import 'navigationBar/favorite.dart';
import 'navigationBar/home.dart';
import 'navigationBar/profile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    const HomeScreen(),           // Главная
    const SearchScreen(),         // Поиск
    const FavoritesScreen(),      // Избранное
    CartScreen(onBrowseFlowers: () => setState(() => _currentIndex = 0)),         // Корзина
    const ProfileScreen(),        // Профиль
  ];

  @override
  void initState() {
    super.initState();
    appLanguageNotifier.addListener(_onLanguageChanged);
    _checkRoleMigration();
  }

  // ✅ Миграция со старого поля isAdmin на новую систему ролей
  Future<void> _checkRoleMigration() async {
    try {
      final userService = UserService();
      final userId = userService.currentUserId;
      if (userId == null) return;

      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        // Если есть старое поле isAdmin: true, но нет поля role — ставим admin
        if (data != null && data['isAdmin'] == true && data['role'] == null) {
          await userService.updateUserRole(userId, UserRole.admin);
          print('✅ User $userId migrated to Admin role');
        }
      }
    } catch (e) {
      print('❌ Migration error: $e');
    }
  }

  @override
  void dispose() {
    appLanguageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final t = getTranslations();
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNav(t),
    );
  }

  Widget _buildBottomNav(AppTranslations t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: null,
            image: "assets/flowers/homeActive.png", // Ваше изображение
            label: t('home'),
            index: 0,
          ),
          _buildNavItem(
            icon: Icons.search,
            label: t('search'),
            index: 1,
          ),
          _buildNavItem(
            icon: Icons.favorite_border,
            label: t('favorites'),
            index: 2,
          ),
          _buildNavItem(
            icon: Icons.shopping_bag_outlined,
            label: t('cart'),
            index: 3,
          ),
          _buildNavItem(
            icon: Icons.person_outline,
            label: t('profile'),
            index: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    IconData? icon,
    String? image,
    required String label,
    required int index,
  })
  {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (image != null)
          // Изображение
            Image.asset(
              image,
              width: 24,
              height: 24,
              color: isActive ? const Color(0xFFB07183) : Colors.grey,
            )
          else if (icon != null)
          // Иконка
            Icon(
              icon,
              color: isActive ? const Color(0xFFB07183) : Colors.grey,
              size: 24,
            ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? const Color(0xFFB07183) : Colors.grey,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
