import 'package:flowery_app/screens/signIn.dart';
import 'package:flowery_app/screens/signUpEmail.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Flower Images Grid
              _buildFlowerImagesGrid(),

              const SizedBox(height: 32),

              // Welcome Text
              const Text(
                'Welcome to Flowery',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Find your dream flowers!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 32),

              // Sign Up Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Apple Sign Up Button
                    _buildSocialButton(
                      icon: Icons.apple,
                      text: 'Sign Up with Apple',
                      onPressed: () {},
                    ),

                    const SizedBox(height: 16),

                    // Google Sign Up Button
                    _buildSocialButton(
                      icon: Icons.g_mobiledata,
                      text: 'Sign Up with Google',
                      onPressed: () {},
                      iconColor: Colors.blue,
                    ),

                    const SizedBox(height: 24),

                    // OR Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Email Sign Up Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC57A8E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpEmailScreen()),
                          );
                        },
                        icon: const Icon(
                          Icons.email_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                        label: const Text(
                          'Sign Up with Email',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Already have account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Переход на страницу входа
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignInScreen()),
                            );
                          },
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlowerImagesGrid() {
    return Column(
      children: [
        // First row - 5 images with horizontal scroll
        SizedBox(
          height: 150, // Увеличенная высота для первого ряда
          child: Row(
            children: [
              Transform.translate(
                offset: const Offset(-70, 0), // 30px за экраном
                child: Row(
                  children: [
                    _buildFlowerImage('assets/flowers/signUpScreen/flower1.png', width: 100),
                    const SizedBox(width: 10),
                    _buildFlowerImage('assets/flowers/signUpScreen/flower2.png', width: 100),
                    const SizedBox(width: 10),
                    _buildFlowerImage('assets/flowers/signUpScreen/flower3.png', width: 100),
                    const SizedBox(width: 10),
                    _buildFlowerImage('assets/flowers/signUpScreen/flower4.png', width: 100),
                    const SizedBox(width: 10),
                    _buildFlowerImage('assets/flowers/signUpScreen/flower5.png', width: 100),
                  ]
                ),
              )
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Second row - 4 images with horizontal scroll
        SizedBox(
          height: 150, // Немного меньше высота для второго ряда
          child: Row(
            children: [
              Transform.translate(
                offset: const Offset(-30, 0), // 30px за экраном
                child: Row(
                    children: [
                      _buildFlowerImage('assets/flowers/signUpScreen/flower6.png', width: 100),
                      const SizedBox(width: 10),
                      _buildFlowerImage('assets/flowers/signUpScreen/flower7.png', width: 100),
                      const SizedBox(width: 10),
                      _buildFlowerImage('assets/flowers/signUpScreen/flower8.png', width: 100),
                      const SizedBox(width: 10),
                      _buildFlowerImage('assets/flowers/signUpScreen/flower9.png', width: 100),
                    ]
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlowerImage(String imagePath, {required double width}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: width,
        height: double.infinity,
        color: Colors.pink[100], // Placeholder color
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.pink[100],
              child: const Icon(
                Icons.local_florist,
                color: Colors.pink,
                size: 40,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    Color? iconColor,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: iconColor ?? Colors.black87,
          size: 28,
        ),
        label: Text(
          text,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}