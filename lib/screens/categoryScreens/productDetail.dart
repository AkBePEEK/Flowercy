import 'package:flutter/material.dart';
import 'package:flowery_app/screens/categoryScreens/shopDetail.dart';
import '../../models/cartItem.dart';
import '../../services/productService.dart';
import '../../services/shopService.dart';
import '../../models/product.dart';
import '../../models/shop.dart';
import '../../services/userService.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService _productService = ProductService();
  final ShopService _shopService = ShopService();
  final UserService _userService = UserService();

  // ✅ Состояния данных
  Product? _product;
  Shop? _shop;
  bool _isLoading = true;
  String? _error;

  // ✅ UI состояния
  int _selectedImage = 0;
  int _quantity = 1;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkIfFavorite();
  }

  // ✅ Загрузка данных продукта и магазина
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. Загружаем продукт
      final product = await _productService.getProductById(widget.productId);
      if (product == null) {
        throw Exception('Product not found');
      }

      // 2. Загружаем магазин этого продукта
      final shop = await _shopService.getShopById(product.shopId);

      setState(() {
        _product = product;
        _shop = shop;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load product';
        _isLoading = false;
      });
      print('❌ Error loading product: $e');
    }
  }

  // ✅ Проверка, в избранном ли товар
  Future<void> _checkIfFavorite() async {
    final isFav = await _userService.isFavorite(widget.productId);
    setState(() => _isFavorite = isFav);
  }

  // ✅ Переключение избранного
  Future<void> _toggleFavorite() async {
    try {
      if (_isFavorite) {
        await _userService.removeFromFavorites(widget.productId);
      } else {
        await _userService.addToFavorites(widget.productId);
      }
      setState(() => _isFavorite = !_isFavorite);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite
              ? 'Added to favorites ❤️'
              : 'Removed from favorites'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('❌ Error toggling favorite: $e');
    }
  }

  // ✅ Добавление в корзину
  Future<void> _addToCart() async {
    if (_product == null) return;

    try {
      await _userService.addToCart(CartItem(
        productId: _product!.id,
        name: _product!.name,
        price: _product!.price,
        quantity: _quantity,
        image: _product!.images.isNotEmpty ? _product!.images.first : null,
        shopId: _product!.shopId,
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $_quantity item(s) to cart'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add to cart'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _product == null
          ? const Center(child: Text('Product not found'))
          : Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Главное изображение
                Stack(
                  children: [
                    Container(
                      height: 400,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      child: _product!.images.isNotEmpty
                          ? Image.network(
                        _product!.images[_selectedImage],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.local_florist, size: 100, color: Colors.grey),
                          );
                        },
                      )
                          : const Icon(Icons.local_florist, size: 100, color: Colors.grey),
                    ),

                    // Кнопки вверху
                    Positioned(
                      top: 40,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCircleButton(Icons.close, () => Navigator.pop(context)),
                          Row(
                            children: [
                              _buildCircleButton(Icons.share, () {}),
                              const SizedBox(width: 8),
                              _buildCircleButton(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                _toggleFavorite,
                                color: _isFavorite ? const Color(0xFFB07183) : Colors.black87,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Размеры (если есть в модели)
                    if (_product != null) ...[
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Column(
                          children: [
                            _buildSizeBadge('55 cm', 'width'),
                            const SizedBox(height: 4),
                            _buildSizeBadge('60 cm', 'height'),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                // Миниатюры
                if (_product!.images.length > 1)
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _product!.images.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final isSelected = _selectedImage == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedImage = index),
                          child: Container(
                            width: 70,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? const Color(0xFFB07183) : Colors.grey[300]!,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                _product!.images[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Название
                      Text(
                        _product!.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),

                      const SizedBox(height: 16),

                      // Информация о доставке
                      _buildInfoRow(Icons.local_shipping, 'Free delivery in 2 hours'),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.favorite, '${_product!.reviews} people added to favorites'),
                      if (_product!.inStock) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.verified_user, 'Verified availability', color: Colors.green),
                      ],

                      const SizedBox(height: 24),

                      // Состав (если есть в модели)
                      if (_product!.description.isNotEmpty) ...[
                        const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Text(
                          _product!.description,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Размеры
                      const Text('Size', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildSizeInfo('Width 55 cm'),
                          const SizedBox(width: 16),
                          _buildSizeInfo('Height 60 cm'),
                        ],
                      ),

                      const SizedBox(height: 32),
                      Divider(color: Colors.grey[200]),
                      const SizedBox(height: 24),

                      // Информация о магазине
                      _buildShopSection(),

                      const SizedBox(height: 24),
                      Divider(color: Colors.grey[200]),
                      const SizedBox(height: 24),

                      // Защита покупателя
                      _buildProtectionSection(),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Нижняя панель с кнопкой
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ... (остальные методы _buildCircleButton, _buildSizeBadge, _buildInfoRow,
  // _buildSizeInfo, _buildShopSection, _buildProtectionSection, _buildBottomBar
  // остаются практически без изменений, только используют _product! и _shop! вместо заглушек)

  Widget _buildShopSection() {
    if (_shop == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFB07183).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _shop!.image.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(_shop!.image, fit: BoxFit.cover),
              )
                  : const Icon(Icons.store, size: 30, color: Color(0xFFB07183)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _shop!.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShopDetailScreen(shopId: _shop!.id),
                        ),
                      );
                    },
                    child: const Text(
                      'Go to store',
                      style: TextStyle(fontSize: 13, color: Color(0xFFB07183), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            onPressed: () {
              // Contact shop
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFB07183)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Contact shop',
              style: TextStyle(color: Color(0xFFB07183), fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            const Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              '${_shop!.rating}/5 rating',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.chat_bubble_outline, size: 16),
            const SizedBox(width: 4),
            Text(
              '${_shop!.reviews} review',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
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
          child: Row(
            children: [
              // Quantity selector
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    _buildQuantityButton(Icons.remove, () {
                      if (_quantity > 1) setState(() => _quantity--);
                    }),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '$_quantity',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    _buildQuantityButton(Icons.add, () => setState(() => _quantity++)),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Add to cart button
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _addToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB07183),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Add to cart   ${_product!.price * _quantity} ₸',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
        ),
        child: Icon(icon, size: 20, color: color ?? Colors.black87),
      ),
    );
  }

  Widget _buildSizeBadge(String size, String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(type == 'width' ? Icons.width_full : Icons.height, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(size, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: color ?? Colors.grey[700],
            fontWeight: color != null ? FontWeight.w600 : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSizeInfo(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildProtectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProtectionItem(Icons.shield_outlined, 'Buyer protection',
            'If the item doesn\'t match the description, you can return it at the shop\'s expense or receive a full refund.'),
        const SizedBox(height: 24),
        _buildProtectionItem(Icons.cancel_outlined, 'Cancellation policy',
            'Free cancellation is available until delivery starts. You will receive a full refund.'),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () {},
          child: const Row(
            children: [
              Icon(Icons.flag_outlined, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                'Report this listing',
                style: TextStyle(fontSize: 13, color: Colors.grey, decoration: TextDecoration.underline),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProtectionItem(IconData icon, String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 20, color: Colors.black87),
            ),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 12),
        Text(description, style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4)),
      ],
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(padding: const EdgeInsets.all(12), child: Icon(icon, size: 18, color: Colors.black87)),
    );
  }
}