import 'package:flowery_app/screens/categoryScreens/shopDetail.dart';
import 'package:flutter/material.dart';
import '../../services/language_service.dart';
import '../../services/productService.dart';
import '../../services/shopService.dart';
import '../../services/userService.dart';
import '../mainScreen.dart';
import '../../widgets/flowerCatalogHeader.dart';
import '../../models/product.dart';
import '../../models/shop.dart';
import '../../widgets/universal_image.dart';

class FlowerCategoryScreen extends StatefulWidget {
  const FlowerCategoryScreen({super.key});

  @override
  State<FlowerCategoryScreen> createState() => _FlowerCategoryScreenState();
}

class _FlowerCategoryScreenState extends State<FlowerCategoryScreen> with LanguageStateMixin{
  String _selectedCategory = 'flowers';
  bool _showFlowerFilterModal = false;
  int _currentFilterTab = 0;
  Set<String> _favoriteShopIds = {};

  // Сервисы
  final ProductService _productService = ProductService();
  final ShopService _shopService = ShopService();
  final UserService _userService = UserService();

  // Данные из Firestore
  List<Shop> _shops = [];
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  // Фильтры
  final List<Map<String, dynamic>> _includedFlowers = [
    {'key': 'roses', 'selected': false},
    {'key': 'tulips', 'selected': false},
    {'key': 'peonies', 'selected': false},
    {'key': 'peony_roses', 'selected': false},
    {'key': 'chrysanthemums', 'selected': false},
    {'key': 'alstroemerias', 'selected': false},
    {'key': 'amaryllis', 'selected': false},
    {'key': 'anemones', 'selected': false},
    {'key': 'asters', 'selected': false},
    {'key': 'cornflowers', 'selected': false},
    {'key': 'carnations', 'selected': false},
  ];

  final List<Map<String, dynamic>> _excludedFlowers = [
    {'key': 'roses', 'selected': false},
    {'key': 'tulips', 'selected': false},
    {'key': 'peonies', 'selected': false},
    {'key': 'peony_roses', 'selected': false},
    {'key': 'chrysanthemums', 'selected': false},
    {'key': 'alstroemerias', 'selected': false},
    {'key': 'amaryllis', 'selected': false},
    {'key': 'anemones', 'selected': false},
    {'key': 'asters', 'selected': false},
    {'key': 'cornflowers', 'selected': false},
    {'key': 'carnations', 'selected': false},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadFavoriteShops();
  }

