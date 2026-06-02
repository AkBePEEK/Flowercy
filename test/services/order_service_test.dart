import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowery_app/models/order.dart';
import 'package:flowery_app/models/orderItem.dart';
import 'package:flowery_app/services/orderService.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late OrderService orderService;

  final mockUser = MockUser(uid: 'user123');

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
    orderService = OrderService(firestore: firestore, auth: auth);
  });

  group('OrderService Tests', () {
    test('createOrder adds an order to firestore', () async {
      final order = Order(
        id: '',
        userId: 'user123',
        items: [
          OrderItem(productId: 'p1', name: 'Product 1', price: 1000, quantity: 1)
        ],
        total: 1000,
        status: 'placed',
        recipient: 'Recipient',
        address: 'Test Address',
        deliveryTime: '10:00',
        payment: 'Card',
        createdAt: DateTime.now(), sellerComment: null,
      );

      final orderId = await orderService.createOrder(order);
      expect(orderId, isNotEmpty);

      final doc = await firestore.collection('orders').doc(orderId).get();
      expect(doc.exists, true);
      expect(doc.data()!['userId'], 'user123');
    });

    test('getUserOrders returns current user orders', () async {
      final now = DateTime.now();
      await firestore.collection('orders').add({
        'userId': 'user123',
        'items': [],
        'total': 1000,
        'status': 'placed',
        'recipient': 'Recipient',
        'address': 'Address',
        'deliveryTime': '10:00',
        'payment': 'Card',
        'createdAt': Timestamp.fromDate(now),
      });
      await firestore.collection('orders').add({
        'userId': 'other_user',
        'items': [],
        'total': 1000,
        'status': 'placed',
        'recipient': 'Recipient',
        'address': 'Address',
        'deliveryTime': '10:00',
        'payment': 'Card',
        'createdAt': Timestamp.fromDate(now),
      });

      final orders = await orderService.getUserOrders();
      expect(orders.length, 1);
      expect(orders.first.userId, 'user123');
    });

    test('updateOrderStatus changes order status', () async {
      final docRef = await firestore.collection('orders').add({
        'status': 'placed',
      });

      await orderService.updateOrderStatus(docRef.id, 'delivered');

      final updatedDoc = await docRef.get();
      expect(updatedDoc.data()!['status'], 'delivered');
    });
  });
}
