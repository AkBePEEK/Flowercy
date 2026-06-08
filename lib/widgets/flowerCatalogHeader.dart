import 'package:flutter/material.dart';
import '../../services/language_service.dart';
import 'universal_image.dart';

class FlowerCatalogHeader extends StatelessWidget {
  static const List<Map<String, String>> defaultCategories = [
    {'key': 'flowers', 'image': 'assets/flowers/flowersCategory/flowers.png'},
    {'key': 'monobouquets', 'image': 'assets/flowers/flowersCategory/monobouquets.png'},
    {'key': 'signature', 'image': 'assets/flowers/flowersCategory/signature.png'},
    {'key': 'by_the_stem', 'image': 'assets/flowers/flowersCategory/byTheStem.png'},
    {'key': 'in_a_box', 'image': 'assets/flowers/flowersCategory/inBox.png'},
    {'key': 'in_a_basket', 'image': 'assets/flowers/flowersCategory/inBasket.png'},
    {'key': 'bridal', 'image': 'assets/flowers/flowersCategory/bridal.png'},
    {'key': 'in_a_wood_box', 'image': 'assets/flowers/flowersCategory/inWoodBox.png'},
  ];

  static const List<String> defaultFilters = [
    'price_filter',
    'free_delivery',
    'flowers_type',
    'delivery_time',
    'color',
  ];

  final String title;
  final VoidCallback? onBackTap;
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onCategoryTap;
  final VoidCallback? onFlowerTypeTap;
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
    final totalItems = _categories.length;
    final itemsInFirstRow = totalItems > 4 ? 4 : totalItems;
    final itemsInSecondRow = totalItems > 4 ? (totalItems - 4 > 4 ? 4 : totalItems - 4) : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (itemsInFirstRow > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(itemsInFirstRow, (index) {
                final item = _categories[index];
                return _buildCategoryItem(
                  item['key'] ?? 'unknown',
                  item['image'] ?? '',
                );
              }),
            ),
          if (itemsInSecondRow > 0) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(itemsInSecondRow, (index) {
                final item = _categories[index + 4];
                return _buildCategoryItem(
                  item['key'] ?? 'unknown',
                  item['image'] ?? '',
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String key, String image) {
    final t = getTranslations();
    final isSelected = key == selectedCategory;
    return GestureDetector(
      onTap: () => onCategoryTap?.call(key),
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
              child: UniversalImage(
                imagePath: image,
                fit: BoxFit.cover,
                errorBuilder: (_,__,___) => _buildPlaceholder(isSelected),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t(key),
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFFB07183)
                  : const Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(bool isSelected) {
    return Container(
      color: isSelected
          ? const Color(0xFFB07183).withValues(alpha: 0.2)
          : Colors.grey[200],
      child: Icon(
        Icons.local_florist,
        color: isSelected ? const Color(0xFFB07183) : Colors.grey,
      ),
    );
  }

  Widget _buildFilters() {
    final t = getTranslations();
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
              child: Row(
                children: [
                  Text(t('reset_all'), style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  const Icon(Icons.close, size: 14),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String filterKey) {
    final t = getTranslations();
    final opensTypeFilter = filterKey == 'flowers_type' || filterKey == 'sweets_type';

    return GestureDetector(
      onTap: opensTypeFilter ? onFlowerTypeTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t(filterKey), style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 16),
          ],
        ),
      ),
    );
  }
}
