import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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

  // Header с профилем
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          // Аватар
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 35,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          // Имя и Settings
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lada',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
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
          _buildMenuItem('My orders', hasArrow: true),
          const Divider(height: 1, indent: 16),
          _buildMenuItem(
            'Notifications',
            trailing: Transform.scale(
              scale: 0.8, // ✅ Уменьшаем Switch на 20%
              child: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFFB07183),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey[300],
              ),
            ),
          ),
          const Divider(height: 1, indent: 16),
          _buildMenuItem('Language', trailing: const Text('EN')),
          const Divider(height: 1, indent: 16),
          _buildMenuItem('Saved addresses', hasArrow: true),
          const Divider(height: 1, indent: 16),
          _buildMenuItem('About us', hasArrow: true),
        ],
      ),
    );
  }

  // Элемент меню
  Widget _buildMenuItem(
      String title, {
        bool hasArrow = false,
        Widget? trailing,
      }) {
    return Container(
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
    );
  }

  // Кнопка Sign out
  Widget _buildSignOutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () {
            // Логика выхода
            print('🚪 Sign out');
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
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