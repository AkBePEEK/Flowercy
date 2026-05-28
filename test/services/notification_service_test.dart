import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowery_app/services/notificationService.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late NotificationService notificationService;

  final mockUser = MockUser(uid: 'user123');

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
    notificationService = NotificationService(firestore: firestore, auth: auth);
  });

  group('NotificationService Tests', () {
    test('addNotification adds a notification to user collection', () async {
      await notificationService.addNotification(
        title: 'Order Placed',
        body: 'Your order #1 has been placed',
        orderId: 'order1',
      );

      final snapshot = await firestore
          .collection('users')
          .doc('user123')
          .collection('notifications')
          .get();

      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['title'], 'Order Placed');
    });

    test('getNotifications returns user notifications', () async {
      await firestore
          .collection('users')
          .doc('user123')
          .collection('notifications')
          .add({
        'title': 'Test Notification',
        'body': 'Body',
        'type': 'order',
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'isRead': false,
      });

      final notifications = await notificationService.getNotifications();
      expect(notifications.length, 1);
      expect(notifications.first.title, 'Test Notification');
    });

    test('markAsRead updates notification status', () async {
      final docRef = await firestore
          .collection('users')
          .doc('user123')
          .collection('notifications')
          .add({
        'title': 'Unread',
        'isRead': false,
      });

      await notificationService.markAsRead(docRef.id);

      final updatedDoc = await docRef.get();
      expect(updatedDoc.data()!['isRead'], true);
    });

    test('getUnreadCount returns correct count', () async {
      await firestore
          .collection('users')
          .doc('user123')
          .collection('notifications')
          .add({'isRead': false});
      await firestore
          .collection('users')
          .doc('user123')
          .collection('notifications')
          .add({'isRead': true});

      final count = await notificationService.getUnreadCount();
      expect(count, 1);
    });
  });
}
