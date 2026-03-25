import 'package:flutter/material.dart';

class FlowerCatalogHeader extends StatelessWidget {
  static const List<Map<String, String>> defaultCategories = [
    {'name': 'Flowers', 'image': 'assets/flowers/flowersCategory/flowers.png'},
    {'name': 'Monobouquets', 'image': 'assets/flowers/flowersCategory/monobouquets.png'},
    {'name': 'Signature', 'image': 'assets/flowers/flowersCategory/signature.png'},
    {'name': 'By the stem', 'image': 'assets/flowers/flowersCategory/byTheStem.png'},
    {'name': 'In a box', 'image': 'assets/flowers/flowersCategory/inBox.png'},
    {'name': 'In a basket', 'image': 'assets/flowers/flowersCategory/inBasket.png'},
    {'name': 'Bridal', 'image': 'assets/flowers/flowersCategory/bridal.png'},
    {'name': 'In a wood box', 'image': 'assets/flowers/flowersCategory/inWoodBox.png'},
  ];

  static const List<String> defaultFilters = [
    'Price',
    'Free delivery',
    'Flowers type',
    'Delivery time',
    'Color',
  ];

  final String title;
  final VoidCallback? onBackTap;
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onCategoryTap;
  final VoidCallback? onFlowerTypeTap; // ✅ Callback для открытия модального окна
  final String? selectedCategory;
  final List<Map<String, String>>? categories;
  final List<String>? filters;

  const FlowerCatalogHeader({
    super.key,
    required this.title,
    this.onBackTap,
    this.onFilterTap,
    this.onCategoryTap,
    this.onFlowerTypeTap,
    this.selectedCategory,
    this.categories,
    this.filters,
  });

  List<Map<String, String>> get _categories => categories ?? defaultCategories;
  List<String> get _filters => filters ?? defaultFilters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 16),
        _buildCategories(),
        const SizedBox(height: 16),
        _buildFilters(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (onBackTap != null)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 24),
              onPressed: onBackTap,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          else
            const SizedBox(width: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              return _buildCategoryItem(
                _categories[index]['name']!,
                _categories[index]['image']!,
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              return _buildCategoryItem(
                _categories[index + 4]['name']!,
                _categories[index + 4]['image']!,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String name, String image) {
    final isSelected = name == selectedCategory;
    return GestureDetector(
      onTap: () => onCategoryTap?.call(name),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: const Color(0xFFB07183), width: 2)
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: isSelected
                        ? const Color(0xFFB07183).withValues(alpha: 0.2)
                        : Colors.grey[200],
                    child: Icon(
                      Icons.local_florist,
                      color: isSelected ? const Color(0xFFB07183) : Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFFB07183) : const Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 16),
            GestureDetector(
              onTap: onFilterTap,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((filter) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildFilterChip(filter),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Text('Reset all', style: TextStyle(fontSize: 13)),
                  SizedBox(width: 4),
                  Icon(Icons.close, size: 14),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    return GestureDetector(
      onTap: label == 'Flowers type' ? onFlowerTypeTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 16),
          ],
        ),
      ),
    );
  }
}