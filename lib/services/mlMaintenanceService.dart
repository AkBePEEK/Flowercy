import 'package:dio/dio.dart';
import 'api/api_config.dart';

class MLMaintenanceService {
  final Dio _dio;
  static String get _baseUrl => ApiConfig.baseUrl;

  MLMaintenanceService({Dio? dio}) 
      : _dio = dio ?? Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
          headers: {'bypass-tunnel-reminder': 'true'},
        ));

  // 1. Получить датасет для обучения (на основе действий пользователей)
  Future<Map<String, dynamic>> getMLDataset() async {
    try {
      final response = await _dio.get('/ml/dataset');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch ML dataset: $e');
    }
  }

  // 2. Запустить переобучение модели
  Future<Map<String, dynamic>> retrainModel() async {
    try {
      final response = await _dio.post('/ml/retrain');
      return response.data;
    } catch (e) {
      throw Exception('Failed to trigger model retraining: $e');
    }
  }

  // 3. Получить логи рекомендаций для анализа
  Future<List<Map<String, dynamic>>> getRecommendationLogs({
    String? outcome,
    String? userId,
    int limit = 100,
  }) async {
    try {
      final queryParams = {
        if (outcome != null) 'outcome': outcome,
        if (userId != null) 'user_id': userId,
        'limit': limit,
      };
      
      final response = await _dio.get('/ml/logs', queryParameters: queryParams);
      return List<Map<String, dynamic>>.from(response.data['logs'] ?? []);
    } catch (e) {
      throw Exception('Failed to fetch recommendation logs: $e');
    }
  }

  // 4. Проверка здоровья сервиса
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
