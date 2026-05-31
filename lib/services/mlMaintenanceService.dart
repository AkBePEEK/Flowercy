import 'dart:convert';
import 'package:http/http.dart' as http;

class MLMaintenanceService {
  final http.Client _client;
  static const String _baseUrl = 'http://192.168.1.180:8000';

  MLMaintenanceService({http.Client? client}) : _client = client ?? http.Client();

  // 1. Получить датасет для обучения (на основе действий пользователей)
  Future<Map<String, dynamic>> getMLDataset() async {
    final response = await _client.get(Uri.parse('$_baseUrl/ml/dataset'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to fetch ML dataset');
  }

  // 2. Запустить переобучение модели
  Future<Map<String, dynamic>> retrainModel() async {
    final response = await _client.post(Uri.parse('$_baseUrl/ml/retrain'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to trigger model retraining');
  }

  // 3. Получить логи рекомендаций для анализа
  Future<List<Map<String, dynamic>>> getRecommendationLogs({
    String? outcome,
    String? userId,
    int limit = 100,
  }) async {
    final queryParams = {
      if (outcome != null) 'outcome': outcome,
      if (userId != null) 'user_id': userId,
      'limit': limit.toString(),
    };
    
    final uri = Uri.parse('$_baseUrl/ml/logs').replace(queryParameters: queryParams);
    final response = await _client.get(uri);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['logs'] ?? []);
    }
    throw Exception('Failed to fetch recommendation logs');
  }

  // 4. Проверка здоровья сервиса
  Future<bool> checkHealth() async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/health'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
