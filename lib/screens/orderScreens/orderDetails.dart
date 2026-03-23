import 'package:flutter/material.dart';

import 'courierComment.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  // ✅ Переменные для выбора
  int _selectedDeliveryIndex = 0;
  int _selectedPaymentIndex = 0;
  String _courierComment = 'Add';

  // Данные доставки
  final List<Map<String, String>> _deliveryOptions = [
    {
      'title': 'Faster',
      'subtitle': 'in 45 - 55 min.',
      'price': 'Free',
    },
    {
      'title': 'Another time',
      'subtitle': 'Choose date and time',
      'price': '',
    },
    {
      'title': 'Faster',
      'subtitle': 'in 45 - 55 min.',
      'price': 'Free',
    },
  ];

  // Данные оплаты
  final List<Map<String, String>> _paymentOptions = [
    {
      'title': 'Bank card',
      'subtitle': 'Pay now',
    },
    {
      'title': 'Kaspi.kz',
      'subtitle': 'Pay now',
    },
    {
      'title': 'Upon receipt',
      'subtitle': 'Payment receipt',
    },
  ];

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
        title: const Text(
          'Order details',
          style: TextStyle(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(),
                  const SizedBox(height: 24),
                  _buildDeliverySection(),
                  const SizedBox(height: 24),
                  _buildImportantDetailsSection(),
                  const SizedBox(height: 24),
                  _buildPaymentSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildBottomSection(context),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      children: [
        _buildInfoRow('Recipient', 'Lada'),
        const Divider(height: 1),
        _buildInfoRow('Address', 'Astana, Uly Dala Avenue, 31'),
        const Divider(height: 1),
        _buildInfoRow('Apt./Office/Floor/Entrance', 'Apt. 510 /...'),
        const Divider(height: 1),
        _buildInfoRow(
          'Comment for the courier',
          _courierComment.isEmpty ? 'Add' : _courierComment,
          isAddable: true,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAddable = false}) {
    return GestureDetector(
      onTap: isAddable ? () => _showCourierComment() : null,
      child: Container(
        padding: const EdgeInsets.all(16),
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
                    color: isAddable ? Colors.grey[700] : Colors.black,
                    fontWeight: isAddable ? FontWeight.w400 : FontWeight.w500,
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

// Метод для показа модального окна
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
      print('💬 Courier comment: $result');
    }
  }

  // ✅ Доставка с кликабельными элементами
  Widget _buildDeliverySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Delivery',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    _deliveryOptions[_selectedDeliveryIndex]['subtitle']!,
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
              itemCount: _deliveryOptions.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final option = _deliveryOptions[index];
                final isSelected = index == _selectedDeliveryIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDeliveryIndex = index;
                    });
                    print('✅ Delivery selected: ${option['title']} (${option['subtitle']})');
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

  // ... (_buildImportantDetailsSection без изменений) ...

  Widget _buildImportantDetailsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Important details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  const Text(
                    'Select',
                    style: TextStyle(
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
            'For example: include your name in the SMS or arrange a surprise',
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
  Widget _buildPaymentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _paymentOptions.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final option = _paymentOptions[index];
                final isSelected = index == _selectedPaymentIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPaymentIndex = index;
                    });
                    print('✅ Payment selected: ${option['title']}');
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

  Widget _buildBottomSection(BuildContext context) {
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
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  '42 480 ₸',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                print('💳 Pay for order');
                print('🚚 Delivery: ${_deliveryOptions[_selectedDeliveryIndex]['title']}');
                print('💰 Payment: ${_paymentOptions[_selectedPaymentIndex]['title']}');
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
                'Pay for the order',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}