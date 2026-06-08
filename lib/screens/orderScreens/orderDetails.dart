import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/cartItem.dart';
import '../../models/order.dart';
import '../../models/orderItem.dart';
import '../../services/language_service.dart';
import '../../services/notificationService.dart';
import '../../services/orderService.dart';
import '../../services/userService.dart';
import '../../services/paymentService.dart';
import '../../services/shopService.dart';
import 'orderInProgress.dart';

class OrderDetailsScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final int total;
  final String? sellerComment;

  const OrderDetailsScreen({
    super.key,
    required this.cartItems,
    required this.total,
    this.sellerComment,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> with LanguageStateMixin {
  // ✅ Состояния выбора
  int _selectedPickupTimeIndex = 0;
  DateTime? _selectedCustomDateTime;
  int _selectedPaymentIndex = 0;
  String _recipientName = '';
  String _shopAddress = '53 Mangilik El Ave, Astana'; // Placeholder for shop address
  String? _shopId;
  bool _isLoading = true;
  bool _isPlacingOrder = false;

  final PaymentService _paymentService = PaymentService();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _selectDateTime() async {
    final t = getTranslations();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 14)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFB07183),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFB07183),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedCustomDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _selectedPickupTimeIndex = 1;
        });
      }
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final user = await UserService().getCurrentUser();
      
      if (widget.cartItems.isNotEmpty) {
        final firstItem = widget.cartItems.first;
        _shopId = firstItem.shopId; // Use shopId from cart item
        
        if (_shopId != null) {
          final shop = await ShopService().getShopById(_shopId!);
          if (shop != null) {
            _shopAddress = shop.address;
          }
        }
      }

      setState(() {
        _recipientName = user?.name ?? user?.email.split('@').first ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectPickupPoint() async {
    final t = getTranslations();
    setState(() => _isLoading = true);
    
    try {
      final shops = await ShopService().getAllShops();
      setState(() => _isLoading = false);
      
      if (!mounted) return;
      
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t('pickup_point'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: shops.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final shop = shops[index];
                      final isSelected = shop.id == _shopId;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(shop.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(shop.address, style: const TextStyle(fontSize: 13)),
                        trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFFB07183)) : null,
                        onTap: () {
                          setState(() {
                            _shopId = shop.id;
                            _shopAddress = shop.address;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('error'))));
    }
  }

  void _editRecipientName() {
    final t = getTranslations();
    final controller = TextEditingController(text: _recipientName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(t('recipient'), style: const TextStyle(fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: t('no_name'),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t('cancel'))),
          ElevatedButton(
            onPressed: () {
              setState(() => _recipientName = controller.text.trim());
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
    
    final String customTimeDisplay = _selectedCustomDateTime != null
        ? "${_selectedCustomDateTime!.day.toString().padLeft(2, '0')}.${_selectedCustomDateTime!.month.toString().padLeft(2, '0')} ${_selectedCustomDateTime!.hour.toString().padLeft(2, '0')}:${_selectedCustomDateTime!.minute.toString().padLeft(2, '0')}"
        : t('choose_date_time');

    final List<Map<String, dynamic>> pickupTimeOptions = [
      {
        'title': t('faster_delivery'),
        'subtitle': 'через 30-40 мин.',
      },
      {
        'title': t('another_time'),
        'subtitle': customTimeDisplay,
      },
    ];

    final List<Map<String, dynamic>> paymentOptions = [
      {
        'title': t('bank_card'),
        'subtitle': t('pay_now'),
        'method': PaymentMethod.card,
      },
      {
        'title': 'Kaspi.kz',
        'subtitle': t('pay_now'),
        'method': PaymentMethod.kaspi,
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
          : Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPickupInfoSection(t),
                            const SizedBox(height: 24),
                            _buildPickupTimeSection(t, pickupTimeOptions),
                            const SizedBox(height: 24),
                            if (widget.sellerComment != null && widget.sellerComment!.isNotEmpty)
                              _buildCommentPreview(t),
                            const SizedBox(height: 24),
                            _buildPaymentSection(t, paymentOptions),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomSection(context, t, pickupTimeOptions, paymentOptions, widget.total),
                  ],
                ),
                if (_isPlacingOrder)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFFB07183)),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildPickupInfoSection(AppTranslations t) {
    return Column(
      children: [
        _buildInfoRow(
          t('recipient'), 
          _recipientName.isEmpty ? t('unknown') : _recipientName,
          isEditable: true,
          onTap: _editRecipientName,
        ),
        const Divider(height: 1),
        _buildInfoRow(
          t('pickup_point'),
          _shopAddress,
          isEditable: true,
          onTap: _selectPickupPoint, 
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isEditable = false, VoidCallback? onTap}) {
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
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: isEditable ? const Color(0xFFB07183) : Colors.black,
                    fontWeight: isEditable ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                if (isEditable) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.edit_outlined, size: 16, color: Color(0xFFB07183)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentPreview(AppTranslations t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t('commentSeller'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Text(widget.sellerComment!, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupTimeSection(AppTranslations t, List<Map<String, dynamic>> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t('pickup_time'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = index == _selectedPickupTimeIndex;
                return GestureDetector(
                  onTap: () {
                    if (index == 1) {
                      _selectDateTime();
                    } else {
                      setState(() => _selectedPickupTimeIndex = index);
                    }
                  },
                  child: Container(
                    width: 160,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFB07183).withValues(alpha: 0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? const Color(0xFFB07183) : Colors.grey[300]!, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(option['title']!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFFB07183) : Colors.black87)),
                        const SizedBox(height: 4),
                        Text(option['subtitle']!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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

  Widget _buildPaymentSection(AppTranslations t, List<Map<String, dynamic>> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t('payment'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = index == _selectedPaymentIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPaymentIndex = index),
                  child: Container(
                    width: 160,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFB07183).withValues(alpha: 0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? const Color(0xFFB07183) : Colors.grey[300]!, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(option['title']!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFFB07183) : Colors.black87)),
                        const SizedBox(height: 4),
                        Text(option['subtitle']!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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

  Future<void> _placeOrder(AppTranslations t, List<Map<String, dynamic>> pickupOptions, List<Map<String, dynamic>> paymentOptions, int total) async {
    if (_recipientName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('recipient')), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final paymentMethod = paymentOptions[_selectedPaymentIndex]['method'] as PaymentMethod;
      final paymentResult = await _paymentService.processPayment(method: paymentMethod, amount: total);

      if (!paymentResult.success) throw Exception(paymentResult.message ?? t('general_error'));

      final order = Order(
        id: '',
        userId: userId,
        shopId: _shopId,
        items: widget.cartItems.map((item) => OrderItem(
          productId: item.productId,
          name: item.name,
          price: item.price,
          quantity: item.quantity,
          image: item.image,
        )).toList(),
        total: total,
        status: 'placed',
        recipient: _recipientName,
        shopAddress: _shopAddress,
        pickupTime: pickupOptions[_selectedPickupTimeIndex]['subtitle']!,
        payment: paymentOptions[_selectedPaymentIndex]['title']!,
        sellerComment: widget.sellerComment,
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  Widget _buildBottomSection(BuildContext context, AppTranslations t, List<Map<String, dynamic>> pickupOptions, List<Map<String, dynamic>> paymentOptions, int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))]),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t('total'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                Text('$total ₸', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isPlacingOrder ? null : () => _placeOrder(t, pickupOptions, paymentOptions, total),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB07183),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isPlacingOrder
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('${t('payOrder')}  $total ₸', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