  // ✅ Загрузка данных из Firestore
  Future<void> _loadData() async {
    final t = getTranslations();
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Всегда загружаем все цветы основной категории 'flowers'
      final products = await _productService.getProductsByCategory('flowers');

      // Загружаем все магазины
      final shops = await _shopService.getAllShops();

      setState(() {
        _products = products;
        _shops = shops;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = t('error_loading_product');
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFavoriteShops() async {
    final shops = await _userService.getFavoriteShops();
    setState(() => _favoriteShopIds = shops.toSet());
  }

  // ✅ Перезагрузка при смене категории
  void _onCategoryChanged(String categoryKey) {
    setState(() {
      _selectedCategory = categoryKey.toLowerCase();
    });
  }

  // ✅ Применение фильтров
  void _applyFlowerFilters() {
    setState(() => _showFlowerFilterModal = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = getTranslations();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                FlowerCatalogHeader(
                  title: _selectedCategory == 'flowers'
                      ? t('flowers_and_bouquets')
                      : t(_selectedCategory.toLowerCase()),
                  onBackTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  ),
                  onCategoryTap: _onCategoryChanged, // ✅ Обновлённый колбэк
                  onFlowerTypeTap: () {
                    setState(() => _showFlowerFilterModal = true);
                  },
                  selectedCategory: _selectedCategory,
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: Text(t('retry')),
                        ),
                      ],
                    ),
                  )
                      : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildShopsSection(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showFlowerFilterModal) ...[
            GestureDetector(
              onTap: () => setState(() => _showFlowerFilterModal = false),
              child: Container(color: Colors.black.withValues(alpha: 0.5)),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: _buildFlowerFilterModal(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFlowerFilterModal() {
    final t = getTranslations();
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _showFlowerFilterModal = false),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              Text(
                t('included_flowers'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentFilterTab = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _currentFilterTab == 0
                              ? const Color(0xFFB07183)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      t('includes'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _currentFilterTab == 0
                            ? const Color(0xFFB07183)
                            : Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentFilterTab = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _currentFilterTab == 1
                              ? const Color(0xFFB07183)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      t('excludes'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _currentFilterTab == 1
                            ? const Color(0xFFB07183)
                            : Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _currentFilterTab == 0
                ? _includedFlowers.length
                : _excludedFlowers.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final flowers = _currentFilterTab == 0
                  ? _includedFlowers
                  : _excludedFlowers;
              return _buildFlowerFilterItem(flowers[index]);
            },
          ),
        ),
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
            child: ElevatedButton(
              onPressed: () {
                _applyFlowerFilters();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB07183),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                t('apply_filters'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlowerFilterItem(Map<String, dynamic> flower) {
    final t = getTranslations();
    return CheckboxListTile(
      value: flower['selected'],
      onChanged: (value) {
        setState(() => flower['selected'] = value ?? false);
      },
      title: Text(
        t(flower['key']),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      activeColor: const Color(0xFFB07183),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildShopsSection() {
    final t = getTranslations();
    
    // Фильтруем товары по выбранной секции (например, 'monobouquets', 'signature')
    final filteredProducts = _products.where((p) => p.section == _selectedCategory).toList();

    // Если нет товаров для выбранной секции
    if (filteredProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.local_florist, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                '${t('no_products_category')} ${t(_selectedCategory)}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_shops.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Группируем отфильтрованные товары по магазинам
    final shopsWithProducts = <Shop, List<Product>>{};
    for (var product in filteredProducts) {
      final shop = _shops.firstWhere(
            (s) => s.id == product.shopId,
        orElse: () => Shop(
          id: '',
          name: t('unknown'),
          rating: 0,
          reviews: 0,
          image: '',
          address: '',
          phone: '',
        ),
      );
      
      if (!shopsWithProducts.containsKey(shop)) {
        shopsWithProducts[shop] = [];
      }
      shopsWithProducts[shop]!.add(product);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${shopsWithProducts.length} ${t('shops_nearby')}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          // Список магазинов
          ...shopsWithProducts.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildShopCard(entry.key, entry.value),
          )),
        ],
      ),
    );
  }

  // ✅ Карточка магазина с товарами ТОЛЬКО выбранной категории
  Widget _buildShopCard(Shop shop, List<Product> products) {
    final t = getTranslations();
    final displayProducts = products.take(6).toList();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShopDetailScreen(shopId: shop.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Сетка товаров
            if (displayProducts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildProductGridItem(displayProducts[0])),
                        if (displayProducts.length > 1) ...[
                          const SizedBox(width: 8),
                          Expanded(child: _buildProductGridItem(displayProducts[1])),
                        ],
                        if (displayProducts.length > 2) ...[
                          const SizedBox(width: 8),
                          Expanded(child: _buildProductGridItem(displayProducts[2])),
                        ],
                      ],
                    ),
                    if (displayProducts.length > 3) const SizedBox(height: 8),
                    if (displayProducts.length > 3)
                      Row(
                        children: [
                          Expanded(child: _buildProductGridItem(displayProducts[3])),
                          if (displayProducts.length > 4) ...[
                            const SizedBox(width: 8),
                            Expanded(child: _buildProductGridItem(displayProducts[4])),
                          ],
                          if (displayProducts.length > 5) ...[
                            const SizedBox(width: 8),
                            Expanded(child: _buildProductGridItem(displayProducts[5])),
                          ],
                        ],
                      ),
                  ],
                ),
              ),

            // Информация о магазине
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        shop.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${t('today')}, 8:00-10:00',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ASTANA | DELIVERY',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${shop.rating}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Text(
                        ' (${shop.reviews})',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const Spacer(),
                      const Icon(Icons.local_shipping, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        shop.freeDelivery ? t('free_delivery') : t('paid'),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Товар в сетке (из модели Product)
  Widget _buildProductGridItem(Product product) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: Stack(
          children: [
            // Изображение товара
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: product.images.isNotEmpty
                  ? UniversalImage(
                imagePath: product.images.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.local_florist, color: Colors.grey, size: 40),
                  );
                },
                placeholder: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
                  : const Icon(Icons.local_florist, color: Colors.grey, size: 40),
            ),

            // Цена
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  product.formattedPrice,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
