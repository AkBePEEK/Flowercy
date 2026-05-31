import 'package:dio/dio.dart';
import 'api/api_client.dart';
import '../models/api/user_preferences.dart';
import '../models/api/product_card.dart';

class AIFloristService {
  final ApiClient _apiClient;

  AIFloristService({ApiClient? apiClient}) 
      : _apiClient = apiClient ?? ApiClient(Dio());

  String get baseUrl => 'http://192.168.1.180:8000';

  // Проверка связи с сервером
  Future<bool> checkConnection() async {
    try {
      print('🔍 Checking connection...');
      // We can use a simple get list or health check if added to ApiClient
      await getSupportedFlowers();
      return true;
    } catch (e) {
      print('❌ Health check failed: $e');
      return false;
    }
  }

  // 1. Рекомендации по параметрам
  Future<List<ProductCard>> recommend({
    required String occasion,
    required List<String> colors,
    required List<String> flowersInclude,
    required List<String> flowersAvoid,
    String? size,
    String? mood,
    int? budgetMax,
    String userId = 'guest',
    bool includeExternal = false,
  }) async {
    try {
      final preferences = UserPreferences(
        userId: userId,
        occasion: occasion,
        colors: colors,
        mood: mood,
        size: size ?? 'M',
        flowersInclude: flowersInclude,
        flowersAvoid: flowersAvoid,
        budgetMax: budgetMax?.toDouble() ?? 50000.0,
        topN: 5,
        includeExternal: includeExternal,
      );

      final response = await _apiClient.getRecommendations(preferences);
      return response.results ?? response.bouquets ?? [];
    } catch (e) {
      print('❌ Network error in recommend: $e');
      rethrow;
    }
  }


  // 2. Рекомендации по тексту
  Future<List<ProductCard>> recommendFromText(String query, {String userId = 'guest'}) async {
    try {
      final response = await _apiClient.recommendFromText({
        'query': query,
        'top_n': 3,
        'user_id': userId,
        'city': 'Astana',
      });
      
      return response.results ?? response.bouquets ?? [];
    } catch (e) {
      print('❌ Error in recommendFromText: $e');
      throw Exception('Failed to get AI recommendations');
    }
  }

  // 3. Генерация изображения
  Future<String?> generateImage({
    required List<String> flowers,
    required List<String> colors,
    String? mood,
    String? occasion,
  }) async {
    try {
      final response = await _apiClient.generateImage({
        'flowers': flowers,
        'colors': colors,
        'mood': mood ?? '',
        'occasion': occasion ?? '',
      });
      return response.imageBase64;
    } catch (e) {
      print('❌ Error in generateImage: $e');
      return null;
    }
  }

  // 4. Парсинг текстового описания в структуру
  Future<UserPreferences> nlpParse(String text) async {
    try {
      return await _apiClient.nlpParse({'text': text});
    } catch (e) {
      print('❌ Error in nlpParse: $e');
      throw Exception('Failed to parse description');
    }
  }

  // 5. Получение 3D структуры букета
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
      final response = await Dio().get('http://192.168.1.180:8000$path');
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
      return [];
    }
  }
}
