import 'package:cloud_firestore/cloud_firestore.dart';

import 'address.dart';
import 'cartItem.dart';

class User {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final List<String> favorites;
  final List<CartItem> cart;
  final List<String> orders;
  final String? avatarUrl;

  // ✅ Новые поля для адресов
  final List<Address> addresses;
  final String? defaultAddressId;

  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  User({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.favorites = const [],
    this.cart = const [],
    this.orders = const [],
    this.avatarUrl,
    this.addresses = const [],
    this.defaultAddressId,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'],
      phone: data['phone'],
      favorites: List<String>.from(data['favorites'] ?? []),
      cart: (data['cart'] as List?)?.map((item) => CartItem.fromMap(item as Map<String, dynamic>)).toList() ?? [],
      orders: List<String>.from(data['orders'] ?? []),
      avatarUrl: data['avatarUrl'],

      // ✅ Адреса из Firestore
      addresses: (data['addresses'] as List?)
          ?.map((addr) => Address.fromMap(addr as Map<String, dynamic>))
          .toList() ?? [],
      defaultAddressId: data['defaultAddressId'],

      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'favorites': favorites,
      'cart': cart.map((dynamic item) => item?.toMap()).toList(),
      'orders': orders,
      'avatarUrl': avatarUrl,

      // ✅ Адреса в Firestore
      'addresses': addresses.map((dynamic addr) => addr?.toMap()).toList(),
      'defaultAddressId': defaultAddressId,

      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isActive': isActive,
    };
  }

// ... остальные геттеры ...
}