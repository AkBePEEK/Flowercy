import 'package:cloud_firestore/cloud_firestore.dart';

class SeedFlowerProductsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedFlowerProducts() async {
    final products = [
      // ===================== FLOWERS =====================
      {
        'id': 'lui_buton_pink_garden_bouquet',
        'shopId': 'lui_buton',
        'shopName': 'Lui Buton',
        'name': 'Pink Garden Bouquet',
        'category': 'flowers',
        'section': 'flowers',
        'price': 14500,
        'image': 'assets/flowers/products/pink_garden_bouquet.png',
        'description':
        'A soft mixed bouquet with roses, eustoma and greenery for everyday gifts.',
        'flowers': 'rose, eustoma, greenery',
        'colors': 'pink, white, green',
        'isAvailable': true,
      },
      {
        'id': 'bloom_room_fresh_flower_mix',
        'shopId': 'bloom_room',
        'shopName': 'Bloom Room',
        'name': 'Fresh Flower Mix',
        'category': 'flowers',
        'section': 'flowers',
        'price': 12800,
        'image': 'assets/flowers/products/fresh_flower_mix.png',
        'description':
        'A fresh colorful bouquet with seasonal flowers in a natural style.',
        'flowers': 'tulip, chrysanthemum, daisy',
        'colors': 'pink, yellow, white',
        'isAvailable': true,
      },
      {
        'id': 'flora_astana_daily_bouquet',
        'shopId': 'flora_astana',
        'shopName': 'Flora Astana',
        'name': 'Daily Bouquet',
        'category': 'flowers',
        'section': 'flowers',
        'price': 9900,
        'image': 'assets/flowers/products/daily_bouquet.png',
        'description':
        'A simple and affordable bouquet for warm daily occasions.',
        'flowers': 'carnation, daisy, gypsophila',
        'colors': 'white, pink, yellow',
        'isAvailable': true,
      },

      // ===================== MONOBOUQUETS =====================
      {
        'id': 'rose_avenue_red_rose_monobouquet',
        'shopId': 'rose_avenue',
        'shopName': 'Rose Avenue',
        'name': 'Red Rose Monobouquet',
        'category': 'flowers',
        'section': 'monobouquets',
        'price': 16500,
        'image': 'assets/flowers/products/red_rose_monobouquet.png',
        'description':
        'A classic monobouquet of red roses for romantic occasions.',
        'flowers': 'rose',
        'colors': 'red',
        'isAvailable': true,
      },
      {
        'id': 'tulip_house_pastel_tulips',
        'shopId': 'tulip_house',
        'shopName': 'Tulip House',
        'name': 'Pastel Tulips',
        'category': 'flowers',
        'section': 'monobouquets',
        'price': 9800,
        'image': 'assets/flowers/products/pastel_tulips.png',
        'description':
        'A delicate monobouquet of tulips in pastel spring shades.',
        'flowers': 'tulip',
        'colors': 'pink, white, purple',
        'isAvailable': true,
      },
      {
        'id': 'petal_studio_gypsophila_cloud',
        'shopId': 'petal_studio',
        'shopName': 'Petal Studio',
        'name': 'Gypsophila Cloud',
        'category': 'flowers',
        'section': 'monobouquets',
        'price': 7200,
        'image': 'assets/flowers/products/gypsophila_cloud.png',
        'description':
        'A light and airy monobouquet made of white gypsophila.',
        'flowers': 'gypsophila',
        'colors': 'white',
        'isAvailable': true,
      },

      // ===================== SIGNATURE =====================
      {
        'id': 'lui_buton_signature_love',
        'shopId': 'lui_buton',
        'shopName': 'Lui Buton',
        'name': 'Signature Love',
        'category': 'flowers',
        'section': 'signature',
        'price': 24500,
        'image': 'assets/flowers/products/signature_love.png',
        'description':
        'A signature bouquet with roses, peonies and decorative wrapping.',
        'flowers': 'rose, peony, eustoma',
        'colors': 'pink, cream, white',
        'isAvailable': true,
      },
      {
        'id': 'cvetasto_signature_mood',
        'shopId': 'cvetasto',
        'shopName': 'Cvetasto',
        'name': 'Signature Mood',
        'category': 'flowers',
        'section': 'signature',
        'price': 27500,
        'image': 'assets/flowers/products/signature_mood.png',
        'description':
        'A modern signature bouquet with anemones and garden-style flowers.',
        'flowers': 'anemone, rose, gypsophila',
        'colors': 'white, purple, pink',
        'isAvailable': true,
      },
      {
        'id': 'rose_avenue_premium_signature',
        'shopId': 'rose_avenue',
        'shopName': 'Rose Avenue',
        'name': 'Premium Signature',
        'category': 'flowers',
        'section': 'signature',
        'price': 29500,
        'image': 'assets/flowers/products/premium_signature.png',
        'description':
        'A premium floral arrangement with orchids, roses and hydrangea.',
        'flowers': 'orchid, rose, hydrangea',
        'colors': 'white, pink, purple',
        'isAvailable': true,
      },

      // ===================== BY THE STEM =====================
      {
        'id': 'lui_buton_single_red_rose',
        'shopId': 'lui_buton',
        'shopName': 'Lui Buton',
        'name': 'Single Red Rose',
        'category': 'flowers',
        'section': 'by_the_stem',
        'price': 1200,
        'image': 'assets/flowers/products/single_red_rose.png',
        'description':
        'A single fresh red rose sold by the stem.',
        'flowers': 'rose',
        'colors': 'red',
        'isAvailable': true,
      },
      {
        'id': 'bloom_room_single_tulip',
        'shopId': 'bloom_room',
        'shopName': 'Bloom Room',
        'name': 'Single Tulip',
        'category': 'flowers',
        'section': 'by_the_stem',
        'price': 800,
        'image': 'assets/flowers/products/single_tulip.png',
        'description':
        'A fresh tulip sold by the stem for custom bouquet creation.',
        'flowers': 'tulip',
        'colors': 'pink, yellow, white',
        'isAvailable': true,
      },
      {
        'id': 'petal_studio_single_lily',
        'shopId': 'petal_studio',
        'shopName': 'Petal Studio',
        'name': 'Single White Lily',
        'category': 'flowers',
        'section': 'by_the_stem',
        'price': 1500,
        'image': 'assets/flowers/products/single_white_lily.png',
        'description':
        'A graceful white lily sold by the stem.',
        'flowers': 'lily',
        'colors': 'white',
        'isAvailable': true,
      },

      // ===================== IN A BOX =====================
      {
        'id': 'rose_avenue_pink_rose_box',
        'shopId': 'rose_avenue',
        'shopName': 'Rose Avenue',
        'name': 'Pink Rose Box',
        'category': 'flowers',
        'section': 'in_a_box',
        'price': 28000,
        'image': 'assets/flowers/products/pink_rose_box.png',
        'description':
        'A stylish flower box with pink roses for birthdays and romantic gifts.',
        'flowers': 'rose',
        'colors': 'pink',
        'isAvailable': true,
      },
      {
        'id': 'flora_astana_mix_flower_box',
        'shopId': 'flora_astana',
        'shopName': 'Flora Astana',
        'name': 'Mixed Flower Box',
        'category': 'flowers',
        'section': 'in_a_box',
        'price': 21500,
        'image': 'assets/flowers/products/mixed_flower_box.png',
        'description':
        'A colorful flower box with seasonal flowers and soft decorations.',
        'flowers': 'rose, chrysanthemum, eustoma',
        'colors': 'pink, white, yellow',
        'isAvailable': true,
      },
      {
        'id': 'cvetasto_luxury_box',
        'shopId': 'cvetasto',
        'shopName': 'Cvetasto',
        'name': 'Luxury Flower Box',
        'category': 'flowers',
        'section': 'in_a_box',
        'price': 32000,
        'image': 'assets/flowers/products/luxury_flower_box.png',
        'description':
        'A luxury flower box with premium roses and hydrangea.',
        'flowers': 'rose, hydrangea',
        'colors': 'white, pink, cream',
        'isAvailable': true,
      },

      // ===================== IN A BASKET =====================
      {
        'id': 'bloom_room_spring_basket',
        'shopId': 'bloom_room',
        'shopName': 'Bloom Room',
        'name': 'Spring Basket',
        'category': 'flowers',
        'section': 'in_a_basket',
        'price': 23500,
        'image': 'assets/flowers/products/spring_basket.png',
        'description':
        'A spring flower basket with tulips, daisies and greenery.',
        'flowers': 'tulip, daisy, greenery',
        'colors': 'pink, yellow, white',
        'isAvailable': true,
      },
      {
        'id': 'flora_astana_garden_basket',
        'shopId': 'flora_astana',
        'shopName': 'Flora Astana',
        'name': 'Garden Basket',
        'category': 'flowers',
        'section': 'in_a_basket',
        'price': 25500,
        'image': 'assets/flowers/products/garden_basket.png',
        'description':
        'A garden-style basket with fresh mixed flowers.',
        'flowers': 'rose, carnation, chrysanthemum',
        'colors': 'pink, white, yellow',
        'isAvailable': true,
      },
      {
        'id': 'tulip_house_tulip_basket',
        'shopId': 'tulip_house',
        'shopName': 'Tulip House',
        'name': 'Tulip Basket',
        'category': 'flowers',
        'section': 'in_a_basket',
        'price': 22500,
        'image': 'assets/flowers/products/tulip_basket.png',
        'description':
        'A basket arrangement with fresh tulips in soft colors.',
        'flowers': 'tulip',
        'colors': 'pink, white, purple',
        'isAvailable': true,
      },

      // ===================== BRIDAL =====================
      {
        'id': 'lui_buton_white_bridal_bouquet',
        'shopId': 'lui_buton',
        'shopName': 'Lui Buton',
        'name': 'White Bridal Bouquet',
        'category': 'flowers',
        'section': 'bridal',
        'price': 30000,
        'image': 'assets/flowers/products/white_bridal_bouquet.png',
        'description':
        'An elegant white bridal bouquet with roses and eustoma.',
        'flowers': 'rose, eustoma, gypsophila',
        'colors': 'white, cream',
        'isAvailable': true,
      },
      {
        'id': 'rose_avenue_peony_bridal',
        'shopId': 'rose_avenue',
        'shopName': 'Rose Avenue',
        'name': 'Peony Bridal Bouquet',
        'category': 'flowers',
        'section': 'bridal',
        'price': 36500,
        'image': 'assets/flowers/products/peony_bridal_bouquet.png',
        'description':
        'A romantic bridal bouquet with soft peonies and roses.',
        'flowers': 'peony, rose',
        'colors': 'white, pink, cream',
        'isAvailable': true,
      },
      {
        'id': 'petal_studio_minimal_bridal',
        'shopId': 'petal_studio',
        'shopName': 'Petal Studio',
        'name': 'Minimal Bridal Bouquet',
        'category': 'flowers',
        'section': 'bridal',
        'price': 28500,
        'image': 'assets/flowers/products/minimal_bridal_bouquet.png',
        'description':
        'A minimal bridal bouquet with lilies and soft greenery.',
        'flowers': 'lily, rose, greenery',
        'colors': 'white, green',
        'isAvailable': true,
      },

      // ===================== IN A WOOD BOX =====================
      {
        'id': 'cvetasto_lavender_wood_box',
        'shopId': 'cvetasto',
        'shopName': 'Cvetasto',
        'name': 'Lavender Wood Box',
        'category': 'flowers',
        'section': 'in_a_wood_box',
        'price': 21000,
        'image': 'assets/flowers/products/lavender_wood_box.png',
        'description':
        'A rustic wooden box with lavender and delicate seasonal flowers.',
        'flowers': 'lavender, gypsophila',
        'colors': 'purple, white',
        'isAvailable': true,
      },
      {
        'id': 'flora_astana_rustic_wood_box',
        'shopId': 'flora_astana',
        'shopName': 'Flora Astana',
        'name': 'Rustic Wood Box',
        'category': 'flowers',
        'section': 'in_a_wood_box',
        'price': 24000,
        'image': 'assets/flowers/products/rustic_wood_box.png',
        'description':
        'A rustic wooden box with chrysanthemums, daisies and greenery.',
        'flowers': 'chrysanthemum, daisy, greenery',
        'colors': 'white, yellow, green',
        'isAvailable': true,
      },
      {
        'id': 'bloom_room_soft_wood_box',
        'shopId': 'bloom_room',
        'shopName': 'Bloom Room',
        'name': 'Soft Wood Box',
        'category': 'flowers',
        'section': 'in_a_wood_box',
        'price': 26000,
        'image': 'assets/flowers/products/soft_wood_box.png',
        'description':
        'A soft flower arrangement in a wooden box with pastel colors.',
        'flowers': 'rose, eustoma, gypsophila',
        'colors': 'pink, white, cream',
        'isAvailable': true,
      },
    ];

    for (final product in products) {
      final id = product['id'] as String;

      final data = Map<String, dynamic>.from(product);
      data.remove('id');

      await _firestore.collection('products').doc(id).set({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    print('✅ Flower products seeded');
  }
}