import 'package:flutter_test/flutter_test.dart';
import 'package:flowery_app/models/cartItem.dart';

void main() {
  group('CartItem Model Tests', () {
    test('fromMap should create a CartItem object correctly', () {
      final map = {
        'productId': 'p1',
        'name': 'Rose',
        'price': 1000,
        'quantity': 2,
        'image': 'img.png',
        'shopId': 's1',
      };

      final item = CartItem.fromMap(map);

      expect(item.productId, 'p1');
      expect(item.name, 'Rose');
      expect(item.price, 1000);
      expect(item.quantity, 2);
      expect(item.image, 'img.png');
      expect(item.shopId, 's1');
    });

    test('totalPrice and formatted getters should work', () {
      final item = CartItem(
        productId: 'p1',
        name: 'Rose',
        price: 1500,
        quantity: 3,
      );

      expect(item.totalPrice, 4500);
      expect(item.formattedPrice, '1500 ₸');
      expect(item.formattedTotalPrice, '4500 ₸');
    });

    test('copyWith should update quantity correctly', () {
      final item = CartItem(
        productId: 'p1',
        name: 'Rose',
        price: 1000,
        quantity: 1,
      );

      final updated = item.copyWith(quantity: 5);

      expect(updated.quantity, 5);
      expect(updated.productId, 'p1');
    });
  });
}
