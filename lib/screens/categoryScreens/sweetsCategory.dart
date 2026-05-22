import 'package:flowery_app/screens/categoryScreens/shopDetail.dart';
import 'package:flutter/material.dart';
import '../../services/productService.dart';
import '../../services/shopService.dart';
import '../mainScreen.dart';
import '../../widgets/flowerCatalogHeader.dart';
import '../../models/product.dart';
import '../../models/shop.dart';

class SweetsCategoryScreen extends StatefulWidget {
  const SweetsCategoryScreen({super.key});

  @override
  State<SweetsCategoryScreen> createState() => _SweetsCategoryScreenState();
}

class _SweetsCategoryScreenState extends State<SweetsCategoryScreen> {
  String _selectedCategory = 'Sweets';
  bool _showSweetsFilterModal = false;
  int _currentFilterTab = 0;

  // Сервисы
  final ProductService _productService = ProductService();
  final ShopService _shopService = ShopService();

  // Данные из Firestore
  List<Shop> _shops = [];
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  // Фильтры
  final List<Map<String, dynamic>> _includedSweets = [
    {'name': 'Chocolate', 'selected': false},
    {'name': 'Macarons', 'selected': false},
    {'name': 'Cupcakes', 'selected': false},
    {'name': 'Cookies', 'selected': false},
    {'name': 'Candy', 'selected': false},
    {'name': 'Marshmallows', 'selected': false},
    {'name': 'Caramel', 'selected': false},
    {'name': 'Nuts', 'selected': false},
    {'name': 'Berries', 'selected': false},
    {'name': 'Honey', 'selected': false},
  ];

  final List<Map<String, dynamic>> _excludedSweets = [
    {'name': 'Chocolate', 'selected': false},
    {'name': 'Macarons', 'selected': false},
    {'name': 'Cupcakes', 'selected': false},
    {'name': 'Cookies', 'selected': false},
    {'name': 'Candy', 'selected': false},
    {'name': 'Marshmallows', 'selected': false},
    {'name': 'Caramel', 'selected': false},
    {'name': 'Nuts', 'selected': false},
    {'name': 'Berries', 'selected': false},
    {'name': 'Honey', 'selected': false},
  ];

  static const List<Map<String, String>> _sweetsCategories = [
    {
      'name': 'Sweets',
      'image': 'assets/flowers/homeScreen/sweetsCategories.png',
    },
    {
      'name': 'Cakes',
      'image': 'assets/flowers/homeScreen/sweetsCategories.png',
    },
    {
      'name': 'Macarons',
      'image': 'assets/flowers/homeScreen/sweetsCategories.png',
    },
    {
      'name': 'Chocolate',
      'image': 'assets/flowers/homeScreen/sweetsCategories.png',
    },
    {
      'name': 'Cupcakes',
      'image': 'assets/flowers/homeScreen/sweetsCategories.png',
    },
    {
      'name': 'Cookies',
      'image': 'assets/flowers/homeScreen/sweetsCategories.png',
    },
    {
      'name': 'Candy',
      'image': 'assets/flowers/homeScreen/sweetsCategories.png',
    },
    {
      'name': 'Gift boxes',
      'image': 'assets/flowers/homeScreen/sweetsCategories.png',
    },
  ];

