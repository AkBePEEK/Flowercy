import 'package:flutter/material.dart';
import 'package:flowery_app/screens/categoryScreens/productDetail.dart';
import '../../services/productService.dart';
import '../../services/shopService.dart';
import '../../services/userService.dart';
import '../../models/shop.dart';
import '../../models/product.dart';

class ShopDetailScreen extends StatefulWidget {
  final String shopId;

  const ShopDetailScreen({super.key, required this.shopId});

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  final ShopService _shopService = ShopService();
  final ProductService _productService = ProductService();
  final UserService _userService = UserService();

  // ✅ Состояния данных
  Shop? _shop;
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  // ✅ UI состояния
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ✅ Загрузка данных магазина и его товаров
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. Загружаем магазин
      final shop = await _shopService.getShopById(widget.shopId);
      if (shop == null) throw Exception('Shop not found');

      // 2. Загружаем товары этого магазина
      final products = await _productService.getProductsByShop(widget.shopId);

      setState(() {
        _shop = shop;
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load shop';
        _isLoading = false;
      });
      print('❌ Error loading shop: $e');
    }
  }

  // ✅ Переключение избранного для магазина (опционально)
  Future<void> _toggleFavorite() async {
    setState(() => _isFavorite = !_isFavorite);
    // 🔹 Здесь можно добавить логику избранного для магазинов
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      )
          : _shop == null
          ? const Center(child: Text('Shop not found'))
          : CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? const Color(0xFFB07183) : Colors.grey,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
            title: const Text(
              'Shop',
              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            pinned: true,
          ),

          // Shop Header
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Shop Logo & Name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB07183).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: _shop!.image.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(_shop!.image, fit: BoxFit.cover),
                        )
                            : const Icon(Icons.store, size: 50, color: Color(0xFFB07183)),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        _shop!.name,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                      ),

                      const SizedBox(height: 12),

                      // Rating & Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, size: 18, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${_shop!.rating}/5',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${_shop!.reviews} reviews',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Contact button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text(
                            'Contact shop',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFB07183)),
                            foregroundColor: const Color(0xFFB07183),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      Divider(color: Colors.grey[200]),
                      const SizedBox(height: 24),

                      // Shop Info
                      _buildInfoCard(Icons.description, 'About', _shop!.address),
                      const SizedBox(height: 12),
                      _buildInfoCard(Icons.location_on, 'Address', _shop!.address),
                      const SizedBox(height: 12),
                      _buildInfoCard(Icons.access_time, 'Working hours', '9:00 - 21:00'),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        Icons.local_shipping,
                        'Delivery',
                        _shop!.freeDelivery ? 'Free delivery in 2 hours' : 'Paid delivery',
                        valueColor: Colors.green,
                      ),

                      const SizedBox(height: 32),

                      // Products Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Products',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '${_products.length} items',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Products Grid
                if (_products.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No products yet',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(_products[index]);
                      },
                    ),
                  ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: Colors.grey[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor ?? Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
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
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: product.images.isNotEmpty
                      ? Image.network(
                    product.images.first,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.local_florist, color: Colors.grey),
                    ),
                  )
                      : Container(color: Colors.grey[300], child: const Icon(Icons.local_florist, color: Colors.grey)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text('${product.rating}', style: const TextStyle(fontSize: 11)),
                      const Spacer(),
                      Text('${product.reviews} sales', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${product.price} ₸',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFFB07183)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}