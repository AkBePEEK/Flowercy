import 'package:flutter/material.dart';
import 'dart:convert'; // ✅ Добавлено для base64
import '../../models/order.dart';
import '../../models/bouquetRequest.dart';
import '../../services/language_service.dart';
import '../../services/orderService.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> with LanguageStateMixin {
  final OrderService _orderService = OrderService();

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
            t('order_management'),
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
      stream: _orderService.getAllOrdersStream(),
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
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildOrderAdminCard(orders[index], t),
        );
      },
    );
  }

  Widget _buildRequestsList(AppTranslations t) {
    return StreamBuilder<List<BouquetRequest>>(
      stream: _orderService.getAllBouquetRequestsStream(),
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
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildRequestAdminCard(requests[index], t),
        );
      },
    );
  }

  Widget _buildOrderAdminCard(Order order, AppTranslations t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '№${order.id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              _buildStatusBadge(order.status, t),
            ],
          ),
          const SizedBox(height: 8),
          Text('${t('recipient')}: ${order.recipient}'),
          Text('${t('total')}: ${order.formattedTotal}'),
          const Divider(height: 24),
          Text(t('change_status'), style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _statusButton(order.id, 'placed', t('order_status_placed'), Colors.blue),
              _statusButton(order.id, 'collecting', t('order_status_collecting'), Colors.orange),
              _statusButton(order.id, 'delivery', t('order_status_delivery'), Colors.purple),
              _statusButton(order.id, 'delivered', t('order_status_delivered'), Colors.green),
              _statusButton(order.id, 'cancelled', t('order_cancelled_msg'), Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestAdminCard(BouquetRequest request, AppTranslations t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (request.image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: _buildImage(request.image),
                  ),
                ),
              if (request.image != null) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          request.bouquetName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        _buildRequestStatusBadge(request.status, t),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${t('recipient')}: ${request.userName}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (request.userPhone.isNotEmpty) Text('📞 ${request.userPhone}'),
          Text('💐 ${request.flowers}'),
          Text('💰 ${request.price} ₸'),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (request.status == 'pending') ...[
                TextButton(
                  onPressed: () => _orderService.updateRequestStatus(request.id, 'cancelled'),
                  child: Text(t('cancel'), style: const TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _orderService.updateRequestStatus(request.id, 'accepted'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: Text(t('accept')),
                ),
              ],
              if (request.status == 'accepted')
                ElevatedButton(
                  onPressed: () => _orderService.updateRequestStatus(request.id, 'completed'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  child: Text(t('complete')),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String? imageData) {
    if (imageData == null || imageData.isEmpty) return const Icon(Icons.image_not_supported);

    if (imageData.startsWith('http')) {
      return Image.network(
        imageData,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      );
    } else {
      try {
        String base64Str = imageData;
        if (base64Str.contains(',')) {
          base64Str = base64Str.split(',').last;
        }
        return Image.memory(
          base64Decode(base64Str),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
        );
      } catch (e) {
        return const Icon(Icons.broken_image);
      }
    }
  }

  Widget _buildStatusBadge(String status, AppTranslations t) {
    Color color;
    switch (status.toLowerCase()) {
      case 'placed': color = Colors.blue; break;
      case 'collecting': color = Colors.orange; break;
      case 'delivery': color = Colors.purple; break;
      case 'delivered': color = Colors.green; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        t('order_status_${status.toLowerCase()}'),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRequestStatusBadge(String status, AppTranslations t) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending': color = Colors.orange; break;
      case 'accepted': color = Colors.green; break;
      case 'completed': color = Colors.blue; break;
      case 'cancelled': color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        t('request_status_${status.toLowerCase()}'),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _statusButton(String orderId, String status, String label, Color color) {
    return ElevatedButton(
      onPressed: () => _orderService.updateOrderStatus(orderId, status),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }
}
