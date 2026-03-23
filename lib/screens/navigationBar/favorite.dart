import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Пример данных - букеты
  final List<Map<String, dynamic>> _favoriteBouquets = [
    {
      'price': '43 990₸',
      'name': 'Celine',
      'description': 'Mono-bouquet of premium Columbus peony tulips in a powder pink hat box',
      'image': 'assets/flowers/products/red_roses.png',
    },
    {
      'price': '21 000₸',
      'name': 'Rosalie',
      'description': 'Classic red rose arrangement with eucalyptus in a branded white hat box',
      'image': 'assets/flowers/products/pink_roses.png',
    },
    {
      'price': '30 550₸',
      'name': 'Flora',
      'description': 'Bespoke pink arrangement featuring Oriental lilies, spray chrysanthemums, and gypsophila with euca...',
      'image': 'assets/flowers/products/white_roses.png',
    },
  ];

  // Пример данных - магазины
  final List<Map<String, dynamic>> _favoriteMarkets = [
    {
      'name': 'Cvetasto',
      'rating': 4.9,
      'reviews': 931,
      'image': 'assets/shops/cvetasto.png',
      'discount': '25% off select items',
      'freeDelivery': true,
    },
    {
      'name': 'Flowerhub',
      'rating': 4.8,
      'reviews': 378,
      'image': 'assets/shops/flowerhub.png',
      'discount': '30% off select items',
      'freeDelivery': false,
    },
    {
      'name': 'Romeo',
      'rating': 4.7,
      'reviews': 872,
      'image': 'assets/shops/romeo.png',
      'discount': '25% off select items',
      'freeDelivery': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            child: TabBarView(
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
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _favoriteBouquets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final bouquet = _favoriteBouquets[index];
        return _buildBouquetItem(bouquet);
      },
    );
  }

  // Элемент букета
  Widget _buildBouquetItem(Map<String, dynamic> bouquet) {
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
              child: Image.asset(
                bouquet['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.local_florist, color: Colors.grey),
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
                  bouquet['price'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bouquet['name'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bouquet['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Сердечко
          GestureDetector(
            onTap: () {
              // Удалить из избранного
              print('❤️ Remove from favorites: ${bouquet['name']}');
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

  // Вкладка с магазинами
  Widget _buildMarketsTab() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _favoriteMarkets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final market = _favoriteMarkets[index];
        return _buildMarketItem(market);
      },
    );
  }

  // Элемент магазина
  Widget _buildMarketItem(Map<String, dynamic> market) {
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
              child: Image.asset(
                market['image'],
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
          // Информация
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  market['name'],
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
                      '${market['rating']}/5 rating',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    const Text('•', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                    const Icon(Icons.chat_bubble_outline, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${market['reviews']} review',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (market['discount'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          market['discount'],
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (market['freeDelivery'])
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
            ),
          ),
          const SizedBox(width: 8),
          // Сердечко
          GestureDetector(
            onTap: () {
              // Удалить из избранного
              print('❤️ Remove from favorites: ${market['name']}');
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