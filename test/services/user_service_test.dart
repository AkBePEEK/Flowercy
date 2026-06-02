import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowery_app/services/userService.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late UserService userService;

  final mockUser = MockUser(uid: 'user123', email: 'test@example.com');

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
    userService = UserService(firestore: firestore, auth: auth);
  });

  group('UserService Tests', () {
    test('getCurrentUser returns user model', () async {
      await firestore.collection('users').doc('user123').set({
        'email': 'test@example.com',
        'name': 'Test User',
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });

      final user = await userService.getCurrentUser();
      expect(user, isNotNull);
      expect(user!.email, 'test@example.com');
      expect(user.name, 'Test User');
    });

    test('createUser saves user to firestore', () async {
      await userService.createUser(
        email: 'test@example.com',
        name: 'Test User',
      );

      final doc = await firestore.collection('users').doc('user123').get();
      expect(doc.exists, true);
      expect(doc.data()!['email'], 'test@example.com');
    });

    test('updateProfile updates user data', () async {
      await firestore.collection('users').doc('user123').set({
        'name': 'Old Name',
      });

      await userService.updateProfile(name: 'New Name');

      final doc = await firestore.collection('users').doc('user123').get();
      expect(doc.data()!['name'], 'New Name');
    });

    test('addToFavorites adds product id to favorites array', () async {
      await firestore.collection('users').doc('user123').set({
        'favorites': [],
      });

      await userService.addToFavorites('prod123');

      final doc = await firestore.collection('users').doc('user123').get();
      expect(List<String>.from(doc.data()!['favorites']), contains('prod123'));
    });
  });
}
