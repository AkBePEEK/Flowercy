import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:flowery_app/services/aiFloristService.dart';
import 'package:flowery_app/services/api/api_client.dart';
import 'package:flowery_app/models/api/product_card.dart';
import 'package:flowery_app/models/api/api_responses.dart';
import 'package:mockito/annotations.dart';

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
    test('checkConnection returns true on success', () async {
      when(mockApiClient.checkHealth()).thenAnswer((_) async => Future.value());
      
      final result = await aiFloristService.checkConnection();
      
      expect(result, true);
      verify(mockApiClient.checkHealth()).called(1);
    });

    test('checkConnection returns false on error', () async {
      when(mockApiClient.checkHealth()).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/health'),
        response: Response(
          requestOptions: RequestOptions(path: '/health'),
          statusCode: 503,
        ),
      ));
      
      final result = await aiFloristService.checkConnection();
      
      expect(result, false);
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

    test('generateImage returns map with base64 and path', () async {
      final response = ImageGenerationResponse(
        imageBase64: 'base64_data',
        imagePath: 'outputs/image.png',
      );

      when(mockApiClient.generateImage(any)).thenAnswer((_) async => response);

      final result = await aiFloristService.generateImage(
        flowers: ['Roses'],
      );

      expect(result['image_base64'], 'base64_data');
      expect(result['image_path'], 'outputs/image.png');
    });

    test('getCatalogFlowers rethrows exception on error', () async {
      when(mockApiClient.getCatalogFlowers()).thenThrow(Exception('API Error'));
      
      expect(() => aiFloristService.getCatalogFlowers(), throwsException);
    });
  });
}
