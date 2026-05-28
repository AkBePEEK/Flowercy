import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flowery_app/services/aiFloristService.dart';

// Manual mock to avoid build_runner dependency for this turn
class MockHttpClient extends Mock implements http.Client {
  @override
  Future<http.Response> post(Uri? url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return super.noSuchMethod(
      Invocation.method(#post, [url], {#headers: headers, #body: body, #encoding: encoding}),
      returnValue: Future.value(http.Response('', 200)),
    ) as Future<http.Response>;
  }
}

void main() {
  late MockHttpClient mockClient;
  late AIFloristService aiFloristService;

  setUp(() {
    mockClient = MockHttpClient();
    aiFloristService = AIFloristService(client: mockClient);
  });

  group('AIFloristService Tests', () {
    test('recommend returns list of bouquets on success', () async {
      final responseBody = {
        'bouquets': [
          {'name': 'Bouquet 1', 'price': 10000},
          {'name': 'Bouquet 2', 'price': 15000},
        ]
      };

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode(responseBody), 200));

      final result = await aiFloristService.recommend(
        occasion: 'Birthday',
        colors: ['Red'],
        flowersInclude: ['Roses'],
        flowersAvoid: [],
      );

      expect(result.length, 2);
      expect(result[0]['name'], 'Bouquet 1');
    });

    test('recommendFromText returns results on success', () async {
      final responseBody = {
        'results': [
          {'name': 'Result 1'},
        ]
      };

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode(responseBody), 200));

      final result = await aiFloristService.recommendFromText('I want roses');

      expect(result.length, 1);
      expect(result[0]['name'], 'Result 1');
    });

    test('generateImage returns base64 string on success', () async {
      final responseBody = {'image_base64': 'base64_data'};

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode(responseBody), 200));

      final result = await aiFloristService.generateImage(
        flowers: ['Roses'],
        colors: ['Red'],
      );

      expect(result, 'base64_data');
    });

    test('throws exception on error status code', () async {
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Error', 500));

      expect(
        () => aiFloristService.recommend(
          occasion: 'Bday',
          colors: [],
          flowersInclude: [],
          flowersAvoid: [],
        ),
        throwsException,
      );
    });
  });
}
