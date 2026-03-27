import 'package:flutter/material.dart';
import 'generatedBouquet.dart';

class BouquetCraftingScreen extends StatefulWidget {
  final String description;

  const BouquetCraftingScreen({
    super.key,
    required this.description,
  });

  @override
  State<BouquetCraftingScreen> createState() => _BouquetCraftingScreenState();
}

class _BouquetCraftingScreenState extends State<BouquetCraftingScreen> {
  String? _selectedOccasion;
  List<String> _selectedColors = [];
  List<String> _selectedMoods = [];
  String? _selectedSize;
  final TextEditingController _budgetFromController = TextEditingController();
  final TextEditingController _budgetToController = TextEditingController();
  List<String> _flowersToInclude = ['Tulips', 'Roses', 'Daisies'];
  List<String> _flowersToAvoid = ['Lilies'];

  final List<String> _occasions = [
    'March 8th',
    'Birthday',
    'Anniversary',
    'Valentine\'s Day',
    'Thank you',
    'Congratulations',
  ];

  final List<String> _colors = ['Pink', 'Red', 'White', 'Yellow', 'Purple', 'Mixed'];
  final List<String> _moods = ['Tender', 'Spring', 'Minimalistic', 'Luxurious', 'Romantic', 'Cheerful'];
  final List<String> _sizes = ['S', 'M', 'L'];
  final List<String> _allFlowers = [
    'Roses', 'Tulips', 'Peonies', 'Lilies', 'Daisies',
    'Orchids', 'Carnations', 'Chrysanthemums', 'Hydrangeas'
  ];

  @override
  void dispose() {
    _budgetFromController.dispose();
    _budgetToController.dispose();
    super.dispose();
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Customize bouquet',
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Подзаголовок
                    Text(
                      'Let\'s refine your preferences for the perfect bouquet',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
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
                          items: _occasions.map((occasion) {
                            return DropdownMenuItem(
                              value: occasion,
                              child: Text(occasion),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedOccasion = value;
                            });
                          },
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
                            if (isSelected) {
                              _selectedColors.remove(color);
                            } else {
                              _selectedColors.add(color);
                            }
                          });
                        });
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Mood
                    _buildSectionTitle('Mood'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _moods.map((mood) {
                        final isSelected = _selectedMoods.contains(mood);
                        return _buildChip(mood, isSelected, () {
                          setState(() {
                            if (isSelected) {
                              _selectedMoods.remove(mood);
                            } else {
                              _selectedMoods.add(mood);
                            }
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
                              onPressed: () {
                                setState(() {
                                  _selectedSize = size;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected
                                    ? const Color(0xFFB07183)
                                    : Colors.grey[100],
                                foregroundColor: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(size),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Budget
                    _buildSectionTitle('Budget'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildBudgetField(_budgetFromController, 'From'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildBudgetField(_budgetToController, 'Up to'),
                        ),
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
                        ..._flowersToInclude.map((flower) => _buildRemovableChip(flower, () {
                          setState(() {
                            _flowersToInclude.remove(flower);
                          });
                        })),
                        _buildAddMoreChip(() {
                          _showFlowerSelector('include');
                        }),
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
                        ..._flowersToAvoid.map((flower) => _buildRemovableChip(flower, () {
                          setState(() {
                            _flowersToAvoid.remove(flower);
                          });
                        })),
                        _buildAddMoreChip(() {
                          _showFlowerSelector('avoid');
                        }),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Кнопка Generate
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GeneratedBouquetsScreen(
                            description: widget.description,
                            occasion: _selectedOccasion,
                            colors: _selectedColors,
                            moods: _selectedMoods,
                            size: _selectedSize,
                          ),
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
                      'Generate bouquet',
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFB07183)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFFB07183),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 14,
              color: Color(0xFFB07183),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMoreChip(VoidCallback onTap) {
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
            Icon(
              Icons.add,
              size: 14,
              color: Colors.grey,
            ),
            SizedBox(width: 4),
            Text(
              'Add more',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allFlowers.map((flower) {
                final isInList = type == 'include'
                    ? _flowersToInclude.contains(flower)
                    : _flowersToAvoid.contains(flower);

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
                      color: isInList
                          ? const Color(0xFFB07183)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      flower,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isInList ? Colors.white : Colors.grey[700],
                      ),
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