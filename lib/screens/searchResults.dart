import 'package:flutter/material.dart';
import '../../models/product.dart';            // ✅ Модель Product
import '../../models/shop.dart';
import '../services/productService.dart';
import '../services/shopService.dart';
import '../services/userService.dart';               // ✅ Модель Shop

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({
    super.key,
    required this.query,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final ProductService _productService = ProductService();
  final ShopService _shopService = ShopService();
  final UserService _userService = UserService();

  // ✅ Данные из Firestore
  List<Product> _products = [];
  Map<String, Shop> _shops = {}; // Map для быстрого доступа по shopId

  // ✅ Избранное
  Set<String> _favoriteProductIds = {};

  // ✅ Состояния
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _performSearch();
    _loadFavorites();
  }

  // ✅ Поиск товаров
  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Ищем товары по названию (query)
      final products = await _productService.searchProducts(widget.query);

      // Загружаем информацию о магазинах
      final shopIds = products.map((p) => p.shopId).toSet();
      final shopsMap = <String, Shop>{};

      for (var shopId in shopIds) {
        final shop = await _shopService.getShopById(shopId);
        if (shop != null) {
          shopsMap[shopId] = shop;
        }
      }

      setState(() {
        _products = products;
        _shops = shopsMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to search products';
        _isLoading = false;
      });
      print('❌ Search error: $e');
    }
  }

  // ✅ Загрузка избранного
  Future<void> _loadFavorites() async {
    try {
      final favorites = await _userService.getFavorites();
      setState(() {
        _favoriteProductIds = favorites.toSet();
      });
    } catch (e) {
      print('❌ Error loading favorites: $e');
    }
  }

  // ✅ Переключение избранного
  Future<void> _toggleFavorite(String productId, String productName) async {
    final isFavorite = _favoriteProductIds.contains(productId);

    try {
      if (isFavorite) {
        await _userService.removeFromFavorites(productId);
        setState(() => _favoriteProductIds.remove(productId));
        _showSnackBar('$productName removed from favorites');
      } else {
        await _userService.addToFavorites(productId);
        setState(() => _favoriteProductIds.add(productId));
        _showSnackBar('$productName added to favorites ❤️');
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFB07183),
              width: 1.5,
            ),
            // ✅ Добавляем тень для объёма (опционально)
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB07183).withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.query,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87, // ✅ Тёмный текст
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey[100], // ✅ Серый фон для кнопки X
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.grey[700], // ✅ Тёмно-серая иконка
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
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
                    onPressed: _performSearch,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Динамический счётчик результатов
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '${_products.length} results found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900],
                      ),
                    ),
                  ),

                  // ✅ Группировка товаров по магазинам
                  ..._buildShopSections(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Построение секций магазинов
  List<Widget> _buildShopSections() {
    // Группируем товары по shopId
    final Map<String, List<Product>> productsByShop = {};
    for (var product in _products) {
      if (!productsByShop.containsKey(product.shopId)) {
        productsByShop[product.shopId] = [];
      }
      productsByShop[product.shopId]!.add(product);
    }

    // Создаём виджеты для каждого магазина
    return productsByShop.entries.map((entry) {
      final shopId = entry.key;
      final products = entry.value;
      final shop = _shops[shopId];

      if (shop == null) return const SizedBox.shrink();

      return _buildShopSection(
        shop: shop,
        products: products,
      );
    }).toList();
  }

  // ✅ Секция магазина с товарами (без отступа снизу)
  Widget _buildShopSection({
    required Shop shop,
    required List<Product> products,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shop Info
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    shop.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.local_florist, color: Colors.grey),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${shop.rating}/5 rating',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 8),
                        const Icon(Icons.chat_bubble_outline, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${shop.reviews} review',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    if (shop.discount != null || shop.freeDelivery) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (shop.discount != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                shop.discount!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          if (shop.freeDelivery)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.pink[50],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Free delivery',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.pink[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        // ✅ Products Grid (убран отступ сверху)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 280,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.7,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(product);
              },
            ),
          ),
        ),
        // ✅ Убран отступ между магазинами (было const SizedBox(height: 10))
      ],
    );
  }

  // ✅ Карточка товара с интерактивным сердечком
  Widget _buildProductCard(Product product) {
    final isFavorite = _favoriteProductIds.contains(product.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: product.images.isNotEmpty
                        ? Image.network(
                      product.images.first,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.local_florist, color: Colors.grey),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                    )
                        : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.local_florist, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              // Price and Name
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ✅ Сердечко в правом верхнем углу
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _toggleFavorite(product.id, product.name),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey<bool>(isFavorite),
                    size: 18,
                    color: isFavorite ? const Color(0xFFB07183) : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}