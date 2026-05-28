import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowery_app/models/notification.dart';

void main() {
  group('AppNotification Model Tests', () {
    test('fromMap should create an AppNotification object correctly', () {
      final now = DateTime.now();
      final map = {
        'title': 'Test Title',
        'body': 'Test Body',
        'type': 'order',
        'isRead': true,
        'createdAt': Timestamp.fromDate(now),
        'orderId': 'ord123',
      };

      final notification = AppNotification.fromMap(map, 'notif1');

      expect(notification.id, 'notif1');
      expect(notification.title, 'Test Title');
      expect(notification.isRead, true);
      expect(notification.orderId, 'ord123');
      // Timestamp precision might vary slightly, but toDate() should be close
      expect(notification.createdAt.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
    });

    test('toMap should return a correct map', () {
      final now = DateTime.now();
      final notification = AppNotification(
        id: 'notif1',
        title: 'Title',
        body: 'Body',
        type: 'system',
        createdAt: now,
      );

      final map = notification.toMap();

      expect(map['title'], 'Title');
      expect(map['type'], 'system');
      expect(map['isRead'], false);
      expect(map['createdAt'], isA<Timestamp>());
    });
  });
}
