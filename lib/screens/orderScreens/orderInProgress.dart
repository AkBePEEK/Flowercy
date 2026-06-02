import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/order.dart' as local;
import '../../services/language_service.dart';
import '../../services/orderService.dart';
import 'orderComplete.dart';

class OrderInProgressScreen extends StatefulWidget {
  final String orderNumber;
  final String status;
  final String orderId;

  const OrderInProgressScreen({
    super.key,
    this.orderNumber = '',
    this.status = 'placed',
    this.orderId = '',
  });

  @override
  State<OrderInProgressScreen> createState() => _OrderInProgressScreenState();
}

class _OrderInProgressScreenState extends State<OrderInProgressScreen> with LanguageStateMixin {
  bool _isCancelling = false;

  Map<String, dynamic> _getStatusData(AppTranslations t, String currentStatus) {
    switch (currentStatus.toLowerCase()) {
      case 'placed':
        return {'icon': 'assets/orderStatus/placed.png',
          'title': t('order_status_placed'), 'completedSteps': 1};
      case 'collecting':
        return {'icon': 'assets/orderStatus/collecting.png',
          'title': t('order_status_collecting'), 'completedSteps': 2};
      case 'delivery':
        return {'icon': 'assets/orderStatus/delivery.png',
          'title': t('order_status_delivery'), 'completedSteps': 3};
      case 'delivered':
        return {'icon': 'assets/orderStatus/delivered.png',
          'title': t('order_status_delivered'), 'completedSteps': 4};
      case 'cancelled':
        return {'icon': 'assets/orderStatus/placed.png', // Or a dedicated cancelled icon
          'title': t('order_cancelled_msg'), 'completedSteps': 0};
      default:
        return {'icon': 'assets/orderStatus/placed.png',
          'title': t('order_status_placed'), 'completedSteps': 1};
    }
  }

  // Отмена заказа
  Future<void> _cancelOrder() async {
    final t = getTranslations();
    setState(() => _isCancelling = true);
    try {
      if (widget.orderId.isNotEmpty) {
        await OrderService().updateOrderStatus(widget.orderId, 'cancelled');
      }
      if (mounted) {
        Navigator.pop(context); // вернуться назад
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t('order_cancelled_msg')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t('error')}: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  void _showCancelDialog() {
    final t = getTranslations();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('cancel_order_confirm_title')),
        content: Text(t('cancel_order_confirm_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('no')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // закрыть диалог
              _cancelOrder();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(t('yes')),
          ),
        ],
      ),
    );
  }

  // Support — открываем телефон/чат (заглушка)
  void _openSupport() {
    final t = getTranslations();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t('support'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.phone, color: Color(0xFFB07183)),
              title: Text(t('call_support')),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline, color: Color(0xFFB07183)),
              title: Text(t('chat_with_us')),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Открыть WhatsApp чат с курьером
  Future<void> _launchWhatsApp() async {
    final t = getTranslations();
    const phone = "+77777777777"; // Заглушка номера курьера
    final message = "${t('home')}! Я по поводу заказа №${widget.orderId}";
    final url = "https://wa.me/$phone?text=${Uri.encodeComponent(message)}";
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('error'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = getTranslations();

    return StreamBuilder<local.Order?>(
      stream: OrderService().getOrderStream(widget.orderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        final order = snapshot.data;
        final currentStatus = order?.status ?? widget.status;
        final statusData = _getStatusData(t, currentStatus);

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
              '${t('order_number_label')} ${widget.orderNumber}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFFB07183).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            statusData['icon'],
                            color: const Color(0xFFB07183),
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.local_florist,
                              color: Color(0xFFB07183),
                              size: 48,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          statusData['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB07183),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 60),
                        _buildProgressTracker(statusData['completedSteps']),
                        const SizedBox(height: 60),
                        // ✅ Support, Chat and Details — теперь рабочие
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildActionButton(
                              icon: Icons.headset_mic,
                              label: t('support'),
                              onTap: _openSupport,
                            ),
                            const SizedBox(width: 12),
                            // ✅ НОВАЯ КНОПКА: Чат с курьером
                            _buildActionButton(
                              icon: Icons.chat_outlined,
                              label: t('chat_courier'),
                              onTap: _launchWhatsApp,
                            ),
                            const SizedBox(width: 12),
                            _buildActionButton(
                              icon: Icons.list,
                              label: t('details'),
                              onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder:
                                    (context) => OrderDetailScreen(orderNumber: widget.orderNumber,
                                    orderId: widget.orderId)))
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
              if (currentStatus.toLowerCase() != 'delivered' && currentStatus.toLowerCase() != 'cancelled')
                Container(
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
                      onPressed: _isCancelling ? null : _showCancelDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB07183),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: _isCancelling
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        t('cancel'),
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
        );
      },
    );
  }


  // ✅ Трекер прогресса с динамическими шагами
  Widget _buildProgressTracker(int completedSteps) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Шаг 1: Заказ размещен
        _buildProgressStep(
          icon: Icons.check,
          isCompleted: completedSteps >= 1, image: '',
        ),
        // Линия
        Expanded(
          child: Container(
            height: 2,
            color: completedSteps >= 2
                ? const Color(0xFFB07183)
                : Colors.grey[300],
            margin: const EdgeInsets.only(bottom: 15),
          ),
        ),
        // Шаг 2: Собирается
        _buildProgressStep(
          image: 'assets/shopping_basket.png',
          isCompleted: completedSteps >= 2,
        ),
        // Линия
        Expanded(
          child: Container(
            height: 2,
            color: completedSteps >= 3
                ? const Color(0xFFB07183)
                : Colors.grey[300],
            margin: const EdgeInsets.only(bottom: 15),
          ),
        ),
        // Шаг 3: Доставка
        _buildProgressStep(
          icon: Icons.directions_car_filled_outlined,
          isCompleted: completedSteps >= 3, image: '',
        ),
        // Линия
        Expanded(
          child: Container(
            height: 2,
            color: completedSteps >= 4
                ? const Color(0xFFB07183)
                : Colors.grey[300],
            margin: const EdgeInsets.only(bottom: 15),
          ),
        ),
        // Шаг 4: Доставлен
        _buildProgressStep(
          icon: Icons.flag_outlined,
          isCompleted: completedSteps >= 4, image: '',
        ),
      ],
    );
  }

  // ✅ Шаг прогресса
  Widget _buildProgressStep({
    required String image,
    required bool isCompleted,
    IconData? icon
  })
  {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFB07183) : Colors.grey[300]!,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Image.asset(
        image,
        width: 24,
        height: 24,
        color: isCompleted ? Colors.white : const Color(0xFFC8C8C8),
        errorBuilder: (context, error, stackTrace) {
          // Fallback на иконку если изображение не найдено
          return Icon(
            icon,
            color: isCompleted ? Colors.white : const Color(0xFFC8C8C8),
            size: 32,
          );
        },
      ),
    );
  }

  // Кнопка действия
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  })
  {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFB07183).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFB07183), size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
