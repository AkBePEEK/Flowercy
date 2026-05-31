import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flowery_app/services/aiFloristService.dart';
import 'package:flowery_app/services/api/api_client.dart';
import 'package:flowery_app/models/api/product_card.dart';
import 'package:flowery_app/models/api/api_responses.dart';
import 'package:mockito/annotations.dart';

// Generate mocks
@GenerateMocks([ApiClient])
import 'ai__florist_service_test.mocks.dart';

void main() {
  late MockApiClient mockApiClient;
  late AIFloristService aiFloristService;

  setUp(() {
    mockApiClient = MockApiClient();
    aiFloristService = AIFloristService(apiClient: mockApiClient);
  });

  group('AIFloristService Tests', () {
    test('recommend returns list of bouquets on success', () async {
      final bouquets = [
        ProductCard(id: '1', name: 'Bouquet 1', price: 10000, imageUrl: '', provider: 'Internal', storeId: '1', inStock: true),
        ProductCard(id: '2', name: 'Bouquet 2', price: 15000, imageUrl: '', provider: 'Internal', storeId: '1', inStock: true),
      ];

      when(mockApiClient.getRecommendations(any)).thenAnswer((_) async => RecommendationResponse(results: bouquets));

      final result = await aiFloristService.recommend(
        occasion: 'Birthday',
        colors: ['Red'],
        flowersInclude: ['Roses'],
        flowersAvoid: [],
      );

      expect(result.length, 2);
      expect(result[0].name, 'Bouquet 1');
    });

    test('recommendFromText returns results on success', () async {
      final response = RecommendationResponse(results: [
        ProductCard(id: '1', name: 'Result 1', price: 10000, imageUrl: '', provider: 'Internal', storeId: '1', inStock: true),
      ]);

      when(mockApiClient.recommendFromText(any)).thenAnswer((_) async => response);

      final result = await aiFloristService.recommendFromText('I want roses');

      expect(result.length, 1);
      expect(result[0].name, 'Result 1');
    });

    test('generateImage returns base64 string on success', () async {
      final response = ImageGenerationResponse(imageBase64: 'base64_data');

      when(mockApiClient.generateImage(any)).thenAnswer((_) async => response);

      final result = await aiFloristService.generateImage(
        flowers: ['Roses'],
        colors: ['Red'],
      );

      expect(result, 'base64_data');
    });
  });
}
