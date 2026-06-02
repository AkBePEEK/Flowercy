import 'package:flutter/material.dart';
import '../../services/language_service.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> with LanguageStateMixin {
  @override
  Widget build(BuildContext context) {
    final t = getTranslations();
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          t('about_us'),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 120,
                height: 120,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFB07183).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  "assets/flowers/logo.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              t('app_name'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB07183),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t('about_app_description'),
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoSection(
              t('our_mission_title'),
              t('our_mission_text'),
              Icons.auto_awesome,
            ),
            const SizedBox(height: 24),
            _buildInfoSection(
              t('contact_info_title'),
              "Email: support@flowery.kz\nPhone: +7 (700) 891-30-25\nAddress: Astana, Kazakhstan",
              Icons.contact_support_outlined,
            ),
            const SizedBox(height: 40),
            const Center(
              child: Text(
                "Version 1.0.0",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String text, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFFB07183), size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
