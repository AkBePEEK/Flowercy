import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Получить все уведомления пользователя
  Future<List<AppNotification>> getNotifications() async {
    if (_userId == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Добавить уведомление (вызывается при создании заказа)
  Future<void> addNotification({
    required String title,
    required String body,
    String type = 'order',
    String? orderId,
  }) async {
    if (_userId == null) return;

    final notification = AppNotification(
      id: '',
      title: title,
      body: body,
      type: type,
      createdAt: DateTime.now(),
      orderId: orderId,
    );

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .add(notification.toMap());
  }

  // Отметить как прочитанное
  Future<void> markAsRead(String notificationId) async {
    if (_userId == null) return;

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  // Количество непрочитанных
  Future<int> getUnreadCount() async {
    if (_userId == null) return 0;

    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    return snapshot.docs.length;
  }
}