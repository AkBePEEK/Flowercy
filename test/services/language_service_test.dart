import 'package:flutter_test/flutter_test.dart';
import 'package:flowery_app/services/language_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flowery_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LanguageService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      appLanguageNotifier.value = 'en';
    });

    test('Translations are correctly retrieved for English', () {
      final translations = AppTranslations('en');
      expect(translations('home'), 'Home');
      expect(translations('cart'), 'Cart');
    });

    test('Translations are correctly retrieved for Russian', () {
      final translations = AppTranslations('ru');
      expect(translations('home'), 'Главная');
      expect(translations('cart'), 'Корзина');
    });

    test('Language switching works and updates appLanguageNotifier', () async {
      await setAppLanguage('ru');
      expect(appLanguageNotifier.value, 'ru');
      expect(t('home'), 'Главная');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_language'), 'ru');
    });

    test('Fallbacks to English if key is missing in another language', () {
      // Assuming 'app_name' might be the same or we can test with a fake key if we had a way to inject it.
      // But based on current structure:
      final translations = AppTranslations('kk');
      expect(translations('app_name'), 'Flowery App');
    });

    test('Returns key itself if translation is missing everywhere', () {
      final translations = AppTranslations('en');
      expect(translations('non_existent_key'), 'non_existent_key');
    });
  });
}
