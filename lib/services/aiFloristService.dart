import 'dart:convert';
import 'package:http/http.dart' as http;

class AIFloristService {
  final http.Client _client;

  AIFloristService({http.Client? client}) : _client = client ?? http.Client();

  // Если тестируете локально с телефона — используй IP компьютера
  // Если задеплоено — используй реальный URL
  static const String _baseUrl = 'http://192.168.1.176:8000';

  // Рекомендации по параметрам
  Future<List<Map<String, dynamic>>> recommend({
    required String occasion,
    required List<String> colors,
    required List<String> flowersInclude,
    required List<String> flowersAvoid,
    String? size,
    String? mood,
    int? budgetMax,
    String userId = 'guest',
  }) async {
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
        'include_external': false,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['bouquets'] ?? []);
    }
    throw Exception('Failed to get recommendations');
  }

  // Рекомендации по тексту
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

  // Генерация изображения
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
      return data['image_base64']; // base64 строка
    }
    return null;
  }
}