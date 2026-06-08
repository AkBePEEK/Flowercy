import 'package:flutter/material.dart';
import '../../models/cartItem.dart';
import '../../services/language_service.dart';
import '../../services/userService.dart';
import '../../widgets/universal_image.dart';
import '../orderScreens/orderDetails.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback? onBrowseFlowers;
  const CartScreen({super.key, this.onBrowseFlowers});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with LanguageStateMixin{
  final UserService _userService = UserService();

  // ✅ Состояния для корзины
  List<CartItem> _cartItems = [];
  bool _isLoading = true;
  String? _error;
  String _sellerComment = '';
  String _promocode = '';
  int _discount = 0;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  // ✅ Загрузка корзины из Firestore
  Future<void> _loadCart() async {
    final t = getTranslations();
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await _userService.getCurrentUser();
      setState(() {
        _cartItems = user?.cart ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = t('error_load_cart');
        _isLoading = false;
      });
      print('❌ Error loading cart: $e');
    }
  }

  // ✅ Обновление количества товара
  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity <= 0) {
      await _removeFromCart(item.productId);
    } else {
      await _userService.updateCartItemQuantity(item.productId, newQuantity);
      _loadCart(); // Перезагрузить корзину
    }
  }

  // ✅ Удаление товара из корзины
  Future<void> _removeFromCart(String productId) async {
    await _userService.removeFromCart(productId);
    _loadCart();
  }

  // ✅ Диалог для добавления комментария продавцу
  void _editSellerComment() {
    final t = getTranslations();
    final controller = TextEditingController(text: _sellerComment);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24), // ✅ Удлиняем по бокам
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // ✅ Скругляем углы
        title: Text(t('commentSeller'), style: const TextStyle(fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: MediaQuery.of(context).size.width, // ✅ На всю доступную ширину
          child: TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: t('addComment'),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('cancel'), style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _sellerComment = controller.text.trim());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB07183),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(t('save')),
          ),
        ],
      ),
    );
  }

  // ✅ Диалог для ввода промокода
  void _editPromocode() {
    final t = getTranslations();
    final controller = TextEditingController(text: _promocode);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24), // ✅ Удлиняем по бокам
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(t('promocode'), style: const TextStyle(fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: t('usePromocode'),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('cancel'), style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              final code = controller.text.trim().toUpperCase();
              setState(() {
                _promocode = code;
                if (code == 'FLOWERY10') {
                  _discount = (_totalPrice * 0.1).round();
                } else {
                  _discount = 0;
                }
              });
              Navigator.pop(context);
              if (_discount > 0) {
                _showSnackBar('${t('promocode')} $code ${t('applied')}!');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB07183),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: Text(t('apply')),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // ✅ Подсчёт общей суммы
  int get _totalPrice {
    return _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  int get _finalPrice => _totalPrice - _discount;

  @override
  Widget build(BuildContext context) {
    final t = getTranslations();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          t.cart,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // ✅ Кнопка очистки корзины (если есть товары)
          if (_cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: () => _showClearCartDialog(),
            ),
        ],
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
                    onPressed: _editSellerComment,
                    child: Text(t('retry')),
                  ),
                ],
              ),
            )
                : _cartItems.isEmpty
                ? _buildEmptyCart() // ✅ Пустая корзина
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Список товаров из корзины
                  ..._cartItems.map((item) => _buildProductItem(item)),
                  const SizedBox(height: 16),

                  _buildCommentSection(),
                  const SizedBox(height: 24),

                  _buildPeopleAddSection(),
                  const SizedBox(height: 24),

                  _buildPromocodeSection(),
                  const SizedBox(height: 24),

                  // ✅ Динамическая цена
                  _buildPriceSummary(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // ✅ Кнопка с динамической ценой
          _buildBottomButton(context),
        ],
      ),
    );
  }

  // ✅ Экран пустой корзины
  Widget _buildEmptyCart() {
    final t = getTranslations();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            t('cartEmpty'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t('addSomeFlowers'),
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              widget.onBrowseFlowers?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB07183),
              foregroundColor: Colors.white,
            ),
            child: Text(t('browseFlowers')),
          ),
        ],
      ),
    );
  }

  // ✅ Товар корзины (динамический)
  Widget _buildProductItem(CartItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Изображение
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: UniversalImage(
                imagePath: item.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.local_florist, color: Colors.grey);
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
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Количество с кнопками +/-
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: () => _updateQuantity(item, item.quantity - 1),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          SizedBox(
                            width: 24,
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: () => _updateQuantity(item, item.quantity + 1),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Цена
                    Text(
                      '${item.price * item.quantity}₸',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ✅ Кнопка удаления
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: Colors.grey),
            onPressed: () => _removeFromCart(item.productId),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // ✅ Комментарий продавцу
  Widget _buildCommentSection() {
    final t = getTranslations();
    return GestureDetector(
      onTap: _editSellerComment,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE9ECEC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('commentSeller'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  if (_sellerComment.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _sellerComment,
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  _sellerComment.isEmpty ? t('addComment') : t('edit'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFB07183)),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 16, color: Color(0xFFB07183)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // People add to the order (можно сделать интерактивным позже)
  Widget _buildPeopleAddSection() {
    final t = getTranslations();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('people_add_to_order'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      "assets/flowers/logo.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('postcard'),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '0₸',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Промокод
  Widget _buildPromocodeSection() {
    final t = getTranslations();
    return GestureDetector(
      onTap: _editPromocode,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE9ECEC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('promocode'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _promocode.isEmpty ? t('youHavePromocode') : '${t('applied')}: $_promocode',
                    style: TextStyle(fontSize: 12, color: _promocode.isEmpty ? Colors.grey[600] : Colors.green[700]),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  _promocode.isEmpty ? t('usePromocode') : t('edit'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFB07183)),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 16, color: Color(0xFFB07183)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Итоговая цена (динамическая)
  Widget _buildPriceSummary() {
    final t = getTranslations();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t('price'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                '$_totalPrice₸', // ✅ Динамическая цена
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          if (_discount > 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t('promocode'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green),
                ),
                Text(
                  '-$_discount₸',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.green),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t('delivery'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Text(
                '0₸',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Divider(height: 24),
          // ✅ Общая сумма
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t('total'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              Text(
                '$_finalPrice₸', // ✅ Динамическая сумма со скидкой
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ Кнопка с проверкой пустой корзины
  Widget _buildBottomButton(BuildContext context) {
    final t = getTranslations();
    return Container(
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
        child: ElevatedButton(
          onPressed: _cartItems.isEmpty
              ? null // ✅ Блокировать если корзина пуста
              : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsScreen(
                  cartItems: _cartItems, // ✅ Передаём товары в заказ
                  total: _finalPrice,    // ✅ Передаём сумму со скидкой
                  sellerComment: _sellerComment.isEmpty ? null : _sellerComment, // ✅ Передаем комментарий
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _cartItems.isEmpty
                ? Colors.grey[400]
                : const Color(0xFFB07183),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text(
            _cartItems.isEmpty ? t('cart_is_empty') : t('goToCheckout'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Диалог подтверждения очистки корзины
  void _showClearCartDialog() {
    final t = getTranslations();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('clearCart')),
        content: Text(t('removeAllItems')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _userService.clearCart();
              _loadCart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(t('clear')),
          ),
        ],
      ),
    );
  }
}