import 'package:cloud_firestore/cloud_firestore.dart';

class SeedCatalogFlowersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedCatalogFlowers() async {
    final flowers = [
      {
        'id': 'rose',
        'name': 'Rose',
        'price_per_stem': 1200,
        'colors': 'red, white, pink, yellow, cream',
        'description':
        'A classic flower used in romantic bouquets, wedding arrangements and elegant gift compositions.',
        'photo': 'assets/flowers/catalog/rose.png',
      },
      {
        'id': 'tulip',
        'name': 'Tulip',
        'price_per_stem': 800,
        'colors': 'red, yellow, white, pink, purple',
        'description':
        'A spring flower with a simple and elegant shape, often used in fresh seasonal bouquets.',
        'photo': 'assets/flowers/catalog/tulip.png',
      },
      {
        'id': 'peony',
        'name': 'Peony',
        'price_per_stem': 1800,
        'colors': 'pink, white, red, coral',
        'description':
        'A large and delicate flower with a soft texture, popular for wedding and luxury bouquets.',
        'photo': 'assets/flowers/catalog/peony.png',
      },
      {
        'id': 'lily',
        'name': 'Lily',
        'price_per_stem': 1500,
        'colors': 'white, pink, orange, yellow',
        'description':
        'A graceful flower with large petals and a strong decorative appearance, suitable for elegant bouquets.',
        'photo': 'assets/flowers/catalog/lily.png',
      },
      {
        'id': 'orchid',
        'name': 'Orchid',
        'price_per_stem': 2500,
        'colors': 'white, purple, pink, yellow',
        'description':
        'An exotic and long-lasting flower often used in premium floral arrangements.',
        'photo': 'assets/flowers/catalog/orchid.png',
      },
      {
        'id': 'chrysanthemum',
        'name': 'Chrysanthemum',
        'price_per_stem': 700,
        'colors': 'white, yellow, pink, purple, green',
        'description':
        'A durable flower with many petals, commonly used in bright and long-lasting bouquets.',
        'photo': 'assets/flowers/catalog/chrysanthemum.png',
      },
      {
        'id': 'carnation',
        'name': 'Carnation',
        'price_per_stem': 600,
        'colors': 'red, pink, white, purple, yellow',
        'description':
        'A soft and affordable flower that stays fresh for a long time and is used in many bouquet styles.',
        'photo': 'assets/flowers/catalog/carnation.png',
      },
      {
        'id': 'hydrangea',
        'name': 'Hydrangea',
        'price_per_stem': 2200,
        'colors': 'blue, pink, white, purple, green',
        'description':
        'A voluminous flower with many small blossoms, often used to make bouquets look fuller.',
        'photo': 'assets/flowers/catalog/hydrangea.png',
      },
      {
        'id': 'eustoma',
        'name': 'Eustoma',
        'price_per_stem': 1300,
        'colors': 'white, pink, purple, cream',
        'description':
        'A delicate flower with a soft romantic look, often combined with roses and peonies.',
        'photo': 'assets/flowers/catalog/eustoma.png',
      },
      {
        'id': 'gerbera',
        'name': 'Gerbera',
        'price_per_stem': 900,
        'colors': 'red, yellow, orange, pink, white',
        'description':
        'A bright flower with a cheerful appearance, suitable for colorful and simple bouquets.',
        'photo': 'assets/flowers/catalog/gerbera.png',
      },
      {
        'id': 'alstroemeria',
        'name': 'Alstroemeria',
        'price_per_stem': 750,
        'colors': 'pink, yellow, white, orange, purple',
        'description':
        'A long-lasting flower with small patterned petals, often used as a filler in mixed bouquets.',
        'photo': 'assets/flowers/catalog/alstroemeria.png',
      },
      {
        'id': 'sunflower',
        'name': 'Sunflower',
        'price_per_stem': 1400,
        'colors': 'yellow',
        'description':
        'A large bright flower associated with warmth and positivity, suitable for summer-style bouquets.',
        'photo': 'assets/flowers/catalog/sunflower.png',
      },
      {
        'id': 'iris',
        'name': 'Iris',
        'price_per_stem': 1000,
        'colors': 'purple, blue, white, yellow',
        'description':
        'An elegant flower with a unique shape, often used to add contrast to bouquets.',
        'photo': 'assets/flowers/catalog/iris.png',
      },
      {
        'id': 'daisy',
        'name': 'Daisy',
        'price_per_stem': 500,
        'colors': 'white, yellow',
        'description':
        'A simple and fresh-looking flower, often used in natural and casual bouquet compositions.',
        'photo': 'assets/flowers/catalog/daisy.png',
      },
      {
        'id': 'lavender',
        'name': 'Lavender',
        'price_per_stem': 650,
        'colors': 'purple',
        'description':
        'A fragrant flower used in minimal, rustic and decorative floral arrangements.',
        'photo': 'assets/flowers/catalog/lavender.png',
      },
      {
        'id': 'ranunculus',
        'name': 'Ranunculus',
        'price_per_stem': 1600,
        'colors': 'white, pink, red, orange, yellow',
        'description':
        'A delicate layered flower with a romantic appearance, often used in wedding and premium bouquets.',
        'photo': 'assets/flowers/catalog/ranunculus.png',
      },
      {
        'id': 'freesia',
        'name': 'Freesia',
        'price_per_stem': 850,
        'colors': 'white, yellow, pink, purple, red',
        'description':
        'A small fragrant flower with elegant blossoms, suitable for soft and fresh bouquet compositions.',
        'photo': 'assets/flowers/catalog/freesia.png',
      },
      {
        'id': 'gypsophila',
        'name': 'Gypsophila',
        'price_per_stem': 500,
        'colors': 'white, pink',
        'description':
        'A light filler flower with many small blossoms, often used to add airiness and volume to bouquets.',
        'photo': 'assets/flowers/catalog/gypsophila.png',
      },
      {
        'id': 'anemone',
        'name': 'Anemone',
        'price_per_stem': 1700,
        'colors': 'white, red, purple, pink, blue',
        'description':
        'A stylish flower with a dark center and soft petals, often used in modern bouquet arrangements.',
        'photo': 'assets/flowers/catalog/anemone.png',
      },
      {
        'id': 'delphinium',
        'name': 'Delphinium',
        'price_per_stem': 1500,
        'colors': 'blue, purple, white, pink',
        'description':
        'A tall decorative flower used to add height, color and structure to floral compositions.',
        'photo': 'assets/flowers/catalog/delphinium.png',
      },
    ];

    for (final flower in flowers) {
      final id = flower['id'] as String;

      final data = Map<String, dynamic>.from(flower);
      data.remove('id');

      await _firestore.collection('catalog_flowers').doc(id).set({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    print('✅ Catalog flowers seeded');
  }
}