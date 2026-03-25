import 'package:flutter/material.dart';

class SearchResultsScreen extends StatelessWidget {
  final String query;

  const SearchResultsScreen({
    super.key,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFB07183), width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  query,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Results count
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '167 results found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900],
                      ),
                    ),
                  ),

                  // Shops and products
                  _buildShopSection(
                    context,
                    name: 'Lui buton',
                    rating: 4.7,
                    reviews: 676,
                    image: 'assets/shops/lui_buton.png',
                    discount: '30% off select items',
                    products: [
                      {'price': '32 000₸', 'name': '51 red roses', 'image': 'assets/flowers/products/red_roses.png'},
                      {'price': '57 500₸', 'name': '101 pink roses', 'image': 'assets/flowers/products/pink_roses.png'},
                      {'price': '150 990₸', 'name': '222 white ros...', 'image': 'assets/flowers/products/white_roses.png'},
                    ],
                  ),

                  _buildShopSection(
                    context,
                    name: 'Rosalie',
                    rating: 4.2,
                    reviews: 228,
                    image: 'assets/shops/rosalie.png',
                    discount: '40% off select items',
                    freeDelivery: true,
                    products: [
                      {'price': '32 000₸', 'name': '51 red roses', 'image': 'assets/flowers/products/red_roses.png'},
                      {'price': '57 500₸', 'name': '101 pink roses', 'image': 'assets/flowers/products/pink_roses.png'},
                      {'price': '150 990₸', 'name': '222 white ros...', 'image': 'assets/flowers/products/white_roses.png'},
                    ],
                  ),

                  _buildShopSection(
                    context,
                    name: 'Cvetasto',
                    rating: 4.9,
                    reviews: 931,
                    image: 'assets/shops/cvetasto.png',
                    discount: '25% off select items',
                    freeDelivery: true,
                    products: [
                      {'price': '32 000₸', 'name': '51 red roses', 'image': 'assets/flowers/products/red_roses.png'},
                      {'price': '57 500₸', 'name': '101 pink roses', 'image': 'assets/flowers/products/pink_roses.png'},
                      {'price': '150 990₸', 'name': '222 white ros...', 'image': 'assets/flowers/products/white_roses.png'},
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Shop Section with Products
  Widget _buildShopSection(
      BuildContext context, {
        required String name,
        required double rating,
        required int reviews,
        required String image,
        String? discount,
        bool freeDelivery = false,
        required List<Map<String, String>> products,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shop Info
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.local_florist, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$rating/5 rating',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 8),
                        const Icon(Icons.chat_bubble_outline, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '$reviews review',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    if (discount != null || freeDelivery) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (discount != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                discount,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          if (freeDelivery)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.pink[50],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Free delivery',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.pink[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Products Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 280,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.7,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(product);
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // Product Card
  Widget _buildProductCard(Map<String, String> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.asset(
                  product['image']!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.local_florist, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
          ),
          // Price and Name
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product['price']!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    product['name']!,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}