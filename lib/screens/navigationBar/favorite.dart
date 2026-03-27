import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../models/shop.dart';
import '../../services/productService.dart';
import '../../services/shopService.dart';
import '../../services/userService.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ✅ Сервисы
  final UserService _userService = UserService();
  final ProductService _productService = ProductService();
  final ShopService _shopService = ShopService();

  // ✅ Данные из Firestore
  List<Product> _favoriteProducts = [];
  List<Shop> _favoriteShops = [];

  // ✅ Состояния
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites(); // ✅ Загружаем данные при открытии
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ✅ Загрузка избранного из Firestore
  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. Получаем список избранных товаров (их ID)
      final favoriteIds = await _userService.getFavorites();

      // 2. Загружаем детали каждого товара
      final products = <Product>[];
      for (var id in favoriteIds) {
        final product = await _productService.getProductById(id);
        if (product != null) {
          products.add(product);
        }
      }

      // 🔹 Для магазинов: можно хранить отдельно или фильтровать по категории
      // Пока загружаем все магазины (в реальном проекте добавьте избранное для магазинов)
      final shops = await _shopService.getAllShops();

      setState(() {
        _favoriteProducts = products;
        _favoriteShops = shops.take(3).toList(); // Пример: первые 3 магазина
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load favorites';
        _isLoading = false;
      });
      print('❌ Error loading favorites: $e');
    }
  }

  // ✅ Удаление из избранного
  Future<void> _removeFromFavorites(String productId, String name) async {
    await _userService.removeFromFavorites(productId);
    _loadFavorites(); // Перезагрузить список

    // Показать подтверждение
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name removed from favorites'),
        duration: const Duration(seconds: 2),
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
        title: const Text(
          'Favorites',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // ✅ Кнопка обновления
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
          ),
        ],
      ),
      body: Column(
        children: [
          // Табы
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _tabController.animateTo(0),
                    child: AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, child) {
                        final isSelected = _tabController.index == 0;
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isSelected
                                ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                                : null,
                          ),
                          child: Text(
                            'Bouquets',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? const Color(0xFFB07183) : Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _tabController.animateTo(1),
                    child: AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, child) {
                        final isSelected = _tabController.index == 1;
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isSelected
                                ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                                : null,
                          ),
                          child: Text(
                            'Markets',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? const Color(0xFFB07183) : Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Контент табов
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
                    onPressed: _loadFavorites,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
                : TabBarView(
              controller: _tabController,
              children: [
                // Вкладка Bouquets
                _buildBouquetsTab(),
                // Вкладка Markets
                _buildMarketsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Вкладка с букетами
  Widget _buildBouquetsTab() {
    return _favoriteProducts.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No favorite bouquets yet',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the heart icon on any bouquet to save it',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
        : ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _favoriteProducts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = _favoriteProducts[index];
        return _buildBouquetItem(product);
      },
    );
  }

  // Элемент букета (из модели Product)
  Widget _buildBouquetItem(Product product) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Изображение
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.images.isNotEmpty
                  ? Image.network(
                product.images.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.local_florist, color: Colors.grey);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },
              )
                  : const Icon(Icons.local_florist, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          // Информация
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.formattedPrice, // ✅ "42480 ₸"
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Сердечко (удалить из избранного)
          GestureDetector(
            onTap: () => _removeFromFavorites(product.id, product.name),
            child: const Icon(
              Icons.favorite, // ✅ Заполненное = в избранном
              color: Color(0xFFB07183),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // Вкладка с магазинами
  Widget _buildMarketsTab() {
    return _favoriteShops.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No favorite markets yet',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    )
        : ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _favoriteShops.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final shop = _favoriteShops[index];
        return _buildMarketItem(shop);
      },
    );
  }

  // Элемент магазина (из модели Shop)
  Widget _buildMarketItem(Shop shop) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Изображение
          Container(
            width: 80,
            height: 80,
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
                    child: const Icon(Icons.store, color: Colors.grey),
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
          // Информация
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shop.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text('${shop.rating}/5 rating', style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 8),
                    const Text('•', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                    const Icon(Icons.chat_bubble_outline, size: 14),
                    const SizedBox(width: 4),
                    Text('${shop.reviews} review', style: const TextStyle(fontSize: 13)),
                  ],
                ),
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
                          style: TextStyle(fontSize: 11, color: Colors.green[700], fontWeight: FontWeight.w500),
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
                          style: TextStyle(fontSize: 11, color: Colors.pink[700], fontWeight: FontWeight.w500),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Сердечко (для магазинов можно добавить отдельное избранное)
          GestureDetector(
            onTap: () {
              // В реальном проекте: удалить магазин из избранного
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feature coming soon!')),
              );
            },
            child: const Icon(
              Icons.favorite,
              color: Color(0xFFB07183),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}