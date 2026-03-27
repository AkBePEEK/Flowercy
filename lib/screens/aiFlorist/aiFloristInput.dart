import 'package:flutter/material.dart';

class AIFloristInputScreen extends StatefulWidget {
  const AIFloristInputScreen({super.key});

  @override
  State<AIFloristInputScreen> createState() => _AIFloristInputScreenState();
}

class _AIFloristInputScreenState extends State<AIFloristInputScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedSuggestion;

  final List<String> _suggestions = [
    'March 8th holiday bouquet',
    'March 8th birthday bouquet',
    'March 8th romantic',
    'Anniversary',
  ];

  // ✅ Результаты AI (показываются прямо здесь)
  bool _isGenerating = false;
  List<Map<String, dynamic>> _aiResults = [];

  // ✅ Генерация AI предложений
  Future<void> _generateAIResults() async {
    if (_descriptionController.text.isEmpty) return;

    setState(() {
      _isGenerating = true;
    });

    // Имитация AI генерации (здесь будет API запрос)
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _aiResults = [
        {
          'title': 'Romantic Roses',
          'description': 'Classic red roses with baby\'s breath',
          'price': '25 000 ₸',
          'image': 'assets/flowers/products/red_roses.png',
        },
        {
          'title': 'Spring Tulips',
          'description': 'Fresh pink tulips arrangement',
          'price': '18 500 ₸',
          'image': 'assets/flowers/products/pink_roses.png',
        },
      ];
      _isGenerating = false;
    });
  }


  @override
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
        child: Column(
          children: [
            // ✅ Верхняя часть — скроллится
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(  // ✅ Здесь НЕТ Expanded!
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter a short description of your bouquet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Suggestions
                    const Text(
                      'Suggestions',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _suggestions.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final suggestion = _suggestions[index];
                          final isSelected = _selectedSuggestion == suggestion;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSuggestion = suggestion;
                                _descriptionController.text = suggestion;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFB07183)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                suggestion,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? Colors.white : Colors.grey[700],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Text field
                    const Text(
                      'Describe your bouquet',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'e.g., Romantic red roses for anniversary...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ✅ Результаты AI (горизонтальный список, фиксированная высота)
                    if (_aiResults.isNotEmpty)
                      SizedBox(
                        height: 200,  // ✅ Фиксированная высота!
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _aiResults.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final result = _aiResults[index];
                            return _buildResultCard(result);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ✅ Кнопка — фиксирована внизу (не внутри скролла)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isGenerating ? null : _generateAIResults,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB07183),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isGenerating
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Generate bouquet ideas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                result['image']!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.local_florist, color: Colors.grey);
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result['title']!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            result['price']!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFB07183),
            ),
          ),
        ],
      ),
    );
  }
}