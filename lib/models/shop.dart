import 'package:cloud_firestore/cloud_firestore.dart';

class Shop {
  final String id;
  final String name;
  final double rating;
  final int reviews;
  final String image;
  final String? discount;
  final bool freeDelivery;
  final String address;
  final String phone;
  final bool isOpen;

  Shop({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviews,
    required this.image,
    this.discount,
    this.freeDelivery = false,
    required this.address,
    required this.phone,
    this.isOpen = true,
  });

  factory Shop.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Shop(
      id: doc.id,
      name: data['name'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      reviews: data['reviews'] ?? 0,
      image: data['image'] ?? '',
      discount: data['discount'],
      freeDelivery: data['freeDelivery'] ?? false,
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      isOpen: data['isOpen'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'rating': rating,
      'reviews': reviews,
      'image': image,
      'discount': discount,
      'freeDelivery': freeDelivery,
      'address': address,
      'phone': phone,
      'isOpen': isOpen,
    };
  }
}