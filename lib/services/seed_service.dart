import 'package:cloud_firestore/cloud_firestore.dart';

class SeedShopsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedFlowerShops() async {
    final shops = [
      {
        'name': 'Lui Buton',
        'category': 'flowers',
        'image': 'assets/flowers/shops/shop1.png',
        'rating': 4.8,
        'reviews': 711,
        'address': 'Астана, пр. Кабанбай Батыра, 46',
        'phone': '+7 701 234 56 78',
        'freeDelivery': true,
        'isOpen': true,
        'deliveryTime': 'Tomorrow from 10:00',
      },
      {
        'name': 'Bloom Room',
        'category': 'flowers',
        'image': 'assets/flowers/shops/shop2.png',
        'rating': 4.7,
        'reviews': 489,
        'address': 'Астана, ул. Сыганак, 16',
        'phone': '+7 702 345 67 89',
        'freeDelivery': true,
        'isOpen': true,
        'deliveryTime': 'Today from 18:00',
      },
      {
        'name': 'Rose Avenue',
        'category': 'flowers',
        'image': 'assets/flowers/shops/shop3.png',
        'rating': 4.9,
        'reviews': 624,
        'address': 'Астана, пр. Туран, 37',
        'phone': '+7 705 456 78 90',
        'freeDelivery': false,
        'isOpen': true,
        'deliveryTime': 'Tomorrow from 09:00',
      },
      {
        'name': 'Flora Astana',
        'category': 'flowers',
        'image': 'assets/flowers/shops/shop4.png',
        'rating': 4.6,
        'reviews': 352,
        'address': 'Астана, ул. Сарайшык, 3',
        'phone': '+7 777 012 34 56',
        'freeDelivery': true,
        'isOpen': true,
        'deliveryTime': 'Today from 20:00',
      },
      {
        'name': 'Petal Studio',
        'category': 'flowers',
        'image': 'assets/flowers/shops/shop5.png',
        'rating': 4.8,
        'reviews': 570,
        'address': 'Астана, ул. Мәңгілік Ел, 29',
        'phone': '+7 708 567 89 01',
        'freeDelivery': false,
        'isOpen': true,
        'deliveryTime': 'Tomorrow from 12:00',
      },
    ];

    for (final shop in shops) {
      await _firestore.collection('shops').add(shop);
    }

    print('✅ Flower shops seeded');
  }
}