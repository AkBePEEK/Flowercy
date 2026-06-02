import 'package:flutter/material.dart';
import '../../services/language_service.dart';
import '../orderScreens/orderManagement.dart';
import 'bouquetRequestManagement.dart';
import 'productManagement.dart';
import 'userManagement.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with LanguageStateMixin {
  @override
  Widget build(BuildContext context) {
    final t = getTranslations();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          t('admin_panel'),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAdminCard(
            context,
            title: t('order_management'),
            icon: Icons.shopping_bag_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OrderManagementScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _buildAdminCard(
            context,
            title: t('bouquet_requests'),
            icon: Icons.auto_awesome_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BouquetRequestManagementScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _buildAdminCard(
            context,
            title: t('user_management'),
            icon: Icons.people_outline,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserManagementScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _buildAdminCard(
            context,
            title: t('product_management'),
            icon: Icons.inventory_2_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProductManagementScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: const Color(0xFFB07183)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
