import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final int price;
  final String currency;
  final String description;
  final List<String> images;
  final String shopId;
  final String category;
  final double rating;
  final int reviews;
  final String? discount;
  final bool freeDelivery;
  final bool inStock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.currency = '₸',
    required this.description,
    required this.images,
    required this.shopId,
    required this.category,
    required this.rating,
    required this.reviews,
    this.discount,
    this.freeDelivery = false,
    this.inStock = true,
  });

  // ✅ Из Firestore в объект
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      currency: data['currency'] ?? '₸',
      description: data['description'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      shopId: data['shopId'] ?? '',
      category: data['category'] ?? 'flowers',
      rating: (data['rating'] ?? 0).toDouble(),
      reviews: data['reviews'] ?? 0,
      discount: data['discount'],
      freeDelivery: data['freeDelivery'] ?? false,
      inStock: data['inStock'] ?? true,
    );
  }

  // ✅ Из объекта в Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'currency': currency,
      'description': description,
      'images': images,
      'shopId': shopId,
      'category': category,
      'rating': rating,
      'reviews': reviews,
      'discount': discount,
      'freeDelivery': freeDelivery,
      'inStock': inStock,
    };
  }

  String get formattedPrice => '$price $currency';
}