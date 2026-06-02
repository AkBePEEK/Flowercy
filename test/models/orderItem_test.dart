import 'package:flutter_test/flutter_test.dart';
import 'package:flowery_app/models/orderItem.dart';

void main() {
  group('OrderItem Model Tests', () {
    test('fromMap should create an OrderItem object correctly', () {
      final map = {
        'productId': 'p1',
        'name': 'Rose',
        'quantity': 5,
        'price': 1000,
        'image': 'rose.png',
      };

      final item = OrderItem.fromMap(map);

      expect(item.productId, 'p1');
      expect(item.name, 'Rose');
      expect(item.quantity, 5);
      expect(item.price, 1000);
      expect(item.image, 'rose.png');
    });

    test('toMap should return a correct map', () {
      final item = OrderItem(
        productId: 'p1',
        name: 'Rose',
        quantity: 5,
        price: 1000,
        image: 'rose.png',
      );

      final map = item.toMap();

      expect(map['productId'], 'p1');
      expect(map['quantity'], 5);
      expect(map['price'], 1000);
    });

    test('getters should return correct values', () {
      final item = OrderItem(
        productId: 'p1',
        name: 'Rose',
        quantity: 3,
        price: 1200,
      );

      expect(item.totalPrice, 3600);
      expect(item.formattedPrice, '1200 ₸');
      expect(item.formattedTotalPrice, '3600 ₸');
    });
  });
}
