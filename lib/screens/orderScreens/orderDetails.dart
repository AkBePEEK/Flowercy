import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/address.dart';
import '../../models/cartItem.dart';
import '../../models/order.dart';
import '../../models/orderItem.dart';
import '../../services/language_service.dart';
import '../../services/notificationService.dart';
import '../../services/orderService.dart';
import '../../services/userService.dart';
import '../savedAddresses.dart';
import 'courierComment.dart';
import 'orderInProgress.dart';

class OrderDetailsScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final int total;

  const OrderDetailsScreen({
    super.key,
    required this.cartItems,
    required this.total,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> with LanguageStateMixin {
  // ✅ Состояния выбора
  int _selectedDeliveryIndex = 0;
  int _selectedPaymentIndex = 0;
  String _courierComment = '';
  Address? _selectedAddress;
  String _recipientName = '';
  String _apartmentDetails = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // ✅ Загрузка начальных данных (адрес и имя пользователя)
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final user = await UserService().getCurrentUser();
      final addresses = user?.addresses ?? [];
      final defaultAddr = addresses.where((a) => a.isDefault).firstOrNull ?? addresses.firstOrNull;
      
      setState(() {
        _selectedAddress = defaultAddr;
        _recipientName = user?.name ?? user?.email.split('@').first ?? '';
        _apartmentDetails = defaultAddr?.apartment ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ✅ Выбор нового адреса
  Future<void> _pickAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SavedAddressesScreen()),
    );
    // Обновляем данные после выбора
    final addresses = await UserService().getAddresses();
    final defaultAddr = addresses.where((a) => a.isDefault).firstOrNull ?? addresses.firstOrNull;
    
    setState(() {
      _selectedAddress = defaultAddr;
      if (defaultAddr != null) {
        _apartmentDetails = defaultAddr.apartment ?? '';
      }
    });
  }

  // ✅ Редактирование текстового поля (Получатель или Квартира)
  void _editTextField(String title, String initialValue, Function(String) onSave) {
    final t = getTranslations();
    final controller = TextEditingController(text: initialValue);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: t('enter_email_hint'), // Reuse or use generic hint
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t('cancel'))),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text.trim());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB07183), foregroundColor: Colors.white),
            child: Text(t('save')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = getTranslations();
    
    // Данные доставки
    final List<Map<String, String>> _deliveryOptions = [
      {
        'title': t('faster_delivery'),
        'subtitle': t('delivery_time_subtitle'),
        'price': 'Free',
      },
      {
        'title': t('another_time'),
        'subtitle': t('choose_date_time'),
        'price': '',
      },
      {
        'title': t('faster_delivery'),
        'subtitle': t('delivery_time_subtitle'),
        'price': 'Free',
      },
    ];

    // Данные оплаты
    final List<Map<String, String>> _paymentOptions = [
      {
        'title': t('bank_card'),
        'subtitle': t('pay_now'),
      },
      {
        'title': 'Kaspi.kz',
        'subtitle': t('pay_now'),
      },
      {
        'title': t('upon_receipt'),
        'subtitle': t('payment_receipt'),
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          t('orderDetails'),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(t),
                  const SizedBox(height: 24),
                  _buildDeliverySection(t, _deliveryOptions),
                  const SizedBox(height: 24),
                  _buildImportantDetailsSection(t),
                  const SizedBox(height: 24),
                  _buildPaymentSection(t, _paymentOptions),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildBottomSection(context, t, _deliveryOptions, _paymentOptions),
        ],
      ),
    );
  }

  Widget _buildInfoSection(AppTranslations t) {
    return Column(
      children: [
        _buildInfoRow(
          t('recipient'), 
          _recipientName.isEmpty ? t('unknown') : _recipientName,
          isAddable: true,
          onTap: () => _editTextField(t('recipient'), _recipientName, (val) => setState(() => _recipientName = val)),
        ),
        const Divider(height: 1),
        _buildInfoRow(
          t('address'),
          _selectedAddress?.street ?? t('addAddress'),
          isAddable: true,
          onTap: _pickAddress,
        ),
        const Divider(height: 1),
        _buildInfoRow(
          t('apt_office_floor_entrance'),
          _apartmentDetails.isEmpty ? t('apt_office_floor_entrance_hint') : _apartmentDetails,
          isAddable: true,
          onTap: () => _editTextField(t('apt_office_floor_entrance'), _apartmentDetails, (val) => setState(() => _apartmentDetails = val)),
        ),
        const Divider(height: 1),
        _buildInfoRow(
          t('courierComment'),
          _courierComment.isEmpty ? t('addComment') : _courierComment,
          isAddable: true,
          onTap: _showCourierComment,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAddable = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: isAddable ? const Color(0xFFB07183) : Colors.black,
                    fontWeight: isAddable ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Метод для показа модального окна комментария
  void _showCourierComment() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const CourierCommentSheet(),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _courierComment = result;
      });
    }
  }

  // ✅ Доставка с кликабельными элементами
  Widget _buildDeliverySection(AppTranslations t, List<Map<String, String>> deliveryOptions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t('delivery'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    deliveryOptions[_selectedDeliveryIndex]['subtitle']!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 16),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: deliveryOptions.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final option = deliveryOptions[index];
                final isSelected = index == _selectedDeliveryIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDeliveryIndex = index;
                    });
                  },
                  child: Container(
                    width: 160,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFB07183).withValues(alpha: 0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFB07183)
                            : Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                option['title']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? const Color(0xFFB07183)
                                      : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFB07183)
                                    : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFB07183)
                                      : Colors.grey[400]!,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          option['subtitle']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (option['price']!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            option['price']!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantDetailsSection(AppTranslations t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t('important_details'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    t('select_label'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 16),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            t('important_details_hint'),
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Оплата с кликабельными элементами
  Widget _buildPaymentSection(AppTranslations t, List<Map<String, String>> paymentOptions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('payment'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: paymentOptions.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final option = paymentOptions[index];
                final isSelected = index == _selectedPaymentIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPaymentIndex = index;
                    });
                  },
                  child: Container(
                    width: 160,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFB07183).withValues(alpha: 0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFB07183)
                            : Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                option['title']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? const Color(0xFFB07183)
                                      : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFB07183)
                                    : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFB07183)
                                      : Colors.grey[400]!,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          option['subtitle']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isPlacingOrder = false;

  Future<void> _placeOrder(AppTranslations t, List<Map<String, String>> deliveryOptions, List<Map<String, String>> paymentOptions) async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('addAddress')), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_recipientName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('recipient')), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final order = Order(
        id: '',
        userId: userId,
        items: widget.cartItems.map((item) => OrderItem(
          productId: item.productId,
          name: item.name,
          price: item.price,
          quantity: item.quantity,
          image: item.image,
        )).toList(),
        total: widget.total,
        status: 'placed',
        recipient: _recipientName,
        address: _selectedAddress!.street,
        apartment: _apartmentDetails,
        deliveryTime: deliveryOptions[_selectedDeliveryIndex]['subtitle']!,
        payment: paymentOptions[_selectedPaymentIndex]['title']!,
        comment: _courierComment.isEmpty ? null : _courierComment,
        createdAt: DateTime.now(),
      );

      final orderId = await OrderService().createOrder(order);
      await UserService().clearCart();

      await NotificationService().addNotification(
        title: t('order_placed_title'),
        body: t('order_placed_msg'),
        orderId: orderId,
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => OrderInProgressScreen(
              orderNumber: '№${orderId.substring(0, 8).toUpperCase()}',
              orderId: orderId,
              status: 'placed',
            ),
          ),
              (route) => route.isFirst,
        );
      }
    } catch (e) {
      print('❌ Error placing order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('failed_to_place_order')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  Widget _buildBottomSection(BuildContext context, AppTranslations t, List<Map<String, String>> deliveryOptions, List<Map<String, String>> paymentOptions) {
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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  t('total'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${widget.total} ₸', // Make total dynamic
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _isPlacingOrder ? null : () => _placeOrder(t, deliveryOptions, paymentOptions),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB07183),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isPlacingOrder
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : Text(
                '${t('payOrder')}  ${widget.total} ₸', // ← динамическая цена
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
