import 'package:flutter/material.dart';

import 'orderComplete.dart';
import 'orderInProgress.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My orders',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildOrderItem(
            context,
            status: 'In progress',
            statusColor: Colors.yellow,
            orderNumber: '№896743553',
            productName: 'Rose bouquet',
            price: '42 480₸',
          ),
          const SizedBox(height: 12),
          _buildOrderItem(
            context,
            status: 'Complete',
            statusColor: Colors.green,
            orderNumber: '№896743553',
            productName: 'Rose bouquet',
            price: '42 480₸',
          ),
          const SizedBox(height: 12),
          _buildOrderItem(
            context,
            status: 'Declined',
            statusColor: Colors.red,
            orderNumber: '№896743553',
            productName: 'Rose bouquet',
            price: '42 480₸',
          ),
          const SizedBox(height: 12),
          _buildOrderItem(
            context,
            status: 'In progress',
            statusColor: Colors.yellow,
            orderNumber: '№896743553',
            productName: 'Rose bouquet',
            price: '42 480₸',
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(
      BuildContext context, {
        required String status,
        required Color statusColor,
        required String orderNumber,
        required String productName,
        required String price,
      }) {
    return Container(
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
                // Переход к деталям заказа
                if (status == 'In progress') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderInProgressScreen(
                        orderNumber: orderNumber,
                      ),
                    ),
                  );
                } else {
                  // Complete или Declined
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderCompleteScreen(
                        orderNumber: orderNumber,
                      ),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Order details',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}