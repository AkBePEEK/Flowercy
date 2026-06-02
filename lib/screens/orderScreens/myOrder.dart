import 'package:flowery_app/screens/orderScreens/orderInProgress.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // ✅ Добавлено для base64

import '../../models/order.dart';
import '../../models/bouquetRequest.dart';
import '../../services/language_service.dart';
import '../../services/orderService.dart';
import '../../services/aiFloristService.dart';
import 'orderComplete.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with LanguageStateMixin {
  @override
  Widget build(BuildContext context) {
    final t = getTranslations();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            t('myOrders'),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: const Color(0xFFB07183),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFFB07183),
            tabs: [
              Tab(text: t('historyOrders')),
              Tab(text: t('bouquet_requests')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrdersList(t),
            _buildRequestsList(t),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(AppTranslations t) {
    return StreamBuilder<List<Order>>(
      stream: OrderService().getUserOrdersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('${t('error')}: ${snapshot.error}'));
        }
        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return Center(child: Text(t('no_orders_yet')));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildOrderItemFromOrder(orders[index], context, t),
        );
      },
    );
  }

  Widget _buildRequestsList(AppTranslations t) {
    return StreamBuilder<List<BouquetRequest>>(
      stream: OrderService().getUserBouquetRequestsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('${t('error')}: ${snapshot.error}'));
        }
        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return Center(child: Text(t('no_requests_yet')));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildRequestItem(requests[index], context, t),
        );
      },
    );
  }

  Widget _buildRequestItem(BouquetRequest request, BuildContext context, AppTranslations t) {
    Color statusColor;
    switch (request.status.toLowerCase()) {
      case 'pending': statusColor = Colors.orange; break;
      case 'accepted': statusColor = Colors.green; break;
      case 'completed': statusColor = Colors.blue; break;
      case 'cancelled': statusColor = Colors.red; break;
      default: statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  t('request_status_${request.status.toLowerCase()}'),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${t('ai_bouquet')} №${request.id.substring(0, 5)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildImage(request.image),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.bouquetName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${request.price} ₸',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.flowers,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String? imageData) {
    if (imageData == null || imageData.isEmpty) return const Icon(Icons.local_florist, color: Color(0xFFB07183));

    final String baseUrl = AIFloristService().baseUrl;

    if (imageData.startsWith('http')) {
      return Image.network(imageData, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
    } else if (imageData.startsWith('catalog/')) {
      final imageUrl = '$baseUrl/static/$imageData';
      return Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
    } else {
      try {
        String base64Str = imageData;
        if (base64Str.contains(',')) base64Str = base64Str.split(',').last;
        return Image.memory(base64Decode(base64Str), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
      } catch (e) {
        return const Icon(Icons.broken_image);
      }
    }
  }

  Widget _buildOrderItem(
      BuildContext context, {
        required String status,
        required Color statusColor,
        required String orderNumber,
        required String productName,
        required String price,
        required String orderId,
        required String rawStatus, // ✅ Добавлено
        required AppTranslations t,
        VoidCallback? onTap, // ✅ Новый параметр
      }) {
    return GestureDetector( // ✅ Оборачиваем в GestureDetector
        onTap: onTap,
        child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [

          // Статус и номер заказа
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                orderNumber,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Товар
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Кнопка Order details
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                _navigateToOrder(context, rawStatus, orderId, orderNumber);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t('orderDetails'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  void _navigateToOrder(BuildContext context, String status, String orderId, String orderNumber) {
    final activeStatuses = ['placed', 'collecting', 'delivery', 'in progress'];
    if (activeStatuses.contains(status.toLowerCase())) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderInProgressScreen(
            orderNumber: orderNumber,
            orderId: orderId,
            status: status,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderDetailScreen(
            orderNumber: orderNumber,
            orderId: orderId,
          ),
        ),
      );
    }
  }

  Widget _buildOrderItemFromOrder(Order order, BuildContext context, AppTranslations t) {
    final firstItem = order.items.firstOrNull; // ✅ Первый товар для превью
    return _buildOrderItem(
      context,
      status: t('order_status_${order.status.toLowerCase()}'), // ✅ Локализованный статус
      statusColor: Color(int.parse('0xFF${order.statusColorHex}')), // ✅ Цвет из модели
      orderNumber: '№${order.id}',
      productName: firstItem?.name ?? t('order_preview'),
      price: order.formattedTotal, // ✅ "42 480 ₸" из модели
      orderId:     order.id, // ✅ Передаём ID заказа для навигации
      rawStatus: order.status,
      t: t,
      onTap: () => _navigateToOrder(context, order.status, order.id, '№${order.id}'),
    );
  }
}