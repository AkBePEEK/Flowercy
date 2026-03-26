class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final int price;
  final String? image; // Опционально: изображение товара

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    this.image,
  });

  // ✅ Из Map в объект
  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 1,
      price: data['price'] ?? 0,
      image: data['image'],
    );
  }

  // ✅ Из объекта в Map
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'image': image,
    };
  }

  // ✅ Общая цена для позиции
  int get totalPrice => price * quantity;

  // ✅ Форматированная цена
  String get formattedPrice => '$price ₸';

  // ✅ Форматированная общая цена
  String get formattedTotalPrice => '$totalPrice ₸';
}