import 'package:flutter/material.dart';
import 'dart:convert'; // ✅ Добавлено для декодирования base64

import '../../services/aiFloristService.dart';
// ... (rest of imports)
import '../../services/userService.dart';
import '../../services/language_service.dart';
import '../../services/orderService.dart'; // ✅ Добавлено
import '../../models/bouquetRequest.dart'; // ✅ Добавлено
import 'bouquetComposer.dart';

class AIFloristScreen extends StatefulWidget {
  const AIFloristScreen({super.key});

  @override
  State<AIFloristScreen> createState() => _AIFloristScreenState();
}

class _AIFloristScreenState extends State<AIFloristScreen> with LanguageStateMixin {
  int _currentStep = 0; // 0 — параметры, 1 — генерация

  // Параметры букета (храним КЛЮЧИ, а не переведенные строки)
  String? _selectedOccasionKey;
  List<String> _selectedColorKeys = [];
  String? _selectedSize;
  final TextEditingController _budgetFromController = TextEditingController();
  final TextEditingController _budgetToController = TextEditingController();
  final TextEditingController _nlpController = TextEditingController();
  List<String> _flowersToInclude = [];
  List<String> _flowersToAvoid = [];
  bool _includeExternal = false;

  // Генерация
  bool _isGenerating = false;
  List<Map<String, dynamic>> _generatedBouquets = [];

  // Статические списки ключей для перевода
  final List<String> _occasionKeys = ['birthday', 'anniversary', 'valentines_day', 'march_8th', 'thank_you', 'congratulations'];
  final List<String> _colorKeys = ['pink', 'red', 'white', 'yellow', 'purple', 'mixed'];
  final List<String> _sizes = ['S', 'M', 'L'];
  List<String> _allFlowers = [];

  @override
  void initState() {
    super.initState();
    _fetchFlowers();
  }

