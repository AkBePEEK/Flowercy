import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shop.dart';

class ShopService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'shops';

  Future<List<Shop>> getAllShops() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs.map((doc) => Shop.fromFirestore(doc)).toList();
  }

  Future<Shop?> getShopById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      return Shop.fromFirestore(doc);
    }
    return null;
  }
}