  static const List<String> _sweetsFilters = [
    'Price',
    'Free delivery',
    'Sweets type',
    'Delivery time',
    'Gift box',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ✅ Загрузка данных из Firestore
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Загружаем товары по категории
      final products = await _productService
          .getProductsByCategory(_selectedCategory.toLowerCase());

      // Группируем товары по магазинам
      final shopIds = products.map((p) => p.shopId).toSet();
      final shops = <Shop>[];

      for (var shopId in shopIds) {
        final shop = await _shopService.getShopById(shopId);
        if (shop != null) shops.add(shop);
      }

      setState(() {
        _products = products;
        _shops = shops;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load data';
        _isLoading = false;
      });
      print('❌ Error loading data: $e');
    }
  }

  // ✅ Перезагрузка при смене категории
  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadData();
  }

  // ✅ Применение фильтров
  void _applySweetsFilters() {
    final included = _includedSweets
        .where((sweet) => sweet['selected'] == true)
        .map((sweet) => sweet['name'] as String)
        .toList();
    final excluded = _excludedSweets
        .where((sweet) => sweet['selected'] == true)
        .map((sweet) => sweet['name'] as String)
        .toList();

    // 🔹 Здесь можно добавить фильтрацию на стороне клиента или сервера
    // Для простоты пока просто закрываем модалку
    setState(() => _showSweetsFilterModal = false);

    print('🔍 Filters applied: included=$included, excluded=$excluded');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                FlowerCatalogHeader(
                  title: _selectedCategory == 'Sweets'
                      ? 'Sweets and gifts'
                      : _selectedCategory,
                  onBackTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  ),
                  onCategoryTap: _onCategoryChanged, // ✅ Обновлённый колбэк
                  onFlowerTypeTap: () {
                    setState(() => _showSweetsFilterModal = true);
                  },
                  selectedCategory: _selectedCategory,
                  categories: _sweetsCategories,
                  filters: _sweetsFilters,
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(_error!,
                                      style:
                                          const TextStyle(color: Colors.red)),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _loadData,
                                    child: const Text('Retry'),
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
          if (_showSweetsFilterModal) ...[
            GestureDetector(
              onTap: () => setState(() => _showSweetsFilterModal = false),
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
                child: _buildSweetsFilterModal(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSweetsFilterModal() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _showSweetsFilterModal = false),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              const Text(
                'Included sweets',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                      'Includes',
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
                      'Excludes',
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
                ? _includedSweets.length
                : _excludedSweets.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final sweets =
                  _currentFilterTab == 0 ? _includedSweets : _excludedSweets;
              return _buildSweetsFilterItem(sweets[index]);
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
                _applySweetsFilters();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB07183),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Apply filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSweetsFilterItem(Map<String, dynamic> sweet) {
    return CheckboxListTile(
      value: sweet['selected'],
      onChanged: (value) {
        setState(() => sweet['selected'] = value ?? false);
      },
      title: Text(
        sweet['name'],
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      checkboxShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      activeColor: const Color(0xFFB07183),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildShopsSection() {
    // Если нет товаров для категории
    if (_products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.cake_outlined, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No products available for $_selectedCategory',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Группируем товары по магазинам
    final shopsWithProducts = <Shop, List<Product>>{};
    for (var product in _products) {
      final shop = _shops.firstWhere((s) => s.id == product.shopId,
          orElse: () => _shops.first);
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
            '${shopsWithProducts.length} shop${shopsWithProducts.length != 1 ? 's' : ''} nearby',
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

  // ✅ Карточка магазина с реальными данными
  Widget _buildShopCard(Shop shop, List<Product> products) {
    // Берём первые 6 товаров для сетки
    final displayProducts = products.take(6).toList();

    return GestureDetector(
      onTap: () {
        // Переход на страницу магазина
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
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Сетка товаров 2x3 (только если есть товары)
                if (displayProducts.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // Первый ряд
                        Row(
                          children: [
                            Expanded(
                                child:
                                    _buildProductGridItem(displayProducts[0])),
                            if (displayProducts.length > 1) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                  child: _buildProductGridItem(
                                      displayProducts[1])),
                            ],
                            if (displayProducts.length > 2) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                  child: _buildProductGridItem(
                                      displayProducts[2])),
                            ],
                          ],
                        ),
                        if (displayProducts.length > 3)
                          const SizedBox(height: 8),
                        // Второй ряд
                        if (displayProducts.length > 3)
                          Row(
                            children: [
                              Expanded(
                                  child: _buildProductGridItem(
                                      displayProducts[3])),
                              if (displayProducts.length > 4) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                    child: _buildProductGridItem(
                                        displayProducts[4])),
                              ],
                              if (displayProducts.length > 5) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                    child: _buildProductGridItem(
                                        displayProducts[5])),
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
                      // Название и время доставки
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            shop.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Today, 8:00-10:00', // 🔹 Можно добавить поле deliveryTime в модель Shop
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Категория
                      Text(
                        '${_selectedCategory.toUpperCase()} | ASTANA | DELIVERY',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      // Рейтинг и доставка
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${shop.rating}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          Text(
                            ' (${shop.reviews})',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12),
                          ),
                          const Spacer(),
                          const Icon(Icons.local_shipping, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            shop.freeDelivery ? 'Free' : 'Paid',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Сердечко в правом верхнем углу
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  // 🔹 Для магазинов нужно отдельное поле в User модели
                  // Пока показываем заглушку
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Shop favorites coming soon!')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
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
                  ? Image.network(
                      product.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.cake_outlined,
                              color: Colors.grey, size: 40),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                    )
                  : const Icon(Icons.cake_outlined,
                      color: Colors.grey, size: 40),
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
                  product.formattedPrice, // ✅ "42480 ₸"
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
