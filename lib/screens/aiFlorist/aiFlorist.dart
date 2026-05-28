import 'package:flutter/material.dart';

import '../../services/aiFloristService.dart';
import '../../services/userService.dart';
import 'bouquetComposer.dart';

class AIFloristScreen extends StatefulWidget {
  const AIFloristScreen({super.key});

  @override
  State<AIFloristScreen> createState() => _AIFloristScreenState();
}

class _AIFloristScreenState extends State<AIFloristScreen> {
  int _currentStep = 0; // 0 — параметры, 1 — генерация

  // Параметры букета
  String? _selectedOccasion;
  List<String> _selectedColors = [];
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

  List<String> _occasions = [];
  List<String> _colors = [];
  final List<String> _sizes = ['S', 'M', 'L'];
  List<String> _allFlowers = [];

  @override
  void initState() {
    super.initState();
    _fetchParameters();
  }

  Future<void> _fetchParameters() async {
    try {
      final aiService = AIFloristService();
      final occasions = await aiService.getSupportedOccasions();
      final colors = await aiService.getSupportedColors();
      final flowers = await aiService.getSupportedFlowers();
      
      setState(() {
        _occasions = occasions.isNotEmpty ? occasions : [
          'Birthday', 'Anniversary', 'Valentine\'s Day',
          'March 8th', 'Thank you', 'Congratulations',
        ];
        _colors = colors.isNotEmpty ? colors : ['Pink', 'Red', 'White', 'Yellow', 'Purple', 'Mixed'];
        _allFlowers = flowers.isNotEmpty ? flowers : [
          'Roses', 'Tulips', 'Peonies', 'Lilies', 'Daisies',
          'Orchids', 'Carnations', 'Chrysanthemums', 'Hydrangeas',
        ];
      });
    } catch (e) {
      print('Error fetching parameters: $e');
      // Fallback to defaults
      setState(() {
        _occasions = [
          'Birthday', 'Anniversary', 'Valentine\'s Day',
          'March 8th', 'Thank you', 'Congratulations',
        ];
        _colors = ['Pink', 'Red', 'White', 'Yellow', 'Purple', 'Mixed'];
        _allFlowers = [
          'Roses', 'Tulips', 'Peonies', 'Lilies', 'Daisies',
          'Orchids', 'Carnations', 'Chrysanthemums', 'Hydrangeas',
        ];
      });
    }
  }

  @override
  void dispose() {
    _budgetFromController.dispose();
    _budgetToController.dispose();
    _nlpController.dispose();
    super.dispose();
  }

