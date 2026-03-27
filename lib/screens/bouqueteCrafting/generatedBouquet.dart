import 'package:flutter/material.dart';

class GeneratedBouquetsScreen extends StatelessWidget {
  final String description;
  final String? occasion;
  final List<String> colors;
  final List<String> moods;
  final String? size;

  const GeneratedBouquetsScreen({
    super.key,
    required this.description,
    this.occasion,
    required this.colors,
    required this.moods,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    // Пример сгенерированных букетов (в реальности здесь будет AI генерация)
    final bouquets = List.generate(4, (index) => {
      'title': 'Soft & Elegant',
      'tags': ['Tender', 'Pastel', 'Romantic'],
      'price': '29 500 ₸',
      'image': 'assets/flowers/products/red_roses.png',
    });

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
          'Generated bouquets',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Подзаголовок
                    Text(
                      'Here are some personalized bouquets we created for you based on your description',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Список букетов
                    ...bouquets.map((bouquet) => _buildBouquetCard(bouquet)),

                    const SizedBox(height: 16),

                    // Regenerate link
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          // Перегенерировать
                          _showRegenerateDialog(context);
                        },
                        child: const Text(
                          'Don\'t like any of these? Regenerate bouquets',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFB07183),
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

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

  Widget _buildBouquetCard(Map<String, dynamic> bouquet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
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
          // Изображение
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                bouquet['image']!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.local_florist, color: Colors.grey),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Информация
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bouquet['title']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                // Теги
                Text(
                  bouquet['tags']!.join(' • '),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 12),

                // Цена
                Text(
                  bouquet['price']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB07183),
                  ),
                ),

                const SizedBox(height: 12),

                // Кнопка Send request
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      // Отправить запрос
                      _showRequestDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB07183),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Send request',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRegenerateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regenerate bouquets?'),
        content: const Text('We\'ll create new bouquet options for you based on your preferences.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Здесь логика регенерации
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Generating new bouquets...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB07183),
              foregroundColor: Colors.white,
            ),
            child: const Text('Regenerate'),
          ),
        ],
      ),
    );
  }

  void _showRequestDialog() {
    // Диалог отправки запроса
  }
}