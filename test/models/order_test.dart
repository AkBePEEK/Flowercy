import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowery_app/models/order.dart';
import 'package:flowery_app/models/orderItem.dart';

void main() {
  group('Order Model Tests', () {
    test('fromFirestore should create an Order object correctly', () async {
      final firestore = FakeFirebaseFirestore();
      final now = DateTime.now();
      final data = {
        'userId': 'user123',
        'items': [
          {'productId': 'p1', 'name': 'Rose', 'quantity': 2, 'price': 1000}
        ],
        'total': 2000,
        'status': 'Placed',
        'recipient': 'Alice',
        'shopAddress': 'Street 1',
        'pickupTime': '10:00',
        'payment': 'Card',
        'createdAt': Timestamp.fromDate(now),
      };

      await firestore.collection('orders').doc('ord123').set(data);
      final snapshot = await firestore.collection('orders').doc('ord123').get();

      final order = Order.fromFirestore(snapshot);

      expect(order.id, 'ord123');
      expect(order.userId, 'user123');
      expect(order.items.length, 1);
      expect(order.items[0].name, 'Rose');
      expect(order.total, 2000);
      expect(order.status, 'Placed');
    });

    test('toFirestore should return a correct map', () {
      final now = DateTime.now();
      final order = Order(
        id: 'ord123',
        userId: 'user123',
        items: [OrderItem(productId: 'p1', name: 'Rose', quantity: 2, price: 1000)],
        total: 2000,
        status: 'Placed',
        recipient: 'Alice',
        shopAddress: 'Street 1',
        pickupTime: '10:00',
        payment: 'Card',
        createdAt: now, sellerComment: null,
      );

      final map = order.toFirestore();

      expect(map['userId'], 'user123');
      expect(map['total'], 2000);
      expect(map['status'], 'Placed');
      expect(map['items'], isA<List>());
      expect(map['createdAt'], isA<Timestamp>());
    });

    test('getters should return correct values', () {
      final order = Order(
        id: 'ord123',
        userId: 'user123',
        items: [
          OrderItem(productId: 'p1', name: 'Rose', quantity: 2, price: 1000),
          OrderItem(productId: 'p2', name: 'Lily', quantity: 1, price: 1500),
        ],
        total: 3500,
        status: 'Complete',
        recipient: 'Alice',
        shopAddress: 'Street 1',
        pickupTime: '10:00',
        payment: 'Card',
        createdAt: DateTime.now(), sellerComment: null,
      );

      expect(order.formattedTotal, '3500 ₸');
      expect(order.itemsCount, 3);
      expect(order.statusText, 'Получен');
      expect(order.statusColorHex, '00C853');
      expect(order.canCancel, false);
      expect(order.canRepeat, true);
    });
  });
}
