import 'package:cloud_firestore/cloud_firestore.dart';

import 'orderItem.dart';

class Order {
  final String id;
  final String userId;
  final String? shopId; // ✅ Добавлено: ID магазина
  final List<OrderItem> items;
  final int total;
  final String status; // "Placed", "Collecting", "Ready", "Complete", "Cancelled"
  final String recipient;
  final String shopAddress; // ✅ Переименовано: адрес магазина вместо адреса доставки
  final String pickupTime; // ✅ Переименовано: время самовывоза
  final String payment;
  final String? sellerComment; // ✅ Добавлено
  final DateTime createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.userId,
    this.shopId,
    required this.items,
    required this.total,
    required this.status,
    required this.recipient,
    required this.shopAddress,
    required this.pickupTime,
    required this.payment,
    this.sellerComment,
    required this.createdAt,
    this.updatedAt,
  });

  // ✅ Из Firestore в объект
  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      userId: data['userId'] ?? '',
      shopId: data['shopId'],
      items: (data['items'] as List?)
          ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList() ??
          [],
      total: data['total'] ?? 0,
      status: data['status'] ?? 'Placed',
      recipient: data['recipient'] ?? '',
      shopAddress: data['shopAddress'] ?? data['address'] ?? '', // Fallback на старое поле
      pickupTime: data['pickupTime'] ?? data['deliveryTime'] ?? '',
      payment: data['payment'] ?? '',
      sellerComment: data['sellerComment'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // ✅ Из объекта в Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'shopId': shopId,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'status': status,
      'recipient': recipient,
      'shopAddress': shopAddress,
      'pickupTime': pickupTime,
      'payment': payment,
      'sellerComment': sellerComment,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // ✅ Форматированная цена
  String get formattedTotal => '$total ₸';

  // ✅ Количество товаров в заказе
  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  // ✅ Статус в виде текста для UI
  String get statusText {
    switch (status.toLowerCase()) {
      case 'placed':
        return 'Оформлен';
      case 'collecting':
        return 'Сборка';
      case 'ready':
        return 'Готов к выдаче';
      case 'complete':
        return 'Получен';
      case 'cancelled':
        return 'Отменен';
      default:
        return status;
    }
  }

  // ✅ Цвет статуса для UI
  String get statusColorHex {
    switch (status.toLowerCase()) {
      case 'complete':
        return '00C853'; // Зелёный
      case 'ready':
        return '2196F3'; // Синий
      case 'collecting':
      case 'placed':
        return 'FF9800'; // Оранжевый
      case 'cancelled':
        return 'F44336'; // Красный
      default:
        return '9E9E9E'; // Серый
    }
  }

  // ✅ Проверка, можно ли отменить заказ
  bool get canCancel {
    final cancelStatuses = ['placed', 'collecting'];
    return cancelStatuses.contains(status.toLowerCase());
  }

  // ✅ Проверка, можно ли повторить заказ
  bool get canRepeat {
    final repeatStatuses = ['complete'];
    return repeatStatuses.contains(status.toLowerCase());
  }
}