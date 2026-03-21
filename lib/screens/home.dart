import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header с адресом
            _buildHeader(),

            // Основной контент
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // ВАЖНО!
                    children: [
                      // Категории
                      _buildCategories(),
                      const SizedBox(height: 20),

                      // Карточки AI Florist и Bouquet crafting
                      _buildFeatureCards(),
                      const SizedBox(height: 20),

                      // Top pick
                      _buildTopPick(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(child: _buildBottomNav()),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Astana',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Uly Dala avenue, 31',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 98,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _buildCategoryItem('Flowers', Colors.purple[100]!, 'assets/flowers/homeScreen/flowersCategories.png'),
          _buildCategoryItem('Sweets', Colors.pink[100]!, 'assets/flowers/homeScreen/sweetsCategories.png'),
          _buildCategoryItem('Plants', Colors.green[100]!, 'assets/flowers/homeScreen/plantsCategories.png'),
          _buildCategoryItem('Bears', Colors.blue[100]!, 'assets/flowers/homeScreen/bearCategories.png'),
          _buildCategoryItem('Balloons', Colors.orange[100]!, 'assets/flowers/homeScreen/balloonsCategories.png'),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String name, Color color, String imagePath) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Если изображение не найдено, показываем цветной контейнер с иконкой
                  return Container(
                    color: color,
                    child: const Icon(
                      Icons.local_florist,
                      color: Colors.white70,
                      size: 30,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCards()  {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row( // Изменили Row на Column
        children: [
          // Первая карточка
          Flexible(child:
            Container(
            height: 174,
            width: double.infinity, // На всю ширину
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFFFEBF5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset('assets/flowers/homeScreen/AIFlorist.png'),
                ),

                const SizedBox(height: 10),

                const Text(
                  'AI Florist',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Find the perfect bouquet for any moment',
                  style: TextStyle(fontSize: 12),
                ),

                const Spacer(),

                Row(
                  children: [
                    // Кнопка с текстом
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                            color: Color(0xFFFF67B3),
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: const Center(
                          child: Text(
                            'Ask AI for ideas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Кнопка со стрелкой
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFFFF67B3),
                        size: 12,
                      ),
                    ),
                  ],
                )

              ],
            ),
          )
          ),

          const SizedBox(height: 12, width: 10),

          // Вторая карточка
          Flexible(child:
            Container(
            height: 174,
            width: double.infinity, // На всю ширину
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFE7EDFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                    child: Image.asset("assets/flowers/homeScreen/bouquetCrafting.png"),
                ),
                const SizedBox(height: 10),

                const Text(
                  'Bouquet crafting',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 5),

                const Text(
                  'Create your own bouquet with our florists',
                  style: TextStyle(fontSize: 12),
                ),

                const Spacer(),

                Row(
                  children: [
                    // Кнопка с текстом
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFF558DF0),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: const Center(
                          child: Text(
                            'Start crafting',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Кнопка со стрелкой
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white, // Или Color(0xFF558DF0) с иконкой белого цвета
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF558DF0),
                        size: 12,
                      ),
                    ),
                  ],
                )

                ],
              ),
            )
          ),
        ],
      ),
    );
  }

  Widget _buildTopPick() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'Top pick ',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('🔥', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildProductCard(
                'Ranunculuses',
                '88.000',
                "assets/flowers/homeScreen/Ranunculuses.jpg"
              ),
            ]
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(String title, String price, String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: 256, // Фиксированная высота для карточки
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // 1. Изображение на весь контейнер
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imagePath,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // 2. Градиент затемнения снизу (для читаемости текста)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 120, // Высота градиента
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7), // Темный снизу
                    Colors.black.withOpacity(0.3), // Прозрачнее в середине
                    Colors.transparent, // Полностью прозрачный сверху
                  ],
                ),
              ),
            ),
          ),

          // 3. Бейдж "Top Choice" сверху слева
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Top Choice',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF67B3),
                ),
              ),
            ),
          ),

          // 4. Текст снизу (название и цена)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white, // Белый текст
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₸ $price',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white, // Белый текст
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildBottomBanner() {
  //   return Container(
  //     margin: const EdgeInsets.all(16),
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(12),
  //           decoration: BoxDecoration(
  //             color: Colors.pink[100],
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           child: const Icon(Icons.shopping_bag, color: Colors.pink),
  //         ),
  //         const SizedBox(width: 12),
  //         const Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 'Collecting order',
  //                 style: TextStyle(fontWeight: FontWeight.bold),
  //               ),
  //               SizedBox(height: 4),
  //               Text(
  //                 'We deliver flowers today, from 8:00 to 10:00',
  //                 style: TextStyle(fontSize: 12, color: Colors.grey),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.local_florist, 'Главная', true),
          _buildNavItem(Icons.search, '', false),
          _buildNavItem(Icons.favorite_border, '', false),
          _buildNavItem(Icons.shopping_bag_outlined, '', false),
          _buildNavItem(Icons.person_outline, '', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? Colors.pink : Colors.grey, size: 24),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? Colors.pink : Colors.grey,
            ),
          ),
        ],
      ],
    );
  }
}