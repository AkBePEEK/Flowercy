import 'package:flowery_app/screens/authorizationScreens/signUp.dart';
import 'package:flutter/material.dart';
// ✅ Firebase импорты
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/language_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with LanguageStateMixin {
  // ✅ Контроллеры для полей
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ✅ Состояния для загрузки и ошибок
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ✅ Валидация email
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // ✅ Обработка входа
  Future<void> _handleSignIn() async {
    final t = getTranslations();
    setState(() => _errorMessage = null);

    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = t('fill_all_fields');
      });
      _showError(t('fill_all_fields'));
      return;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      setState(() {
        _errorMessage = t('enter_valid_email');
      });
      _showError(t('enter_valid_email'));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      // ✅ Обработка ошибок Firebase
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = t('user_not_found');
          break;
        case 'wrong-password':
          message = t('wrong_password');
          break;
        case 'invalid-credential':
          message = t('invalid_credential');
          break;
        case 'invalid-email':
          message = t('invalid_email');
          break;
        case 'user-disabled':
          message = t('user_disabled');
          break;
        case 'too-many-requests':
          message = t('too_many_requests');
          break;
        default:
          message = '${t('general_error')} (${e.code})';
      }

      if (mounted) {
        setState(() => _errorMessage = message);
        _showError(message);
      }
    } catch (e) {
      // ✅ Сетевые или другие ошибки
      if (mounted) {
        setState(() => _errorMessage = t('network_error'));
        _showError(t('network_error'));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ✅ Показать ошибку в SnackBar
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Image
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('assets/flowers/signInScreen/flowerHeader.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Sign In Title
              Center(
                child: Text(
                  t('signIn'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ✅ Блок с ошибкой (если есть)
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Email Field
              Text(
                t('email'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  // ✅ Красная рамка при ошибке
                  border: Border.all(
                    color: _errorMessage != null && _emailController.text.isEmpty
                        ? Colors.red
                        : Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  // ✅ Добавить контроллер
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: t('enter_email_hint'),
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  // ✅ Сбрасывать ошибку при вводе
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() => _errorMessage = null);
                    }
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Password Field
              Text(
                t('password'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _errorMessage != null && _passwordController.text.isEmpty
                        ? Colors.red
                        : Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  // ✅ Добавить контроллер
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: t('enter_password_hint'),
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  // ✅ Enter вызывает вход
                  onSubmitted: (_) => _handleSignIn(),
                  // ✅ Сбрасывать ошибку при вводе
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() => _errorMessage = null);
                    }
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Sign In Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  // ✅ Серая кнопка при загрузке
                  color: _isLoading ? Colors.grey[400] : const Color(0xFFC57A8E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton.icon(
                  // ✅ Блокировка при загрузке
                  onPressed: _isLoading ? null : _handleSignIn,
                  icon: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(
                    Icons.email_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                  label: Text(
                    // ✅ Текст при загрузке
                    _isLoading ? t('signing_in_btn') : t('signIn'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Don't have account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${t('noAccount')} ",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: Text(
                      t('signUp'),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
