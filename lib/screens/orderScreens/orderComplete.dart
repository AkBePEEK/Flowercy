import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../models/orderItem.dart';
import '../../services/language_service.dart';
import '../../services/orderService.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderNumber; // для отображения в AppBar
  final String orderId;     // для загрузки из Firestore

  const OrderDetailScreen({
    super.key,
    this.orderNumber = '',
    this.orderId = '',
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> with LanguageStateMixin{
  Order? _order;
  bool _isLoading = true;
  String? _error;
  bool _isRepeating = false;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final t = getTranslations();
    if (widget.orderId.isEmpty) {
      setState(() {
        _error = t('order_id_not_provided');
        _isLoading = false;
      });
      return;
    }

    try {
      final order = await OrderService().getOrderById(widget.orderId);
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = t('failed_to_load_order');
        _isLoading = false;
      });
    }
  }

  // Цвет статуса
  Color _getStatusColor(String status) {
    return Color(int.parse('0xFF${_order!.statusColorHex}'));
  }

  // Повторить заказ — создаём новый с теми же товарами
  Future<void> _repeatOrder() async {
    final t = getTranslations();
    if (_order == null) return;
    setState(() => _isRepeating = true);

    try {
      final newOrder = Order(
        id: '',
        userId: _order!.userId,
        items: _order!.items,
        total: _order!.total,
        status: 'placed',
        recipient: _order!.recipient,
        address: _order!.address,
        apartment: _order!.apartment,
        deliveryTime: _order!.deliveryTime,
        payment: _order!.payment,
        comment: _order!.comment,
        createdAt: DateTime.now(), sellerComment: '',
      );

      await OrderService().createOrder(newOrder);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('order_repeated_success')),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${t('failed_to_repeat_order')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isRepeating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = getTranslations();
    final displayNumber = widget.orderNumber.isNotEmpty
        ? widget.orderNumber
        : (widget.orderId.isNotEmpty ? '№${widget.orderId}' : '№—');

    return StreamBuilder<Order?>(
      stream: OrderService().getOrderStream(widget.orderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('${t('order_number_label')} $displayNumber')),
            body: const Center(child: CircularProgressIndicator(color: Color(0xFFB07183))),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('${t('order_number_label')} $displayNumber')),
            body: _buildErrorState(snapshot.error.toString()),
          );
        }

        final order = snapshot.data;
        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: Text('${t('order_number_label')} $displayNumber')),
            body: Center(child: Text(t('order_not_found'))),
          );
        }

        _order = order; // Save for repeat order logic

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
              '${t('order_number_label')} $displayNumber',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: _buildContent(order),
        );
      },
    );
  }

  // ── Контент ──────────────────────────────────────────────────

  Widget _buildContent(Order order) {
    final t = getTranslations();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Статус + номер заказа
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          t('order_status_${order.status.toLowerCase()}'), // Map status to localized
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '№${order.id}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Товары заказа
                ...order.items.map((item) => _buildOrderItem(item)),

                const SizedBox(height: 8),

                // Итого
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${order.itemsCount} ${t('items_count')}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      Text(
                        order.formattedTotal,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB07183),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Информация о заказе
                _buildInfoSection(order),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),

        // Кнопка Repeat order (только если можно повторить)
        if (order.canRepeat) _buildBottomButton(),
      ],
    );
  }

  // ── Элемент товара ────────────────────────────────────────────

  Widget _buildOrderItem(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Изображение (заглушка — в OrderItem нет image URL)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: item.image != null && item.image!.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                item.image!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.local_florist,
                  color: Colors.grey,
                ),
              ),
            )
                : const Icon(Icons.local_florist, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} × ${item.formattedPrice}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            item.formattedTotalPrice,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ── Информация о заказе ───────────────────────────────────────

  Widget _buildInfoSection(Order order) {
    final t = getTranslations();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (order.recipient.isNotEmpty)
            _buildInfoRow(t('recipient'), order.recipient),
          if (order.address.isNotEmpty) ...[
            const Divider(height: 1, indent: 16),
            _buildInfoRow(
              t('address'),
              order.apartment != null && order.apartment!.isNotEmpty
                  ? '${order.address}, ${order.apartment}'
                  : order.address,
            ),
          ],
          if (order.deliveryTime.isNotEmpty) ...[
            const Divider(height: 1, indent: 16),
            _buildInfoRow(t('delivery_time'), order.deliveryTime),
          ],
          if (order.payment.isNotEmpty) ...[
            const Divider(height: 1, indent: 16),
            _buildInfoRow(t('payment'), order.payment),
          ],
          if (order.comment != null && order.comment!.isNotEmpty) ...[
            const Divider(height: 1, indent: 16),
            _buildInfoRow(t('courierComment'), order.comment!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // ── Кнопка Repeat order ───────────────────────────────────────

  Widget _buildBottomButton() {
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
          onPressed: _isRepeating ? null : _repeatOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB07183),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: _isRepeating
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : Text(
            t('repeatOrder'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  // ── Экран ошибки ──────────────────────────────────────────────

  Widget _buildErrorState(String error) {
    final t = getTranslations();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: Colors.red, fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}), // Trigger rebuild
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB07183),
            ),
            child: Text(t('retry'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}