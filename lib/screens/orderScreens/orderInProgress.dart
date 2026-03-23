import 'package:flutter/material.dart';

class OrderInProgressScreen extends StatelessWidget {
  final String orderNumber;
  final String status; // ✅ Добавляем статус

  const OrderInProgressScreen({
    super.key,
    this.orderNumber = '№896743553',
    this.status = 'Placed', // Placed, Collecting, Delivery, Delivered
  });

  // ✅ Получаем данные для каждого статуса
  Map<String, dynamic> _getStatusData() {
    switch (status.toLowerCase()) {
      case 'placed':
        return {
          'icon': 'assets/orderStatus/placed.png',
          'title': 'The order has been placed',
          'completedSteps': 1,
        };
      case 'collecting':
        return {
          'icon': 'assets/orderStatus/collecting.png', // Или custom icon букета
          'title': 'Collecting the order',
          'completedSteps': 2,
        };
      case 'delivery':
        return {
          'icon': 'assets/orderStatus/delivery.png',
          'title': 'The courier is on his way',
          'completedSteps': 3,
        };
      case 'delivered':
        return {
          'icon': 'assets/orderStatus/delivered.png',
          'title': 'The order has been delivered',
          'completedSteps': 4,
        };
      default:
        return {
          'icon': 'assets/orderStatus/collecting.png',
          'title': 'The order has been placed',
          'completedSteps': 1,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusData = _getStatusData();

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
                    // ✅ Динамическая иконка статуса
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
                      ),
                    ),
                    const SizedBox(height: 24),
                    // ✅ Динамический текст статуса
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
                    // ✅ Трекер прогресса с динамическими шагами
                    _buildProgressTracker(statusData['completedSteps']),
                    const SizedBox(height: 60),
                    // Кнопки Support и Details
                    _buildActionButtons(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          // Кнопка Cancel order (показываем только если заказ не доставлен)
          if (status.toLowerCase() != 'delivered')
            _buildCancelButton(context),
        ],
      ),
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
  }) {
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
        color: isCompleted ? Colors.white : Color(0xFFC8C8C8),
        errorBuilder: (context, error, stackTrace) {
          // Fallback на иконку если изображение не найдено
          return Icon(
            icon,
            color: isCompleted ? Colors.white : Color(0xFFC8C8C8),
            size: 32,
          );
        },
      ),
    );
  }

  // Кнопки действий
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          icon: Icons.headset_mic,
          label: 'Support',
          onTap: () {
            print('💬 Support');
          },
        ),
        const SizedBox(width: 16),
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
              Navigator.pop(context);
              Navigator.pop(context);
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