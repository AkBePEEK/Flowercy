class CartItem {
  final String productId;
  final String name;
  final int price;
  final int quantity;
  final String? image;
  final String? shopId;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.image,
    this.shopId,
  });

  // ✅ Из Map в объект
  factory CartItem.fromMap(Map<String, dynamic> data) {
    return CartItem(
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      quantity: data['quantity'] ?? 1,
      image: data['image'],
      shopId: data['shopId'],
    );
  }

  // ✅ Из объекта в Map
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image': image,
      'shopId': shopId,
    };
  }

  // ✅ Общая цена для позиции
  int get totalPrice => price * quantity;

  // ✅ Форматированная цена
  String get formattedPrice => '$price ₸';

  // ✅ Форматированная общая цена
  String get formattedTotalPrice => '$totalPrice ₸';

  // ✅ Копия с изменениями (для обновления количества)
  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      name: name,
      price: price,
      quantity: quantity ?? this.quantity,
      image: image,
      shopId: shopId,
    );
  }
}