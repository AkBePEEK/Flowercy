import 'package:flowery_app/screens/categoryScreens/shopDetail.dart';
import 'package:flutter/material.dart';

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
  int _selectedImage = 0;
  int _quantity = 1;
  final int _price = 57750;

  final List<String> _images = [
    'assets/flowers/products/pink_roses.png',
    'assets/flowers/products/red_roses.png',
    'assets/flowers/products/white_roses.png',
    'assets/flowers/products/pink_roses.png',
    'assets/flowers/products/red_roses.png',
  ];

  final Map<String, dynamic> _product = {
    'title': 'Misty peony rose bundle with eucalyptus',
    'delivery': 'Free delivery in 2 hours',
    'favorites': 2,
    'verified': true,
    'composition': [
      {'name': 'Eucalyptus', 'count': '5 pcs.'},
      {'name': 'Peony Roses', 'count': '25 pcs.'},
    ],
    'size': {
      'width': '55 cm',
      'height': '60 cm',
    },
    'shop': {
      'name': 'Romantic',
      'rating': 4.7,
      'reviews': 676,
      'sales': 1215,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
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
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                      ),
                      child: Image.asset(
                        _images[_selectedImage],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.local_florist,
                              size: 100,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
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
                              _buildCircleButton(Icons.favorite_border, () {}),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Размеры
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
                ),

                // Миниатюры
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isSelected = _selectedImage == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImage = index;
                          });
                        },
                        child: Container(
                          width: 70,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFB07183)
                                  : Colors.grey[300]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              _images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(color: Colors.grey[300]);
                              },
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
                        _product['title'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Информация о доставке
                      _buildInfoRow(Icons.local_shipping, _product['delivery']),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.favorite,
                        '${_product['favorites']} people added to favorites',
                      ),
                      if (_product['verified']) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.verified_user, 'Verified availability',
                            color: Colors.green),
                      ],

                      const SizedBox(height: 24),

                      // Состав
                      const Text(
                        'Composition',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...(_product['composition'] as List).map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              item['count'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )),

                      const SizedBox(height: 24),

                      // Размеры
                      const Text(
                        'Size',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildSizeInfo('Width ${_product['size']['width']}'),
                          const SizedBox(width: 16),
                          _buildSizeInfo('Height ${_product['size']['height']}'),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Разделитель
                      Divider(color: Colors.grey[200]),
                      const SizedBox(height: 24),

                      // Информация о магазине
                      _buildShopSection(),

                      const SizedBox(height: 24),

                      // Разделитель
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

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
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
          Icon(
            type == 'width' ? Icons.width_full : Icons.height,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            size,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
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
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildShopSection() {
    final shop = _product['shop'] as Map<String, dynamic>;

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
              child: const Icon(
                Icons.store,
                size: 30,
                color: Color(0xFFB07183),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShopDetailScreen(shopId: 'shop_1'),
                        ),
                      );
                    },
                    child: const Text(
                      'Go to store',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFB07183),
                        fontWeight: FontWeight.w500,
                      ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Contact shop',
              style: TextStyle(
                color: Color(0xFFB07183),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            const Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              '${shop['rating']}/5 rating',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.chat_bubble_outline, size: 16),
            const SizedBox(width: 4),
            Text(
              '${shop['reviews']} review',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.shopping_bag, size: 16),
            const SizedBox(width: 4),
            Text(
              '${shop['sales']} sales',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProtectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shield_outlined,
                size: 20,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Buyer protection',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Text(
          'If the item doesn\'t match the description, you can return it at the shop\'s expense or receive a full refund.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),

        const SizedBox(height: 24),

        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.cancel_outlined,
                size: 20,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Cancellation policy',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Text(
          'Free cancellation is available until delivery starts. You will receive a full refund.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),

        const SizedBox(height: 24),

        GestureDetector(
          onTap: () {
            // Report listing
          },
          child: const Row(
            children: [
              Icon(Icons.flag_outlined, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                'Report this listing',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
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
                      if (_quantity > 1) {
                        setState(() => _quantity--);
                      }
                    }),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '$_quantity',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _buildQuantityButton(Icons.add, () {
                      setState(() => _quantity++);
                    }),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Add to cart button
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add to cart
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added $_quantity item(s) to cart'),
                          backgroundColor: Colors.green,
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
                    child: Text(
                      'Add to cart   ${_price * _quantity} ₸',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }
}