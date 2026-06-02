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
        'name': 'Цветочный рай',
        'rating': 4.8,
        'reviews': 124,
        'image': 'https://images.unsplash.com/photo-1487530811015-780780169229?w=400',
        'discount': '10% off',
        'freeDelivery': true,
        'address': 'пр. Республики, 12, Астана',
        'phone': '+7 701 123 45 67',
        'isOpen': true,
      },
      {
        'name': 'Bloomy',
        'rating': 4.6,
        'reviews': 89,
        'image': 'https://images.unsplash.com/photo-1490750967868-88df5691cc81?w=400',
        'discount': null,
        'freeDelivery': true,
        'address': 'ул. Кенесары, 40, Астана',
        'phone': '+7 702 987 65 43',
        'isOpen': true,
      },
      {
        'name': 'Rose Garden',
        'rating': 4.9,
        'reviews': 210,
        'image': 'https://images.unsplash.com/photo-1519378058457-4c29a0a2efac?w=400',
        'discount': '5% off',
        'freeDelivery': false,
        'address': 'пр. Победы, 78, Астана',
        'phone': '+7 705 111 22 33',
        'isOpen': true,
      },
    ];

    for (final shop in shops) {
      await _firestore.collection('shops').add(shop);
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