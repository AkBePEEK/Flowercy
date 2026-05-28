import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowery_app/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('fromFirestore should create a User object correctly', () async {
      final firestore = FakeFirebaseFirestore();
      final now = DateTime.now();
      final data = {
        'email': 'test@test.com',
        'name': 'User',
        'favorites': ['p1'],
        'cart': [{'productId': 'p1', 'name': 'Rose', 'price': 1000, 'quantity': 1}],
        'addresses': [{'id': 'a1', 'street': 'Street', 'city': 'City'}],
        'createdAt': Timestamp.fromDate(now),
      };

      await firestore.collection('users').doc('u123').set(data);
      final snapshot = await firestore.collection('users').doc('u123').get();

      final user = User.fromFirestore(snapshot);

      expect(user.id, 'u123');
      expect(user.email, 'test@test.com');
      expect(user.favorites.length, 1);
      expect(user.cart.length, 1);
      expect(user.addresses.length, 1);
    });

    test('toFirestore should return a correct map', () {
      final now = DateTime.now();
      final user = User(
        id: 'u123',
        email: 'test@test.com',
        createdAt: now,
      );

      final map = user.toFirestore();

      expect(map['email'], 'test@test.com');
      expect(map['createdAt'], isA<Timestamp>());
    });
  });
}