  Future<void> _parseText() async {
    if (_nlpController.text.isEmpty) return;
    
    setState(() => _isGenerating = true);
    try {
      final result = await AIFloristService().nlpParse(_nlpController.text);
      setState(() {
        if (result['occasion'] != null) _selectedOccasion = result['occasion'];
        if (result['colors'] != null) _selectedColors = List<String>.from(result['colors']);
        if (result['flowers_include'] != null) _flowersToInclude = List<String>.from(result['flowers_include']);
        if (result['flowers_avoid'] != null) _flowersToAvoid = List<String>.from(result['flowers_avoid']);
        if (result['budget_max'] != null) _budgetToController.text = result['budget_max'].toString();
        _isGenerating = false;
      });
    } catch (e) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to parse text: $e')),
      );
    }
  }

  Future<void> _generate() async {
    setState(() {
      _isGenerating = true;
      _currentStep = 1;
    });

    try {
      final userId = UserService().currentUserId ?? 'guest';

      final results = await AIFloristService().recommend(
        occasion: _selectedOccasion ?? 'Birthday',
        colors: _selectedColors,
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
          const SnackBar(
            content: Text('Failed to generate. Check your connection.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sendToFlorist(Map<String, dynamic> bouquet) {
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
            const Text(
              'Request sent!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Our florist will contact you shortly to confirm the order for "${bouquet['name'] ?? 'Bouquet'}"',
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
                child: const Text('Great!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'AI Bouquet',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Индикатор шагов
          _buildStepIndicator(),

          Expanded(
            child: _currentStep == 0
                ? _buildParametersStep()
                : _buildGenerationStep(),
          ),

          // Кнопка внизу
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          _buildStepDot(0, 'Parameters'),
          Expanded(
            child: Container(
              height: 2,
              color: _currentStep >= 1 ? const Color(0xFFB07183) : Colors.grey[200],
            ),
          ),
          _buildStepDot(1, 'Result'),
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

  Widget _buildParametersStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customize your bouquet',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Select flowers, occasion and budget',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // NLP Input
          _buildSectionTitle('Describe your dream bouquet'),
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
                      hintText: 'e.g., Soft pink roses under 20k',
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

          // Occasion
          _buildSectionTitle('Occasion'),
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
                value: _selectedOccasion,
                hint: const Text('Select occasion'),
                isExpanded: true,
                items: _occasions.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                onChanged: (value) => setState(() => _selectedOccasion = value),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Colors
          _buildSectionTitle('Colors'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _colors.map((color) {
              final isSelected = _selectedColors.contains(color);
              return _buildChip(color, isSelected, () {
                setState(() {
                  isSelected ? _selectedColors.remove(color) : _selectedColors.add(color);
                });
              });
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Size
          _buildSectionTitle('Size'),
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

          // Budget
          _buildSectionTitle('Budget (₸)'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildBudgetField(_budgetFromController, 'From')),
              const SizedBox(width: 12),
              Expanded(child: _buildBudgetField(_budgetToController, 'Up to')),
            ],
          ),

          const SizedBox(height: 24),

          // Flowers to include
          _buildSectionTitle('Flowers to include'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._flowersToInclude.map((f) => _buildRemovableChip(f, () {
                setState(() => _flowersToInclude.remove(f));
              })),
              _buildAddChip(() => _showFlowerSelector('include')),
            ],
          ),

          const SizedBox(height: 24),

          // Flowers to avoid
          _buildSectionTitle('Flowers to avoid'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._flowersToAvoid.map((f) => _buildRemovableChip(f, () {
                setState(() => _flowersToAvoid.remove(f));
              })),
              _buildAddChip(() => _showFlowerSelector('avoid')),
            ],
          ),

          const SizedBox(height: 24),

          // External results
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('Include results from Wolt/2GIS'),
              Switch(
                value: _includeExternal,
                onChanged: (val) => setState(() => _includeExternal = val),
                activeColor: const Color(0xFFB07183),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildGenerationStep() {
    if (_isGenerating) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFB07183)),
            SizedBox(height: 16),
            Text(
              'Generating your bouquet...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
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
          const Text(
            'Your bouquets',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose the one you like and send it to the florist',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ..._generatedBouquets.map((bouquet) => _buildBouquetCard(bouquet)),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: _generate,
              child: const Text(
                'Regenerate bouquets',
                style: TextStyle(
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

  Widget _buildBouquetCard(Map<String, dynamic> bouquet) {
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
          // Изображение из catalog_image URL или заглушка
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: bouquet['catalog_image'] != null && bouquet['catalog_image'].toString().startsWith('http')
                ? Image.network(
              bouquet['catalog_image'],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
            )
                : _buildImagePlaceholder(),
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
                const SizedBox(height: 4),
                Text(
                  '${bouquet['flowers'] ?? ''} • ${bouquet['mood'] ?? ''}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (bouquet['style_tag'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB07183).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      bouquet['style_tag'],
                      style: const TextStyle(fontSize: 11, color: Color(0xFFB07183)),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  '${bouquet['price']} ₸',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFB07183)),
                ),
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
                          child: const Text('Send', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
                          child: const Text('3D View', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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

  Widget _buildBottomButton() {
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
            child: const Text('Generate bouquet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

  Widget _buildAddChip(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 14, color: Colors.grey),
            SizedBox(width: 4),
            Text('Add', style: TextStyle(fontSize: 13, color: Colors.grey)),
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

  void _showFlowerSelector(String type) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type == 'include' ? 'Flowers to include' : 'Flowers to avoid',
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
