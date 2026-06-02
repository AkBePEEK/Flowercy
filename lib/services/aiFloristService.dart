import 'package:dio/dio.dart';
import 'api/api_client.dart';
import 'api/api_config.dart';
import '../models/api/product_card.dart';

class AIFloristService {
  final ApiClient _apiClient;

  AIFloristService({ApiClient? apiClient}) 
      : _apiClient = apiClient ?? ApiClient(Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 300), // Повышаем до 5 минут для Stable Diffusion
          headers: {'bypass-tunnel-reminder': 'true'},
        )));

  String get baseUrl => ApiConfig.baseUrl;

  // Проверка связи с сервером
  Future<bool> checkConnection() async {
    try {
      print('🌐 Current API BaseURL: $baseUrl');
      print('🔍 Attempting health check to $baseUrl/health...');
      await _apiClient.checkHealth();
      print('✅ Connection successful!');
      return true;
    } catch (e) {
      print('❌ Health check failed for $baseUrl: $e');
      return false;
    }
  }

  // 1. Рекомендации по тексту и параметрам
  Future<List<ProductCard>> recommendFromText(
    String query, {
    String userId = 'guest',
    String? occasion,
    List<String>? colors,
    List<String>? flowersInclude,
    List<String>? flowersAvoid,
    double? budgetMax,
    int topN = 5,
  }) async {
    int retryCount = 0;
    const int maxRetries = 2;

    while (true) {
      try {
        final Map<String, dynamic> body = {
          'query': query,
          'user_id': userId,
          'city': 'Astana',
        };
        
        // Добавляем только ненулевые параметры для совместимости
        if (occasion != null) body['occasion'] = occasion;
        if (colors != null && colors.isNotEmpty) body['colors'] = colors;
        if (flowersInclude != null && flowersInclude.isNotEmpty) body['flowers_include'] = flowersInclude;
        if (flowersAvoid != null && flowersAvoid.isNotEmpty) body['flowers_avoid'] = flowersAvoid;
        if (budgetMax != null) body['budget_max'] = budgetMax;
        if (topN > 0) body['top_n'] = topN;

        final response = await _apiClient.recommendFromText(body);
        
        // Возвращаем изменяемый список, чтобы можно было вставить сгенерированные варианты
        return List<ProductCard>.from(response.results ?? response.bouquets ?? []);
      } catch (e) {
        bool isRetryable = false;
        if (e is DioException) {
          final statusCode = e.response?.statusCode;
          // 503 (Service Unavailable) или 502 (Bad Gateway) часто временные при использовании туннелей
          if (statusCode == 503 || statusCode == 502) {
            isRetryable = true;
          }
        }

        if (isRetryable && retryCount < maxRetries) {
          retryCount++;
          print('🔄 Retry $retryCount/ $maxRetries after error: $e');
          await Future.delayed(Duration(seconds: 2 * retryCount)); // Экспоненциальная задержка
          continue;
        }

        print('❌ Error in recommendFromText: $e');
        if (e is DioException && e.response?.statusCode == 503) {
          throw Exception('AI Service is temporarily unavailable. Please try again in a moment.');
        }
        throw Exception('Failed to get AI recommendations');
      }
    }
  }

  // 2. Генерация изображения
  Future<Map<String, dynamic>> generateImage({
    required List<String> flowers,
    List<String>? colors,
    String? mood,
    String? style,
    String? occasion,
    bool forceGen = true,
  }) async {
    try {
      final response = await _apiClient.generateImage({
        'flowers': flowers,
        'colors': colors ?? [],
        'mood': mood ?? 'happy',
        'style': style ?? 'modern',
        'occasion': occasion ?? 'gift',
        'force_gen': forceGen,
      });
      return {
        'image_base64': response.imageBase64,
        'image_path': response.imagePath,
      };
    } catch (e) {
      print('❌ Error in generateImage: $e');
      throw Exception('Failed to generate image');
    }
  }

  // 3. Получение 3D структуры
  Future<Map<String, dynamic>> get3DStructure(List<String> flowers, {int count = 30}) async {
    try {
      final response = await _apiClient.get3DStructure({
        'flowers': flowers,
        'count': count,
      });
      return {
        'coordinates': response.coordinates,
        'total_count': response.totalCount,
      };
    } catch (e) {
      print('❌ Error in get3DStructure: $e');
      throw Exception('Failed to get 3D structure');
    }
  }

  // 6. Автоматическая сборка букета из выбранных цветов
  Future<List<Map<String, dynamic>>> composeBouquet({
    required List<Map<String, dynamic>> selections,
    double? budget,
    String? style,
    String? occasion,
  }) async {
    try {
      final response = await _apiClient.composeBouquet({
        'selections': selections,
        'budget': budget,
        'style': style,
        'occasion': occasion,
      });
      return response.variations ?? [];
    } catch (e) {
      print('❌ Error in composeBouquet: $e');
      throw Exception('Failed to compose bouquet');
    }
  }

  // 7. Получение списков поддерживаемых параметров
  Future<List<String>> getSupportedOccasions() async => _getList('/bouquets/occasions', 'occasions');
  Future<List<String>> getSupportedFlowers() async => _getList('/bouquets/flowers', 'flowers');
  Future<List<String>> getSupportedMoods() async => _getList('/bouquets/moods', 'moods');
  Future<List<String>> getSupportedColors() async => _getList('/bouquets/colors', 'colors');

  Future<List<String>> _getList(String path, String key) async {
    try {
      // For now, we use raw Dio or add these to ApiClient if they are frequent
      final response = await Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'bypass-tunnel-reminder': 'true'},
      )).get('$baseUrl$path');
      if (response.statusCode == 200) {
        return List<String>.from(response.data[key] ?? []);
      }
    } catch (e) {
      print('❌ Error fetching $path: $e');
    }
    return [];
  }

  // 8. Получение списка цветов для конструктора
  Future<List<Map<String, dynamic>>> getCatalogFlowers() async {
    try {
      final response = await _apiClient.getCatalogFlowers();
      return response.flowers ?? [];
    } catch (e) {
      print('❌ Error in getCatalogFlowers: $e');
      rethrow;
    }
  }
}
