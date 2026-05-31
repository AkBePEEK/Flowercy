import 'dart:convert';
import 'package:http/http.dart' as http;

class AIFloristService {
  final http.Client _client;

  AIFloristService({http.Client? client}) : _client = client ?? http.Client();

  // Автоматический выбор хоста
  String get _baseUrl {
    // 192.168.1.176 — твой локальный IP, самый надежный способ для тестов
    return 'http://192.168.1.176:8000';
  }

  // Проверка связи с сервером
  Future<bool> checkConnection() async {
    try {
      print('🔍 Checking connection to $_baseUrl/health...');
      final response = await _client.get(Uri.parse('$_baseUrl/health')).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Health check failed: $e');
      return false;
    }
  }

  // 1. Рекомендации по параметрам
  Future<List<Map<String, dynamic>>> recommend({
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
      final response = await _client.post(
        Uri.parse('$_baseUrl/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'occasion': occasion,
          'colors': colors,
          'mood': mood ?? '',
          'size': size ?? 'M',
          'flowers_include': flowersInclude,
          'flowers_avoid': flowersAvoid,
          'budget_max': budgetMax ?? 50000,
          'top_n': 5,
          'include_external': includeExternal,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['bouquets'] ?? []);
      } else {
        print('❌ ML Server error: ${response.statusCode} - ${response.body}');
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Network error in recommend: $e');
      rethrow;
    }
  }


  // 2. Рекомендации по тексту (уже было)
  Future<List<Map<String, dynamic>>> recommendFromText(String query) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/ai/recommend-from-text'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'query': query,
        'top_n': 3,
        'city': 'Astana',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['results'] ?? []);
    }
    throw Exception('Failed to get AI recommendations');
  }

  // 3. Генерация изображения (уже было)
  Future<String?> generateImage({
    required List<String> flowers,
    required List<String> colors,
    String? mood,
    String? occasion,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/generate-image'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'flowers': flowers,
        'colors': colors,
        'mood': mood ?? '',
        'occasion': occasion ?? '',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['image_base64'];
    }
    return null;
  }

  // 4. НОВОЕ: Парсинг текстового описания в структуру
  Future<Map<String, dynamic>> nlpParse(String text) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/nlp/parse'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to parse description');
  }

  // 5. НОВОЕ: Получение 3D структуры букета
  Future<Map<String, dynamic>> get3DStructure(List<String> flowers, {int count = 30}) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/bouquets/3d-structure'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'flowers': flowers,
        'count': count,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to get 3D structure');
  }

  // 6. НОВОЕ: Автоматическая сборка букета из выбранных цветов
  Future<List<Map<String, dynamic>>> composeBouquet({
    required List<Map<String, dynamic>> selections,
    double? budget,
    String? style,
    String? occasion,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/bouquets/compose'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'selections': selections,
        'budget': budget,
        'style': style,
        'occasion': occasion,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['variations'] ?? []);
    }
    throw Exception('Failed to compose bouquet');
  }

  // 7. НОВОЕ: Получение списков поддерживаемых параметров
  Future<List<String>> getSupportedOccasions() async => _getList('/bouquets/occasions');
  Future<List<String>> getSupportedFlowers() async => _getList('/bouquets/flowers');
  Future<List<String>> getSupportedMoods() async => _getList('/bouquets/moods');
  Future<List<String>> getSupportedColors() async => _getList('/bouquets/colors');

  Future<List<String>> _getList(String path) async {
    final response = await _client.get(Uri.parse('$_baseUrl$path'));
    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    }
    return [];
  }

  // 8. НОВОЕ: Получение списка цветов для конструктора
  Future<List<Map<String, dynamic>>> getCatalogFlowers() async {
    final response = await _client.get(Uri.parse('$_baseUrl/catalog/flowers'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['flowers'] ?? []);
    }
    return [];
  }
}
