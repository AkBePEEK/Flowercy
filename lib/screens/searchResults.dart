import 'package:flutter/material.dart';
import 'package:flowery_app/screens/categoryScreens/productDetail.dart';
import 'package:flowery_app/screens/categoryScreens/shopDetail.dart';
import '../../models/product.dart';
import '../../models/shop.dart';
import '../../services/language_service.dart';
import '../../services/productService.dart';
import '../../services/shopService.dart';
import '../../services/userService.dart';
import '../../widgets/universal_image.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({
    super.key,
    required this.query,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> with LanguageStateMixin {
  final ProductService _productService = ProductService();
  final ShopService _shopService = ShopService();
  final UserService _userService = UserService();
  
  // ✅ Добавляем контроллер для управления поиском на этом экране
  late TextEditingController _searchController;

  // ✅ Данные из Firestore
  List<Product> _products = [];
  Map<String, Shop> _shops = {}; // Map для быстрого доступа по shopId

  // ✅ Избранное
  Set<String> _favoriteProductIds = {};

  // ✅ Состояния
  bool _isLoading = true;
  String? _error;
  int _shopMatchesCount = 0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
    _performSearch(_searchController.text);
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ Поиск товаров (теперь принимает query)
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. Ищем товары по названию
      final products = await _productService.searchProducts(query);

      // 2. Ищем магазины по названию
      final allShops = await _shopService.getAllShops();
      final queryLower = query.toLowerCase();
      final matchingShops = allShops.where((s) => s.name.toLowerCase().contains(queryLower)).toList();

      // 3. Загружаем информацию о магазинах для найденных товаров
      final shopIdsForProducts = products.map((p) => p.shopId).toSet();
      final shopsMap = <String, Shop>{};

      for (var shopId in shopIdsForProducts) {
        final shop = await _shopService.getShopById(shopId);
        if (shop != null) {
          shopsMap[shopId] = shop;
        }
      }

      // Добавляем магазины, которые совпали по названию
      for (var shop in matchingShops) {
        shopsMap[shop.id] = shop;
      }

      setState(() {
        _products = products;
        _shops = shopsMap;
        _shopMatchesCount = matchingShops.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to search';
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
    final t = getTranslations();
    final isFavorite = _favoriteProductIds.contains(productId);

    try {
      if (isFavorite) {
        await _userService.removeFromFavorites(productId);
        setState(() => _favoriteProductIds.remove(productId));
        _showSnackBar('$productName ${t('removed_from_favorites_msg')}');
      } else {
        await _userService.addToFavorites(productId);
        setState(() => _favoriteProductIds.add(productId));
        _showSnackBar('$productName ${t('added_to_favorites')} ❤️');
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
    final t = getTranslations();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100), // ✅ Увеличено до 100 для полной видимости тени
        child: AppBar(
          toolbarHeight: 100, // ✅ Явно задаем высоту контента
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(top: 15),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 15, right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFB07183),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB07183).withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 22, color: Color(0xFFB07183)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (value) => _performSearch(value),
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: t('searchHint'),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.clear, size: 14, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
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
                    onPressed: () => _performSearch(_searchController.text),
                    child: Text(t('retry')),
                  ),
                ],
              ),
            )
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '${_products.length + _shopMatchesCount} ${t('results_found')}',
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
    final Map<String, List<Product>> productsByShop = {};
    for (var product in _products) {
      if (!productsByShop.containsKey(product.shopId)) {
        productsByShop[product.shopId] = [];
      }
      productsByShop[product.shopId]!.add(product);
    }

    final Set<String> allShopIds = {...productsByShop.keys, ..._shops.keys};

    return allShopIds.map((shopId) {
      final products = productsByShop[shopId] ?? [];
      final shop = _shops[shopId];

      if (shop == null) return const SizedBox.shrink();

      return _buildShopSection(
        shop: shop,
        products: products,
      );
    }).toList();
  }

  // ✅ Секция магазина с товарами
  Widget _buildShopSection({
    required Shop shop,
    required List<Product> products,
  })
  {
    final t = getTranslations();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ShopDetailScreen(shopId: shop.id)),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
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
                    child: UniversalImage(
                      imagePath: shop.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.store, color: Colors.grey),
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
                            '${shop.rating}/5 ${t('rating')}',
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(width: 8),
                          const Text('•', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 8),
                          const Icon(Icons.chat_bubble_outline, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${shop.reviews} ${t('review')}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),

        if (products.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    final isFavorite = _favoriteProductIds.contains(product.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailScreen(productId: product.id)),
        );
      },
      child: Container(
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
                          ? UniversalImage(
                        imagePath: product.images.first,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.local_florist, color: Colors.grey),
                        ),
                      )
                          : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.local_florist, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
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
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _toggleFavorite(product.id, product.name),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: isFavorite ? const Color(0xFFB07183) : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
