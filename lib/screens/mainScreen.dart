import 'package:flowery_app/screens/search.dart';
import 'package:flutter/material.dart';
import 'cart.dart';
import 'favorite.dart';
import 'home.dart';
import 'profile.dart';
// Импортируйте другие экраны когда создадите их

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),           // Главная
    const SearchScreen(),         // Поиск (создайте заглушку)
    const FavoritesScreen(),      // Избранное (создайте загглушку)
    const CartScreen(),           // Корзина (создайте заглушку)
    const ProfileScreen(),        // Профиль
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
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
            label: 'Main',
            index: 0,
          ),
          _buildNavItem(
            icon: Icons.search,
            label: 'Search',
            index: 1,
          ),
          _buildNavItem(
            icon: Icons.favorite_border,
            label: 'Favorite',
            index: 2,
          ),
          _buildNavItem(
            icon: Icons.shopping_bag_outlined,
            label: 'Cart',
            index: 3,
          ),
          _buildNavItem(
            icon: Icons.person,
            label: 'Profile',
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
  }) {
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