import 'package:cloud_firestore/cloud_firestore.dart';

import 'cartItem.dart';

class User {
  final String id; // UID из Firebase Auth
  final String email;
  final String? name;
  final String? phone;
  final List<String> favorites; // ID избранных товаров
  final List<CartItem> cart; // Корзина
  final List<String> orders; // ID заказов пользователя
  final String? avatarUrl; // URL аватара
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive; // Активен ли аккаунт

  User({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.favorites = const [],
    this.cart = const [],
    this.orders = const [],
    this.avatarUrl,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  // ✅ Из Firestore в объект
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'],
      phone: data['phone'],
      favorites: List<String>.from(data['favorites'] ?? []),
      cart: (data['cart'] as List?)
          ?.map((item) => CartItem.fromMap(item as Map<String, dynamic>))
          .toList() ??
          [],
      orders: List<String>.from(data['orders'] ?? []),
      avatarUrl: data['avatarUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  // ✅ Из объекта в Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'favorites': favorites,
      'cart': cart.map((item) => item.toMap()).toList(),
      'orders': orders,
      'avatarUrl': avatarUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isActive': isActive,
    };
  }

  // ✅ Пустой пользователь (для начального состояния)
  factory User.empty(String uid, String email) {
    return User(
      id: uid,
      email: email,
      createdAt: DateTime.now(),
    );
  }

  // ✅ Копия с изменениями (для обновлений)
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    List<String>? favorites,
    List<CartItem>? cart,
    List<String>? orders,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      favorites: favorites ?? this.favorites,
      cart: cart ?? this.cart,
      orders: orders ?? this.orders,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // ✅ Количество избранных товаров
  int get favoritesCount => favorites.length;

  // ✅ Количество товаров в корзине
  int get cartItemsCount => cart.fold(0, (sum, item) => sum + item.quantity);

  // ✅ Общая сумма корзины
  int get cartTotal => cart.fold(0, (sum, item) => sum + item.totalPrice);

  // ✅ Форматированная сумма корзины
  String get formattedCartTotal => '$cartTotal ₸';

  // ✅ Проверка, заполнен ли профиль
  bool get isProfileComplete => name != null && phone != null;

  // ✅ Проверка, есть ли товары в корзине
  bool get hasCartItems => cart.isNotEmpty;

  // ✅ Проверка, есть ли избранные товары
  bool get hasFavorites => favorites.isNotEmpty;

  // ✅ Проверка, есть ли заказы
  bool get hasOrders => orders.isNotEmpty;
}