  Future<void> _fetchFlowers() async {
    try {
      final flowers = await AIFloristService().getSupportedFlowers();
      if (mounted && flowers.isNotEmpty) {
        setState(() => _allFlowers = flowers);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _budgetFromController.dispose();
    _budgetToController.dispose();
    _nlpController.dispose();
    super.dispose();
  }

  Future<void> _parseText() async {
    final t = getTranslations();
    if (_nlpController.text.isEmpty) return;
    
    setState(() => _isGenerating = true);
    try {
      final result = await AIFloristService().nlpParse(_nlpController.text);
      if (!mounted) return;
      setState(() {
        if (result['occasion'] != null) {
          final occasion = result['occasion'].toString().toLowerCase();
          _selectedOccasionKey = _occasionKeys.contains(occasion) ? occasion : _occasionKeys.first;
        }
        if (result['colors'] != null) {
           _selectedColorKeys = List<String>.from(result['colors']).map((c) => c.toLowerCase()).toList();
        }
        if (result['flowers_include'] != null) _flowersToInclude = List<String>.from(result['flowers_include']);
        if (result['flowers_avoid'] != null) _flowersToAvoid = List<String>.from(result['flowers_avoid']);
        if (result['budget_max'] != null) _budgetToController.text = result['budget_max'].toString();
        _isGenerating = false;
      });
    } catch (e) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t('error')}: $e')),
      );
    }
  }

  Future<void> _generate() async {
    final t = getTranslations();
    setState(() {
      _isGenerating = true;
      _currentStep = 1;
    });

    try {
      final userId = UserService().currentUserId ?? 'guest';

      final results = await AIFloristService().recommend(
        occasion: _selectedOccasionKey ?? 'birthday',
        colors: _selectedColorKeys,
        flowersInclude: _flowersToInclude,
        flowersAvoid: _flowersToAvoid,
        size: _selectedSize,
        budgetMax: int.tryParse(_budgetToController.text),
        userId: userId,
        includeExternal: _includeExternal,
      );

      setState(() {
        _generatedBouquets = results;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t('network_error')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendToFlorist(Map<String, dynamic> bouquet) async {
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
        bouquetName: bouquet['name'] ?? 'AI Bouquet',
        flowers: bouquet['flowers'] ?? '',
        price: bouquet['price'] ?? 0,
        image: bouquet['catalog_image'],
        createdAt: DateTime.now(),
      );

      await OrderService().createBouquetRequest(request);

      if (mounted) {
        setState(() => _isGenerating = false);
        _showSuccessSheet(bouquet, t);
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

  void _showSuccessSheet(Map<String, dynamic> bouquet, AppTranslations t) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.check_circle, color: Color(0xFFB07183), size: 48),
            const SizedBox(height: 12),
            Text(
              t('request_sent'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              '${t('request_sent_desc')} "${bouquet['name'] ?? 'Bouquet'}"',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB07183),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(t('success'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
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

          _buildSectionTitle(t('describe_dream_bouquet')),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nlpController,
                    decoration: InputDecoration(
                      hintText: t('dream_bouquet_hint'),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.auto_awesome, color: Color(0xFFB07183)),
                  onPressed: _parseText,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle(t('occasion')),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedOccasionKey,
                hint: Text(t('select_occasion')),
                isExpanded: true,
                items: _occasionKeys.map((key) => DropdownMenuItem(value: key, child: Text(t(key)))).toList(),
                onChanged: (value) => setState(() => _selectedOccasionKey = value),
              ),
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionTitle(t('colors')),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _colorKeys.map((key) {
              final isSelected = _selectedColorKeys.contains(key);
              return _buildChip(t(key), isSelected, () {
                setState(() {
                  isSelected ? _selectedColorKeys.remove(key) : _selectedColorKeys.add(key);
                });
              });
            }).toList(),
          ),

          const SizedBox(height: 24),

          _buildSectionTitle(t('size')),
          const SizedBox(height: 8),
          Row(
            children: _sizes.map((size) {
              final isSelected = _selectedSize == size;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: size == 'L' ? 0 : 8),
                  child: ElevatedButton(
                    onPressed: () => setState(() => _selectedSize = size),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? const Color(0xFFB07183) : Colors.grey[100],
                      foregroundColor: isSelected ? Colors.white : Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(size),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          _buildSectionTitle('${t('budget')} (₸)'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildBudgetField(_budgetFromController, t('from'))),
              const SizedBox(width: 12),
              Expanded(child: _buildBudgetField(_budgetToController, t('up_to'))),
            ],
          ),

          const SizedBox(height: 24),

          _buildSectionTitle(t('flowers_to_include')),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._flowersToInclude.map((f) => _buildRemovableChip(f, () {
                setState(() => _flowersToInclude.remove(f));
              })),
              _buildAddChip(() => _showFlowerSelector('include', t), t),
            ],
          ),

          const SizedBox(height: 24),

          _buildSectionTitle(t('flowers_to_avoid')),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._flowersToAvoid.map((f) => _buildRemovableChip(f, () {
                setState(() => _flowersToAvoid.remove(f));
              })),
              _buildAddChip(() => _showFlowerSelector('avoid', t), t),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle(t('include_external_results')),
              Switch(
                value: _includeExternal,
                onChanged: (val) => setState(() => _includeExternal = val),
                activeThumbColor: const Color(0xFFB07183),
                activeTrackColor: const Color(0xFFB07183).withValues(alpha: 0.5),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
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

  Widget _buildBouquetCard(Map<String, dynamic> bouquet, AppTranslations t) {
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
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildImage(bouquet['catalog_image'] ?? bouquet['generated_image'] ?? bouquet['image_base64']),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bouquet['name'] ?? 'Bouquet',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
// ...
                const SizedBox(height: 10),
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: OutlinedButton(
                          onPressed: () {
                            final flowersString = bouquet['flowers'] as String? ?? '';
                            final flowers = flowersString.split(',').map((s) => s.trim()).toList();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BouquetComposerScreen(initialFlowers: flowers),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFB07183),
                            side: const BorderSide(color: Color(0xFFB07183)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(t('view_3d'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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

  Widget _buildImage(String? imageData) {
    if (imageData == null || imageData.isEmpty) return _buildImagePlaceholder();

    if (imageData.startsWith('http')) {
      return Image.network(
        imageData,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
      );
    } else {
      // Вероятно, это base64
      try {
        String base64Str = imageData;
        if (base64Str.contains(',')) {
          base64Str = base64Str.split(',').last;
        }
        return Image.memory(
          base64Decode(base64Str),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
        );
      } catch (e) {
        print('❌ Error decoding base64 image: $e');
        return _buildImagePlaceholder();
      }
    }
  }

  Widget _buildImagePlaceholder() {

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBF5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.local_florist, color: Color(0xFFB07183), size: 40),
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

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB07183) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : Colors.grey[700]),
        ),
      ),
    );
  }

  Widget _buildRemovableChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFB07183).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFFB07183))),
          const SizedBox(width: 6),
          GestureDetector(onTap: onRemove, child: const Icon(Icons.close, size: 14, color: Color(0xFFB07183))),
        ],
      ),
    );
  }

  Widget _buildAddChip(VoidCallback onTap, AppTranslations t) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(t('add'), style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ),
    );
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

  void _showFlowerSelector(String type, AppTranslations t) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type == 'include' ? t('flowers_to_include') : t('flowers_to_avoid'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allFlowers.map((flower) {
                final isInList = type == 'include' ? _flowersToInclude.contains(flower) : _flowersToAvoid.contains(flower);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (type == 'include') {
                        if (!isInList) _flowersToInclude.add(flower);
                      } else {
                        if (!isInList) _flowersToAvoid.add(flower);
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isInList ? const Color(0xFFB07183) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      flower,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isInList ? Colors.white : Colors.grey[700]),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
