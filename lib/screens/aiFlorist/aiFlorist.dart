import 'package:flutter/material.dart';
import 'dart:convert';

import '../../services/aiFloristService.dart';
import '../../models/api/product_card.dart';
import '../../services/userService.dart';
import '../../services/language_service.dart';
import '../../services/orderService.dart';
import '../../models/bouquetRequest.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/api/api_config.dart';

class AIFloristScreen extends StatefulWidget {
  const AIFloristScreen({super.key});

  @override
  State<AIFloristScreen> createState() => _AIFloristScreenState();
}

class _AIFloristScreenState extends State<AIFloristScreen> with LanguageStateMixin {
  int _currentStep = 0; // 0 — параметры, 1 — генерация

  // Параметры букета
  String? _selectedOccasionKey;
  String? _selectedMoodKey;
  String? _selectedStyleKey;
  List<String> _selectedColors = [];
  bool _forceGen = true;
  
  final TextEditingController _budgetToController = TextEditingController();
  final TextEditingController _nlpController = TextEditingController();
  
  // Выбранные цветы из каталога
  final List<Map<String, dynamic>> _selectedCatalogFlowers = [];
  List<Map<String, dynamic>> _catalogFlowers = [];
  bool _hasCatalogError = false;

  // Генерация
  bool _isGenerating = false;
  List<ProductCard> _generatedBouquets = [];

  // Статические списки ключей для перевода
  final List<String> _occasionKeys = ['birthday', 'anniversary', 'valentines_day', 'march_8th', 'thank_you', 'congratulations'];
  final List<String> _moodKeys = ['cheerful', 'romantic', 'elegant', 'happy'];
  final List<String> _styleKeys = ['sun_drenched', 'modern', 'classic', 'rustic'];
  final List<String> _colorKeys = ['golden_yellow', 'amber', 'pink', 'red', 'white', 'yellow', 'purple', 'mixed'];
  
