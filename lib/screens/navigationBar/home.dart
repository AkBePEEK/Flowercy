import 'package:flutter/material.dart';

import '../../models/address.dart';
import '../../models/product.dart';
import '../../services/language_service.dart';
import '../../services/notificationService.dart';
import '../../services/productService.dart';
import '../../services/userService.dart';
import '../aiFlorist/aiFlorist.dart';
import '../categoryScreens/flowerCategory.dart';
import '../categoryScreens/productDetail.dart';
import '../categoryScreens/sweetsCategory.dart';
import '../notificationsScreen.dart';
import '../orderScreens/orderInProgress.dart';
import '../savedAddresses.dart';
import '../../models/order.dart';
import '../../services/orderService.dart';

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
                      _buildCategories(context),
                      const SizedBox(height: 20),

                      // Карточки AI Florist и Bouquet crafting
                      _buildFeatureCards(context),
                      const SizedBox(height: 20),

                      // Top pick
                      _buildTopPick(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomBanner(context)
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const _HomeHeader();
  }

  Widget _buildCategories(BuildContext context) {
    final t = getTranslations();
    return SizedBox(
      height: 98,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _buildCategoryItem(t('flowers'), Colors.purple[100]!,
              'assets/flowers/homeScreen/flowersCategories.png', context),
          _buildCategoryItem(t('sweets'), Colors.pink[100]!,
              'assets/flowers/homeScreen/sweetsCategories.png', context),
          _buildCategoryItem(t('plants'), Colors.green[100]!,
              'assets/flowers/homeScreen/plantsCategories.png', context),
          _buildCategoryItem(t('bears'), Colors.blue[100]!,
              'assets/flowers/homeScreen/bearCategories.png', context),
          _buildCategoryItem(t('balloons'), Colors.orange[100]!,
              'assets/flowers/homeScreen/balloonsCategories.png', context),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
      String name, Color color, String imagePath, BuildContext context) {
    return GestureDetector(
      onTap: () {
        _navigateToCategory(name, context);
      },
      child: Container(
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
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF333333),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

// Функция навигации (добавьте в класс _CatalogScreenState)
  void _navigateToCategory(String categoryName, BuildContext context) {
    final t = getTranslations();
    if (categoryName == t('flowers')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FlowerCategoryScreen()),
      );
    } else if (categoryName == t('sweets')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SweetsCategoryScreen()),
      );
    }
  }

  Widget _buildFeatureCards(BuildContext context) {
    final t = getTranslations();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AIFloristScreen(),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFEBF5), Color(0xFFE7EDFF)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок с иконкой
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFFB07183),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    t('ai_florist_title'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Описание
              Text(
                t('ai_florist_description'),
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 16),

              // Шаги
              Row(
                children: [
                  _buildStep('🌸', t('flowers')),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  _buildStep('✨', t('generation')),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  _buildStep('💐', t('to_florist')),
                ],
              ),

              const SizedBox(height: 16),

              // Кнопка
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF67B3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          t('create_ai_bouquet'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFFFF67B3),
                      size: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String emoji, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPick() {
    final t = getTranslations();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '${t('top_pick')} ',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
              const Text('🔥', style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _TopPickCard(), // ← заменяем заглушку
      ],
    );
  }

  Widget _buildBottomBanner(BuildContext context) {
    return const _ActiveOrderBanner();
  }
}

class _NotificationBell extends StatefulWidget {
  const _NotificationBell();

  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<_NotificationBell> with LanguageStateMixin{
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final count = await NotificationService().getUnreadCount();
    if (mounted) setState(() => _unreadCount = count);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationsScreen()),
        );
        _loadUnreadCount(); // обновляем счётчик после возврата
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_outlined),
            if (_unreadCount > 0)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFB07183),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$_unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
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

class _TopPickCard extends StatefulWidget {
  const _TopPickCard();

  @override
  State<_TopPickCard> createState() => _TopPickCardState();
}

class _TopPickCardState extends State<_TopPickCard> with LanguageStateMixin{
  Product? _product;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTopPick();
  }

  Future<void> _loadTopPick() async {
    try {
      final products = await ProductService().getAllProducts();
      if (products.isNotEmpty) {
        // Берём товар с наивысшим рейтингом
        products.sort((a, b) => b.rating.compareTo(a.rating));
        setState(() {
          _product = products.first;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ Error loading top pick: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 256,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_product == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: _product!.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        width: double.infinity,
        height: 256,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            // Изображение
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _product!.images.isNotEmpty
                  ? Image.network(
                _product!.images.first,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.local_florist, size: 60, color: Colors.grey),
                ),
              )
                  : Container(
                color: Colors.grey[200],
                child: const Icon(Icons.local_florist, size: 60, color: Colors.grey),
              ),
            ),

            // Градиент
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.black.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Бейдж
            Positioned(
              top: 10, left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  getTranslations()('top_choice'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFFF67B3)),
                ),
              ),
            ),

            // Название и цена
            Positioned(
              left: 12, right: 12, bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _product!.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _product!.formattedPrice,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
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

class _HomeHeader extends StatefulWidget {
  const _HomeHeader();

  @override
  State<_HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<_HomeHeader> with LanguageStateMixin{
  Address? _defaultAddress;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    try {
      final address = await UserService().getDefaultAddress();
      if (mounted) setState(() => _defaultAddress = address);
    } catch (e) {
      print('❌ Error loading address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SavedAddressesScreen()),
                );
                _loadAddress(); // обновляем после возврата
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Astana',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Row(
                    children: [
                      Text(
                        _defaultAddress?.street ?? getTranslations()('addAddress'),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                    ],
                  ),                ],
              ),
            ),
          ),
          _NotificationBell(),
        ],
      ),
    );
  }
}

class _ActiveOrderBanner extends StatefulWidget {
  const _ActiveOrderBanner();

  @override
  State<_ActiveOrderBanner> createState() => _ActiveOrderBannerState();
}

class _ActiveOrderBannerState extends State<_ActiveOrderBanner> with LanguageStateMixin{
  Order? _activeOrder;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActiveOrder();
  }

  Future<void> _loadActiveOrder() async {
    try {
      final orders = await OrderService().getUserOrders();
      final active = orders.where((o) {
        final s = o.status.toLowerCase();
        return s == 'placed' || s == 'collecting' || s == 'delivery';
      }).toList();

      if (mounted) {
        setState(() {
          _activeOrder = active.isNotEmpty ? active.first : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print('❌ Error loading active order: $e');
    }
  }

  String get _statusText {
    final t = getTranslations();
    switch (_activeOrder?.status.toLowerCase()) {
      case 'placed':     return t('status_placed');
      case 'collecting': return t('status_collecting');
      case 'delivery':   return t('status_delivery');
      default:           return t('status_in_progress');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = getTranslations();
    // Пока грузится — ничего не показываем
    if (_isLoading) return const SizedBox.shrink();

    // Нет активных заказов — скрываем баннер
    if (_activeOrder == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderInProgressScreen(
              orderNumber: '№${_activeOrder!.id}',
              status:      _activeOrder!.status,
              orderId:     _activeOrder!.id,
            ),
          ),
        );
        // Обновляем после возврата (заказ мог быть отменён)
        _loadActiveOrder();
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFB07183),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset("assets/shopping_basket.png"),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _statusText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _activeOrder!.deliveryTime.isNotEmpty
                        ? _activeOrder!.deliveryTime
                        : t('delivery_today'),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}