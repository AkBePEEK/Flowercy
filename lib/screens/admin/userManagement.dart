import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/language_service.dart';
import '../../services/userService.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> with LanguageStateMixin {
  final UserService _userService = UserService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _userService.getCurrentUser();
    if (mounted) {
      setState(() => _currentUser = user);
    }
  }

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
          t('user_management'),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<User>>(
        stream: _userService.getAllUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${t('error')}: ${snapshot.error}'));
          }
          final users = snapshot.data ?? [];
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildUserCard(users[index], t),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(User user, AppTranslations t) {
    final bool isMe = user.id == _currentUser?.id;
    final bool canEdit = _currentUser?.isSuperAdmin ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFB07183).withValues(alpha: 0.1),
            child: Text(
              (user.name ?? user.email).substring(0, 1).toUpperCase(),
              style: const TextStyle(color: Color(0xFFB07183), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? t('no_name'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  user.email,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                _buildRoleBadge(user.role),
              ],
            ),
          ),
          if (canEdit && !isMe)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Color(0xFFB07183)),
              onPressed: () => _showRoleDialog(user, t),
            ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    Color color;
    String label;
    switch (role) {
      case UserRole.superAdmin:
        color = Colors.purple;
        label = 'Super Admin';
        break;
      case UserRole.admin:
        color = Colors.blue;
        label = 'Admin';
        break;
      case UserRole.user:
        color = Colors.grey;
        label = 'User';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showRoleDialog(User user, AppTranslations t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('change_role')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserRole.values.map((role) {
            return ListTile(
              title: Text(role.name.toUpperCase()),
              leading: Radio<UserRole>(
                value: role,
                groupValue: user.role,
                onChanged: (newRole) {
                  if (newRole != null) {
                    _userService.updateUserRole(user.id, newRole);
                    Navigator.pop(context);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
