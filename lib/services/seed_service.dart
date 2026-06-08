import 'package:cloud_firestore/cloud_firestore.dart';

class SeedService {
  final FirebaseFirestore _firestore;

  SeedService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> seedAll() async {
    print('🧹 Clearing existing data...');
    await _clearCollection('shops');
    await _clearCollection('products');
    
    print('🌱 Seeding new data...');
    await _seedShops();
    await _seedProducts();
    print('✅ Seed complete!');
  }

  Future<void> _clearCollection(String collectionName) async {
    final snapshot = await _firestore.collection(collectionName).get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
    print('🗑️ Collection $collectionName cleared');
  }

  Future<void> _seedShops() async {
    final shops = [
      {
        'id': 'lui_buton',
        'name': 'Lui Buton',
        'category': 'flowers',
        'image': 'assets/flowers/shops/shop1.png',
        'rating': 4.8,
        'reviews': 124,
        'discount': '10% off',
        'freeDelivery': true,
        'address': '12 Republic Ave, Astana',
        'phone': '+7 701 123 45 67',
        'isOpen': true,
      },
      {
        'id': 'bloom_room',
        'name': 'Bloom Room',
        'category': 'flowers',
        'image': 'assets/flowers/shops/shop2.png',
        'rating': 4.7,
        'reviews': 489,
        'address': '16 Syganak St, Astana',
        'phone': '+7 702 345 67 89',
        'freeDelivery': true,
        'isOpen': true,
        'deliveryTime': 'Today from 18:00',
      },
      {
        'id': 'rose_avenue',
        'name': 'Rose Avenue',
        'category': 'flowers',
        'image': 'assets/flowers/shops/shop3.png',
        'rating': 4.9,
        'reviews': 624,
        'address': '37 Turan Ave, Astana',
        'phone': '+7 705 456 78 90',
        'freeDelivery': false,
        'isOpen': true,
        'deliveryTime': 'Tomorrow from 09:00',
      },
      {
        'id': 'flora_astana',
        'name': 'Flora Astana',
        'category': 'flowers',
        'image': 'assets/flowers/shops/shop4.png',
        'rating': 4.6,
        'reviews': 89,
        'discount': null,
        'freeDelivery': true,
        'address': '40 Kenesary St, Astana',
        'phone': '+7 702 987 65 43',
        'isOpen': true,
      },
      {
        'id': 'petal_studio',
        'name': 'Petal Studio',
        'category': 'flowers',
        'image': 'assets/flowers/shops/shop5.png',
        'rating': 4.8,
        'reviews': 570,
        'address': '29 Mangilik El St, Astana',
        'phone': '+7 708 567 89 01',
        'discount': '5% off',
        'freeDelivery': false,
        'isOpen': true,
      },
      {
        'id': 'tulip_house',
        'name': 'Tulip House',
        'category': 'flowers',
        'image': 'assets/flowers/shops/shop6.png',
        'rating': 4.7,
        'reviews': 438,
        'address': '12 Dostyk St, Astana',
        'phone': '+7 707 678 90 12',
        'freeDelivery': true,
        'isOpen': true,
        'deliveryTime': 'Today from 19:00',
      },
      {
        'id': 'cvetasto',
        'name': 'Cvetasto',
        'category': 'flowers',
        'image': 'assets/flowers/shops/shop7.png',
        'rating': 4.9,
        'reviews': 512,
        'address': '25 Abay Ave, Astana',
        'phone': '+7 700 789 01 23',
        'freeDelivery': false,
        'isOpen': true,
        'deliveryTime': 'Tomorrow from 11:00',
      },
    ];

    for (final shop in shops) {
      final id = shop['id'] as String;

      final data = Map<String, dynamic>.from(shop);
      data.remove('id');

      await _firestore.collection('shops').doc(id).set({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    print('✅ Shops seeded');
  }

  Future<void> _seedProducts() async {
    // Сначала получаем ID магазинов
    final shopDocs = await _firestore.collection('shops').get();
    if (shopDocs.docs.isEmpty) return;

    final shopIds = shopDocs.docs.map((d) => d.id).toList();

    final products = [
      // Flowers
      {
        'name': 'Красные розы',
        'price': 25000,
        'currency': '₸',
        'description': 'Классический букет из 15 красных роз с зеленью',
        'images': ['https://images.unsplash.com/photo-1548460033-8e17a8b1a0c8?w=400'],
        'shopId': shopIds[0],
        'category': 'flowers',
        'section': 'bouquets',
        'rating': 4.9,
        'reviews': 87,
        'discount': null,
        'freeDelivery': true,
        'inStock': true,
      },
      {
        'name': 'Розовые пионы',
        'price': 38000,
        'currency': '₸',
        'description': 'Нежный букет из пионов, идеален для романтических поводов',
        'images': ['https://images.unsplash.com/photo-1490750967868-88df5691cc81?w=400'],
        'shopId': shopIds[0],
        'category': 'flowers',
        'section': 'bouquets',
        'rating': 4.7,
        'reviews': 52,
        'discount': '10% off',
        'freeDelivery': true,
        'inStock': true,
      },
      {
        'name': 'Тюльпаны микс',
        'price': 18000,
        'currency': '₸',
        'description': 'Яркий весенний букет из 25 тюльпанов разных цветов',
        'images': ['https://images.unsplash.com/photo-1520763185298-1b434c919102?w=400'],
        'shopId': shopIds[1],
        'category': 'flowers',
        'section': 'monobouquets',
        'rating': 4.5,
        'reviews': 34,
        'discount': null,
        'freeDelivery': false,
        'inStock': true,
      },
      {
        'name': 'Белые хризантемы',
        'price': 15000,
        'currency': '₸',
        'description': 'Элегантный букет из белых хризантем',
        'images': ['https://images.unsplash.com/photo-1508610048659-a06b669e3321?w=400'],
        'shopId': shopIds[1],
        'category': 'flowers',
        'section': 'monobouquets',
        'rating': 4.6,
        'reviews': 41,
        'discount': null,
        'freeDelivery': true,
        'inStock': true,
      },
      {
        'name': 'Ранункулюсы',
        'price': 88000,
        'currency': '₸',
        'description': 'Роскошный букет из ранункулюсов — цветов утончённости',
        'images': ['https://images.unsplash.com/photo-1487530811015-780780169229?w=400'],
        'shopId': shopIds[2],
        'category': 'flowers',
        'section': 'signature',
        'rating': 5.0,
        'reviews': 19,
        'discount': null,
        'freeDelivery': true,
        'inStock': true,
      },
      // Sweets
      {
        'name': 'Клубника в шоколаде',
        'price': 12000,
        'currency': '₸',
        'description': 'Свежая клубника в бельгийском шоколаде, 500г',
        'images': ['https://images.unsplash.com/photo-1548848221-0c2e497ed557?w=400'],
        'shopId': shopIds[0],
        'category': 'sweets',
        'section': 'sweets',
        'rating': 4.8,
        'reviews': 63,
        'discount': null,
        'freeDelivery': true,
        'inStock': true,
      },
      {
        'name': 'Макаруны ассорти',
        'price': 8500,
        'currency': '₸',
        'description': 'Набор из 12 свежих макарунов с разными вкусами',
        'images': ['https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=400'],
        'shopId': shopIds[1],
        'category': 'sweets',
        'section': 'sweets',
        'rating': 4.7,
        'reviews': 45,
        'discount': null,
        'freeDelivery': true,
        'inStock': true,
      },
      // Plants
      {
        'name': 'Орхидея фаленопсис',
        'price': 22000,
        'currency': '₸',
        'description': 'Комнатная орхидея в горшке, высота 50 см',
        'images': ['https://images.unsplash.com/photo-1566907225619-5a6a5c9f7b2e?w=400'],
        'shopId': shopIds[2],
        'category': 'plants',
        'section': 'plants',
        'rating': 4.7,
        'reviews': 28,
        'discount': '5% off',
        'freeDelivery': false,
        'inStock': true,
      },
    ];

    for (final product in products) {
      await _firestore.collection('products').add(product);
    }
    print('✅ Products seeded');
  }
}