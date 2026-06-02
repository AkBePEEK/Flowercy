import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowery_app/services/auth_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late AuthService authService;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth();
    authService = AuthService(auth: auth, firestore: firestore);
  });

  group('AuthService Tests', () {
    test('signUp creates user and saves data to firestore', () async {
      final result = await authService.signUp(
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User',
      );

      expect(result['success'], true);
      final user = result['user'];
      expect(user, isNotNull);

      final doc = await firestore.collection('users').doc(user.uid).get();
      expect(doc.exists, true);
      expect(doc.data()!['email'], 'test@example.com');
      expect(doc.data()!['name'], 'Test User');
    });

    test('signIn authenticates user', () async {
      // First sign up
      await auth.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      final result = await authService.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result['success'], true);
      expect(result['user'], isNotNull);
    });

    test('signOut signs out user', () async {
      await auth.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(auth.currentUser, isNotNull);

      await authService.signOut();
      expect(auth.currentUser, isNull);
    });
  });
}
