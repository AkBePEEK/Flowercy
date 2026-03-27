import 'package:cloud_firestore/cloud_firestore.dart';

import 'orderItem.dart';

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final int total;
  final String status; // "Complete", "In progress", "Declined", "Placed", "Collecting", "Delivery", "Delivered"
  final String recipient;
  final String address;
  final String? apartment; // Опционально: квартира/офис
  final String deliveryTime;
  final String payment;
  final String? comment; // Опционально: комментарий курьеру
  final DateTime createdAt;
  final DateTime? updatedAt; // Опционально: время обновления статуса

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.recipient,
    required this.address,
    this.apartment,
    required this.deliveryTime,
    required this.payment,
    this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  // ✅ Из Firestore в объект
  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      userId: data['userId'] ?? '',
      items: (data['items'] as List?)
          ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList() ??
          [],
      total: data['total'] ?? 0,
      status: data['status'] ?? 'In progress',
      recipient: data['recipient'] ?? '',
      address: data['address'] ?? '',
      apartment: data['apartment'],
      deliveryTime: data['deliveryTime'] ?? '',
      payment: data['payment'] ?? '',
      comment: data['comment'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // ✅ Из объекта в Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'status': status,
      'recipient': recipient,
      'address': address,
      'apartment': apartment,
      'deliveryTime': deliveryTime,
      'payment': payment,
      'comment': comment,
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
      case 'complete':
        return 'Выполнен';
      case 'in progress':
        return 'В процессе';
      case 'declined':
        return 'Отклонен';
      case 'placed':
        return 'Размещен';
      case 'collecting':
        return 'Собирается';
      case 'delivery':
        return 'Доставляется';
      case 'delivered':
        return 'Доставлен';
      default:
        return status;
    }
  }

  // ✅ Цвет статуса для UI
  String get statusColorHex {
    switch (status.toLowerCase()) {
      case 'complete':
      case 'delivered':
        return '00C853'; // Зелёный
      case 'in progress':
      case 'collecting':
      case 'delivery':
      case 'placed':
        return 'FF9800'; // Оранжевый
      case 'declined':
      case 'cancelled':
        return 'F44336'; // Красный
      default:
        return '9E9E9E'; // Серый
    }
  }

  // ✅ Проверка, можно ли отменить заказ
  bool get canCancel {
    final cancelStatuses = ['placed', 'in progress', 'collecting'];
    return cancelStatuses.contains(status.toLowerCase());
  }

  // ✅ Проверка, можно ли повторить заказ
  bool get canRepeat {
    final repeatStatuses = ['complete', 'delivered'];
    return repeatStatuses.contains(status.toLowerCase());
  }
}