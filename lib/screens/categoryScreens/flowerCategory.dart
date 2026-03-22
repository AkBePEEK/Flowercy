import 'package:flutter/material.dart';
import '../home.dart';
import '../../widgets/flowerCatalogHeader.dart'; // <-- Импорт нового виджета

class FlowerCategoryScreen extends StatefulWidget {
  const FlowerCategoryScreen({super.key});

  @override
  State<FlowerCategoryScreen> createState() => _FlowerCategoryScreenState();
}

class _FlowerCategoryScreenState extends State<FlowerCategoryScreen> {
  String _selectedCategory = 'Flowers';

  final Map<String, List<Map<String, dynamic>>> _shopsByCategory = {
    'Flowers': [
      {
        'name': 'Lui buton',
        'category': 'FLOWERS | ASTANA | DELIVERY',
        'deliveryTime': 'TOMORROW FROM 10:00',
        'rating': 4.81,
        'reviews': 711,
        'delivery': 'Free',
        'products': [
          {'price': '14 500 ₸', 'image': 'assets/products/bouquet1.png'},
          {'price': '7 000 ₸', 'image': 'assets/products/bouquet2.png'},
          {'price': '22 000 ₸', 'image': 'assets/products/bouquet3.png'},
          {'price': '24 000 ₸', 'image': 'assets/products/bouquet4.png'},
          {'price': '32 500 ₸', 'image': 'assets/products/bouquet5.png'},
          {'price': '19 500 ₸', 'image': 'assets/products/bouquet6.png'},
        ],
      },
    ],
    'Monobouquets': [
      {
        'name': 'Rose Garden',
        'category': 'MONOBOUQUETS | ASTANA | DELIVERY',
        'deliveryTime': 'TODAY FROM 12:00',
        'rating': 4.90,
        'reviews': 432,
        'delivery': 'Free',
        'products': [
          {'price': '18 000 ₸', 'image': 'assets/products/bouquet1.png'},
          {'price': '25 000 ₸', 'image': 'assets/products/bouquet2.png'},
          {'price': '30 000 ₸', 'image': 'assets/products/bouquet3.png'},
          {'price': '15 000 ₸', 'image': 'assets/products/bouquet4.png'},
          {'price': '22 000 ₸', 'image': 'assets/products/bouquet5.png'},
          {'price': '28 000 ₸', 'image': 'assets/products/bouquet6.png'},
        ],
      },
    ],
    'Signature': [
      {
        'name': 'Signature Flowers',
        'category': 'SIGNATURE | ASTANA | DELIVERY',
        'deliveryTime': 'TOMORROW FROM 14:00',
        'rating': 4.75,
        'reviews': 289,
        'delivery': 'Free',
        'products': [
          {'price': '35 000 ₸', 'image': 'assets/products/bouquet1.png'},
          {'price': '42 000 ₸', 'image': 'assets/products/bouquet2.png'},
          {'price': '38 000 ₸', 'image': 'assets/products/bouquet3.png'},
          {'price': '45 000 ₸', 'image': 'assets/products/bouquet4.png'},
          {'price': '40 000 ₸', 'image': 'assets/products/bouquet5.png'},
          {'price': '50 000 ₸', 'image': 'assets/products/bouquet6.png'},
        ],
      },
    ],
    // Добавьте остальные категории по аналогии...
  };

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ Реюзабельный хедер (всё выше — в одном виджете!)
            FlowerCatalogHeader(
              title: 'Flowers and bouquets',
              onBackTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              ),
              onFilterTap: () {
                // Логика открытия фильтра
                print('Фильтр нажат');
              },
              onCategoryTap: (category) {
                setState(() {
                  _selectedCategory = category;
                });
                print('Выбрана категория: $category');
              },
              selectedCategory: _selectedCategory,
            ),

            // ✅ Уникальный контент только для этой страницы
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildShopsSection(), // <-- Только это осталось в экране
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // Секция магазинов и товаров
  Widget _buildShopsSection() {
    final shops = _shopsByCategory[_selectedCategory] ?? [];

    // Если нет данных для категории
    if (shops.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.local_florist, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No shops available for $_selectedCategory',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '5 shops nearby',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // Список магазинов
          ...shops.map((shop) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildShopCard(shop),
          )),
        ],
      ),
    );
  }

// Карточка магазина
  // Карточка магазина
  Widget _buildShopCard(Map<String, dynamic> shop) {
    return GestureDetector(
      onTap: () {
        // Переход на страницу магазина
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ShopDetailScreen(shop: shop),
        //   ),
        // );
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
                // Сетка товаров 2x3
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [

                      // Первый ряд (3 товара)
                      Row(
                        children: [
                          Expanded(child: _buildProductGridItem(shop['products'][0])),
                          const SizedBox(width: 8),
                          Expanded(child: _buildProductGridItem(shop['products'][1])),
                          const SizedBox(width: 8),
                          Expanded(child: _buildProductGridItem(shop['products'][2])),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Второй ряд (3 товара)
                      Row(
                        children: [
                          Expanded(child: _buildProductGridItem(shop['products'][3])),
                          const SizedBox(width: 8),
                          Expanded(child: _buildProductGridItem(shop['products'][4])),
                          const SizedBox(width: 8),
                          Expanded(child: _buildProductGridItem(shop['products'][5])),
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
                            shop['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              shop['deliveryTime'],
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Категория
                      Text(
                        shop['category'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Рейтинг и доставка
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            shop['rating'].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            ' (${shop['reviews']})',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.local_shipping, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            shop['delivery'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
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

          ],
        ),
      ),
    );
  }

// Товар в сетке
  Widget _buildProductGridItem(Map<String, dynamic> product) {
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
              child: Image.asset(
                product['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.local_florist,
                      color: Colors.grey,
                      size: 40,
                    ),
                  );
                },
              ),
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
                  product['price'],
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