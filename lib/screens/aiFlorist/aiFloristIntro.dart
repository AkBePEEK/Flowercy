import 'package:flutter/material.dart';
import 'aiFloristInput.dart';

class AIFloristIntroScreen extends StatelessWidget {
  const AIFloristIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI florist',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Декоративные элементы
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFB07183).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Звездочки
                    Positioned(
                      top: 40,
                      child: Icon(
                        Icons.auto_awesome,
                        size: 60,
                        color: const Color(0xFFB07183).withValues(alpha: 0.6),
                      ),
                    ),
                    Positioned(
                      bottom: 50,
                      left: 30,
                      child: Icon(
                        Icons.star,
                        size: 30,
                        color: const Color(0xFFB07183).withValues(alpha: 0.4),
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      right: 40,
                      child: Icon(
                        Icons.auto_awesome,
                        size: 25,
                        color: const Color(0xFFB07183).withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Заголовок
              const Text(
                'Create your bouquets in seconds\nusing AI',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Шаги
              _buildStep(1, 'Tell us your idea', 'Enter a short description of your bouquet'),
              const SizedBox(height: 16),
              _buildStep(2, 'Customize details', 'Choose colors, mood, size, and occasion'),
              const SizedBox(height: 16),
              _buildStep(3, 'Generate & refine', 'Get your AI-generated bouquet and adjust if needed'),

              const Spacer(),

              // Кнопка
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AIFloristInputScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB07183),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Start creating',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int number, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFB07183),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}