  @override
  void initState() {
    super.initState();
    AIFloristService().checkConnection();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    setState(() {
      _hasCatalogError = false;
      _catalogFlowers = [];
    });
    try {
      final flowers = await AIFloristService().getCatalogFlowers();
      if (mounted) {
        setState(() {
          _catalogFlowers = flowers;
          _hasCatalogError = flowers.isEmpty;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _hasCatalogError = true);
      }
    }
  }

  @override
  void dispose() {
    _budgetToController.dispose();
    _nlpController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final t = getTranslations();
    
    // Предварительная проверка связи
    final isAlive = await AIFloristService().checkConnection();
    if (!isAlive) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t('network_error')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: t('success'), onPressed: _generate, textColor: Colors.white),
          ),
        );
      }
      return;
    }

    setState(() {
      _isGenerating = true;
      _currentStep = 1;
    });

    try {
      final userId = UserService().currentUserId ?? 'guest';

      // Формируем детальный запрос на основе выбранных цветов
      String flowerQuery = _selectedCatalogFlowers
          .map((f) => f['name'])
          .join(", ");
      
      String query = _nlpController.text;
      if (query.isEmpty) {
        query = "Create a bouquet for ${_selectedOccasionKey ?? 'special occasion'}";
        if (flowerQuery.isNotEmpty) query += " using: $flowerQuery";
        if (_budgetToController.text.isNotEmpty) query += ". Budget: ${_budgetToController.text} KZT";
      } else if (flowerQuery.isNotEmpty) {
        query += ". Please use these specific flowers: $flowerQuery";
      }

      // Мы всё еще вызываем recommendFromText для логирования предпочтений на бэкенде,
      // но для отображения используем только сгенерированные нейросетью варианты.
      await AIFloristService().recommendFromText(
        query,
        userId: userId,
        occasion: _selectedOccasionKey,
        budgetMax: double.tryParse(_budgetToController.text),
        flowersInclude: _selectedCatalogFlowers.map((f) => f['name'] as String).toList(),
        topN: 3,
      );

      final List<ProductCard> aiVariations = [];

      // Генерируем 3 варианта через Stable Diffusion для разнообразия
      for (int i = 0; i < 3; i++) {
        try {
          final genResult = await AIFloristService().generateImage(
            flowers: _selectedCatalogFlowers.isNotEmpty 
              ? _selectedCatalogFlowers.map((f) => f['name'] as String).toList()
              : ['rose', 'peony', 'eucalyptus'], // fallback flowers
            colors: _selectedColors,
            mood: _selectedMoodKey,
            style: _selectedStyleKey,
            occasion: _selectedOccasionKey,
            forceGen: _forceGen,
          );
          
          if (genResult['image_base64'] != null) {
            aiVariations.add(ProductCard(
              id: 'generated_${DateTime.now().millisecondsSinceEpoch}_$i',
              name: '${t('ai_generated_bouquet')} ${i + 1}',
              price: double.tryParse(_budgetToController.text) ?? 15000,
              imageUrl: genResult['image_base64'],
              provider: 'AI Florist',
              storeId: 'ai_studio',
              inStock: true,
              description: query,
              reason: 'Variation ${i + 1} freshly generated by Stable Diffusion',
            ));
          }
          // Небольшая задержка между запросами, чтобы сервер успел освободить память
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (genError) {
          print('⚠️ Error generating variation $i: $genError');
        }
      }

      setState(() {
        _generatedBouquets = aiVariations;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        String errorMsg = e.toString().replaceFirst('Exception: ', '');
        if (errorMsg.isEmpty || errorMsg.contains('Error')) errorMsg = t('network_error');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendToFlorist(ProductCard bouquet) async {
    final t = getTranslations();
    final userService = UserService();
    final user = await userService.getCurrentUser();
    
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('signIn'))),
        );
      }
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final request = BouquetRequest(
        id: '',
        userId: user.id,
        userName: user.name ?? user.email.split('@').first,
        userPhone: user.phone ?? '',
        bouquetName: bouquet.name,
        flowers: bouquet.description ?? '',
        price: bouquet.price.toInt(),
        image: bouquet.imageUrl,
        createdAt: DateTime.now(),
      );

      await OrderService().createBouquetRequest(request);

      // Прямой запуск WhatsApp сразу после сохранения
      const phone = "77008913025";
      final message = "Здравствуйте! Я хочу заказать букет, сгенерированный ИИ: \"${bouquet.name}\". Цена: ${bouquet.price.toInt()} ₸.";
      final encodedMsg = Uri.encodeComponent(message);
      
      final urls = [
        "whatsapp://send?phone=$phone&text=$encodedMsg",
        "https://wa.me/$phone?text=$encodedMsg",
      ];
      
      bool launched = false;
      for (var url in urls) {
        try {
          if (await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
            launched = true;
            break;
          }
        } catch (_) {}
      }

      if (mounted) {
        setState(() => _isGenerating = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(launched ? t('request_sent') : "Запрос сохранен. Не удалось открыть WhatsApp."),
            backgroundColor: launched ? Colors.green : Colors.orange,
          ),
        );
        
        // Возвращаемся на главный экран через секунду
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t('error')}: $e')),
        );
      }
    }
  }

  void _showSuccessSheet(ProductCard bouquet, AppTranslations t) {
    // Этот метод больше не используется, так как переход стал прямым
  }

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
          onPressed: () {
            if (_currentStep == 1) {
              setState(() => _currentStep = 0);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          t('ai_bouquet'),
          style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStepIndicator(t),
          Expanded(
            child: _currentStep == 0
                ? _buildParametersStep(t)
                : _buildGenerationStep(t),
          ),
          _buildBottomButton(t),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(AppTranslations t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          _buildStepDot(0, t('occasion')),
          Expanded(
            child: Container(
              height: 2,
              color: _currentStep >= 1 ? const Color(0xFFB07183) : Colors.grey[200],
            ),
          ),
          _buildStepDot(1, t('success')),
        ],
      ),
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFB07183) : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? const Color(0xFFB07183) : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildParametersStep(AppTranslations t) {
    if (_hasCatalogError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(t('network_error'), style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCatalog,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB07183)),
              child: Text(t('success'), style: const TextStyle(color: Colors.white)), // "OK/Retry"
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('customize_bouquet'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            t('select_flowers_occasion_budget'),
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // 1. Выбор цветов из каталога
          _buildSectionTitle(t('select_flowers')),
          const SizedBox(height: 12),
          _catalogFlowers.isEmpty 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFB07183)))
            : Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _catalogFlowers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final flower = _catalogFlowers[index];
                    final selectionIdx = _selectedCatalogFlowers.indexWhere((s) => s['id'] == flower['id']);
                    final count = selectionIdx != -1 ? _selectedCatalogFlowers[selectionIdx]['count'] : 0;

                    final isSelected = selectionIdx != -1;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildImage(flower['image'], size: 40),
                      ),
                      title: Text(flower['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      subtitle: Text('${flower['price_per_stem']} ₸', style: const TextStyle(fontSize: 12)),
                      trailing: isSelected 
                        ? const Icon(Icons.check_circle, color: Color(0xFFB07183))
                        : Icon(Icons.radio_button_unchecked, color: Colors.grey[300]),
                      onTap: () => setState(() {
                        if (isSelected) {
                          _selectedCatalogFlowers.removeAt(selectionIdx);
                        } else {
                          _selectedCatalogFlowers.add({
                            'id': flower['id'],
                            'name': flower['name'],
                            'count': 1,
                          });
                        }
                      }),
                    );
                  },
                ),
              ),
          
          const SizedBox(height: 24),

          // 2. Повод
          _buildSectionTitle(t('occasion')),
          const SizedBox(height: 8),
          _buildDropdown(_selectedOccasionKey, _occasionKeys, t('select_occasion'), (val) => setState(() => _selectedOccasionKey = val), t),

          const SizedBox(height: 24),

          // 3. Настроение и Стиль
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(t('mood')),
                    const SizedBox(height: 8),
                    _buildDropdown(_selectedMoodKey, _moodKeys, t('select_mood'), (val) => setState(() => _selectedMoodKey = val), t),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(t('style')),
                    const SizedBox(height: 8),
                    _buildDropdown(_selectedStyleKey, _styleKeys, t('select_style'), (val) => setState(() => _selectedStyleKey = val), t),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 4. Цвета
          _buildSectionTitle(t('colors')),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _colorKeys.map((key) {
              final isSelected = _selectedColors.contains(key);
              return FilterChip(
                label: Text(t(key), style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedColors.add(key);
                    } else {
                      _selectedColors.remove(key);
                    }
                  });
                },
                selectedColor: const Color(0xFFB07183),
                checkmarkColor: Colors.white,
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey[200]!)),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // 5. Бюджет
          _buildSectionTitle('${t('budget')} (₸)'),
          const SizedBox(height: 8),
          _buildBudgetField(_budgetToController, t('up_to')),

          const SizedBox(height: 24),

          // 6. Дополнительные пожелания (текст)
          _buildSectionTitle(t('describe_dream_bouquet')),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: _nlpController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: t('dream_bouquet_hint'),
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 7. Force Generation
          SwitchListTile(
            title: Text(t('force_gen'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            value: _forceGen,
            activeColor: const Color(0xFFB07183),
            onChanged: (val) => setState(() => _forceGen = val),
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDropdown(String? value, List<String> items, String hint, Function(String?) onChanged, AppTranslations t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 13)),
          isExpanded: true,
          items: items.map((key) => DropdownMenuItem(value: key, child: Text(t(key), style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildGenerationStep(AppTranslations t) {
    if (_isGenerating) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFFB07183)),
            const SizedBox(height: 16),
            Text(
              t('generating_bouquet'),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('your_bouquets'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            t('choose_and_send'),
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ..._generatedBouquets.map((bouquet) => _buildBouquetCard(bouquet, t)),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: _generate,
              child: Text(
                t('regenerate_bouquets'),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFB07183),
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBouquetCard(ProductCard bouquet, AppTranslations t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildImage(bouquet.imageUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bouquet.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${bouquet.price.toInt()} ₸',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFB07183)),
                ),
                if (bouquet.reason != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBF5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: Color(0xFFB07183)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            bouquet.reason!,
                            style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () => _sendToFlorist(bouquet),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB07183),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(t('send'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ),
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

  Widget _buildImage(String? imageData, {double size = 100}) {
    if (imageData == null || imageData.isEmpty) return _buildImagePlaceholder(size);

    final String baseUrl = ApiConfig.baseUrl;

    if (imageData.startsWith('http')) {
      return Image.network(
        imageData,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(size),
      );
    } else if (imageData.startsWith('catalog/') || imageData.startsWith('outputs/')) {
      final imageUrl = '$baseUrl/static/$imageData';
      return Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          String assetPath = imageData.replaceFirst('catalog/', 'assets/flowers/products/');
          return Image.asset(
            assetPath,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildImagePlaceholder(size),
          );
        },
      );
    } else if (imageData.contains('.png') || imageData.contains('.jpg')) {
      return Image.asset(
        imageData,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(size),
      );
    } else {
      try {
        String base64Str = imageData;
        if (base64Str.contains(',')) base64Str = base64Str.split(',').last;
        return Image.memory(
          base64Decode(base64Str),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildImagePlaceholder(size),
        );
      } catch (e) {
        return _buildImagePlaceholder(size);
      }
    }
  }

  Widget _buildImagePlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBF5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.local_florist, color: const Color(0xFFB07183), size: size * 0.4),
    );
  }

  Widget _buildBottomButton(AppTranslations t) {
    if (_currentStep == 1 || _isGenerating) return const SizedBox.shrink();

    return Container(
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
            onPressed: _generate,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB07183),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(t('generate_bouquet_btn'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87));
  }

  Widget _buildBudgetField(TextEditingController controller, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
