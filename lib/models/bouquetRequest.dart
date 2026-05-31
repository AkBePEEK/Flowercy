import 'package:cloud_firestore/cloud_firestore.dart';

class BouquetRequest {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String bouquetName;
  final String flowers;
  final int price;
  final String? image;
  final String status; // 'pending', 'accepted', 'completed', 'cancelled'
  final DateTime createdAt;

  BouquetRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.bouquetName,
    required this.flowers,
    required this.price,
    this.image,
    this.status = 'pending',
    required this.createdAt,
  });

  factory BouquetRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BouquetRequest(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhone: data['userPhone'] ?? '',
      bouquetName: data['bouquetName'] ?? '',
      flowers: data['flowers'] ?? '',
      price: data['price'] ?? 0,
      image: data['image'],
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'bouquetName': bouquetName,
      'flowers': flowers,
      'price': price,
      'image': image,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
