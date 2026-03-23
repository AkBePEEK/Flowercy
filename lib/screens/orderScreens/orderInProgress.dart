import 'package:flutter/material.dart';

class OrderInProgressScreen extends StatelessWidget {
  final String orderNumber;

  const OrderInProgressScreen({
    super.key,
    this.orderNumber = '№896743553',
  });

  @override
  Widget build(BuildContext context) {
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
          'Order $orderNumber',
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
                    // Иконка подтверждения
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB07183).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        size: 60,
                        color: Color(0xFFB07183),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Текст подтверждения
                    const Text(
                      'The order has been placed',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB07183),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 60),
                    // Трекер прогресса
                    _buildProgressTracker(),
                    const SizedBox(height: 60),
                    // Кнопки Support и Details
                    _buildActionButtons(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          // Кнопка Cancel order
          _buildCancelButton(context),
        ],
      ),
    );
  }

  // Трекер прогресса
  Widget _buildProgressTracker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Шаг 1: Заказ размещен (активен)
        _buildProgressStep(
          icon: Icons.check,
          isActive: true,
          isCompleted: true,
        ),
        // Линия
        Expanded(
          child: Container(
            height: 2,
            color: Colors.grey[300],
            margin: const EdgeInsets.only(bottom: 15),
          ),
        ),
        // Шаг 2: Собирается
        _buildProgressStep(
          icon: Icons.shopping_bag,
          isActive: false,
          isCompleted: false,
        ),
        // Линия
        Expanded(
          child: Container(
            height: 2,
            color: Colors.grey[300],
            margin: const EdgeInsets.only(bottom: 15),
          ),
        ),
        // Шаг 3: Доставка
        _buildProgressStep(
          icon: Icons.local_shipping,
          isActive: false,
          isCompleted: false,
        ),
        // Линия
        Expanded(
          child: Container(
            height: 2,
            color: Colors.grey[300],
            margin: const EdgeInsets.only(bottom: 15),
          ),
        ),
        // Шаг 4: Доставлен
        _buildProgressStep(
          icon: Icons.flag,
          isActive: false,
          isCompleted: false,
        ),
      ],
    );
  }

  // Шаг прогресса
  Widget _buildProgressStep({
    required IconData icon,
    required bool isActive,
    required bool isCompleted,
  }) {
    Color backgroundColor;
    Color iconColor;

    if (isCompleted) {
      backgroundColor = const Color(0xFFB07183);
      iconColor = Colors.white;
    } else if (isActive) {
      backgroundColor = const Color(0xFFB07183);
      iconColor = Colors.white;
    } else {
      backgroundColor = Colors.grey[200]!;
      iconColor = Colors.grey[400]!;
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 24,
      ),
    );
  }

  // Кнопки действий
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Support
        _buildActionButton(
          icon: Icons.headset_mic,
          label: 'Support',
          onTap: () {
            print('💬 Support');
          },
        ),
        const SizedBox(width: 16),
        // Details
        _buildActionButton(
          icon: Icons.list,
          label: 'Details',
          onTap: () {
            print('📋 Details');
          },
        ),
      ],
    );
  }

  // Кнопка действия
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
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
            child: Icon(
              icon,
              color: const Color(0xFFB07183),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // Кнопка отмены заказа
  Widget _buildCancelButton(BuildContext context) {
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
          onPressed: () {
            _showCancelDialog(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB07183),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text(
            'Cancel order',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // Диалог отмены заказа
  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel order?'),
        content: const Text(
          'Are you sure you want to cancel this order?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Закрыть диалог
              Navigator.pop(context); // Вернуться назад
              print('❌ Order cancelled');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}