import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

// ─────────────────────────────────────────────────────────────
// ПЕРЕВОДЫ — все строки приложения
// ─────────────────────────────────────────────────────────────
class AppTranslations {
  final String languageCode;
  const AppTranslations(this.languageCode);

  // ── Навигация ─────────────────────────────────────────────
  String get home        => _t('Home',       'Главная',    'Басты');
  String get search      => _t('Search',     'Поиск',      'Іздеу');
  String get favorites   => _t('Favorites',  'Избранное',  'Таңдаулы');
  String get cart        => _t('Cart',       'Корзина',    'Себет');
  String get profile     => _t('Profile',    'Профиль',    'Профиль');

  // ── Профиль ───────────────────────────────────────────────
  String get myOrders    => _t('My Orders',      'Мои заказы',       'Менің тапсырыстарым');
  String get savedAddresses => _t('Saved Addresses', 'Адреса',        'Мекенжайлар');
  String get language    => _t('Language',      'Язык',             'Тіл');
  String get logout      => _t('Log out',       'Выйти',            'Шығу');
  String get deleteAccount => _t('Delete Account', 'Удалить аккаунт', 'Аккаунтты жою');
  String get settings    => _t('Settings',      'Настройки',        'Параметрлер');

  // ── Корзина ───────────────────────────────────────────────
  String get cartEmpty       => _t('Your cart is empty',      'Корзина пуста',           'Себет бос');
  String get browseFlowers   => _t('Browse flowers',          'Посмотреть цветы',         'Гүлдерді қарау');
  String get addSomeFlowers  => _t('Add some flowers to get started', 'Добавьте цветы для начала', 'Бастау үшін гүл қосыңыз');
  String get goToCheckout    => _t('Go to checkout',          'Оформить заказ',           'Тапсырысты рәсімдеу');
  String get total           => _t('Total',                   'Итого',                    'Барлығы');
  String get delivery        => _t('Delivery',                'Доставка',                 'Жеткізу');
  String get price           => _t('Price',                   'Цена',                     'Баға');
  String get clearCart       => _t('Clear cart?',             'Очистить корзину?',         'Себетті тазалау?');
  String get removeAllItems  => _t('Remove all items from your cart?', 'Удалить все товары из корзины?', 'Барлық тауарларды себеттен жою?');
  String get commentSeller   => _t('Comment for the seller', 'Комментарий продавцу',      'Сатушыға пікір');
  String get promocode       => _t('Promocode',               'Промокод',                 'Промокод');
  String get usePromocode    => _t('Use',                     'Применить',                'Қолдану');
  String get youHavePromocode=> _t('You have one promocode',  'У вас есть промокод',       'Сізде промокод бар');

  // ── Заказы ────────────────────────────────────────────────
  String get orderDetails    => _t('Order details',  'Детали заказа',    'Тапсырыс мәліметтері');
  String get recipient       => _t('Recipient',      'Получатель',       'Алушы');
  String get address         => _t('Address',        'Адрес',            'Мекенжай');
  String get payment         => _t('Payment',        'Оплата',           'Төлем');
  String get payOrder        => _t('Pay for the order', 'Оплатить заказ', 'Тапсырысты төлеу');
  String get myOrdersTitle   => _t('My Orders',      'Мои заказы',       'Тапсырыстарым');
  String get activeOrders    => _t('Active',         'Активные',         'Белсенді');
  String get historyOrders   => _t('History',        'История',          'Тарих');
  String get noActiveOrders  => _t('No active orders', 'Нет активных заказов', 'Белсенді тапсырыс жоқ');
  String get repeatOrder     => _t('Repeat order',   'Повторить заказ',  'Тапсырысты қайталау');
  String get orderComposition=> _t('Order composition', 'Состав заказа', 'Тапсырыс құрамы');
  String get courierComment  => _t('Comment for the courier', 'Комментарий курьеру', 'Курьерге пікір');
  String get addComment      => _t('Add',            'Добавить',         'Қосу');

  // ── Адреса ───────────────────────────────────────────────
  String get savedAddressesTitle => _t('Saved addresses', 'Сохранённые адреса', 'Сақталған мекенжайлар');
  String get addAddress          => _t('Add address',     'Добавить адрес',      'Мекенжай қосу');
  String get noAddresses         => _t('No saved addresses yet', 'Нет сохранённых адресов', 'Сақталған мекенжай жоқ');
  String get defaultAddress      => _t('Default',         'По умолчанию',        'Әдепкі');
  String get street              => _t('Street',          'Улица',               'Көше');
  String get apartment           => _t('Apt./Office',     'Кв./Офис',            'Пәтер/Кеңсе');
  String get city                => _t('City',            'Город',               'Қала');
  String get deleteAddress       => _t('Delete address?', 'Удалить адрес?',      'Мекенжайды жою?');

  // ── Авторизация ───────────────────────────────────────────
  String get signIn          => _t('Sign In',         'Войти',            'Кіру');
  String get signUp          => _t('Sign Up',         'Регистрация',      'Тіркелу');
  String get email           => _t('Email',           'Email',            'Email');
  String get password        => _t('Password',        'Пароль',           'Құпия сөз');
  String get forgotPassword  => _t('Forgot password?','Забыли пароль?',   'Құпия сөзді ұмыттыңыз ба?');
  String get noAccount       => _t('Don\'t have an account?', 'Нет аккаунта?', 'Аккаунт жоқ па?');
  String get haveAccount     => _t('Already have an account?', 'Уже есть аккаунт?', 'Аккаунт бар ма?');

  // ── Общие ─────────────────────────────────────────────────
  String get save            => _t('Save',    'Сохранить', 'Сақтау');
  String get cancel          => _t('Cancel',  'Отмена',    'Болдырмау');
  String get delete          => _t('Delete',  'Удалить',   'Жою');
  String get edit            => _t('Edit',    'Редактировать', 'Өңдеу');
  String get retry           => _t('Retry',   'Повторить', 'Қайталау');
  String get yes             => _t('Yes',     'Да',        'Иә');
  String get no              => _t('No',      'Нет',       'Жоқ');
  String get loading         => _t('Loading...', 'Загрузка...', 'Жүктелуде...');
  String get error           => _t('Error',   'Ошибка',    'Қате');
  String get success         => _t('Success', 'Успешно',   'Сәтті');
  String get back            => _t('Back',    'Назад',     'Артқа');
  String get selectLanguage  => _t('Select Language', 'Выберите язык', 'Тілді таңдаңыз');
  String get notFound        => _t('Page not found', 'Страница не найдена', 'Бет табылмады');
  String get goHome          => _t('Go to main', 'На главную', 'Басты бетке');

  // ── Поиск ────────────────────────────────────────────────
  String get searchHint      => _t('Search flowers, shops...', 'Поиск цветов, магазинов...', 'Гүл, дүкен іздеу...');
  String get searchResults   => _t('Search results', 'Результаты поиска', 'Іздеу нәтижелері');
  String get noResults       => _t('Nothing found', 'Ничего не найдено', 'Ештеңе табылмады');

  // ── Внутренний хелпер ─────────────────────────────────────
  String _t(String en, String ru, String kz) {
    switch (languageCode) {
      case 'ru': return ru;
      case 'kk': return kz;
      default:   return en;
    }
  }
}

// ✅ Глобальная функция смены языка — вызывай отовсюду
Future<void> setAppLanguage(String code) async {
  appLanguageNotifier.value = code;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', code);
  } catch (_) {}
}

// ✅ Получить текущие переводы
AppTranslations getTranslations() {
  return AppTranslations(appLanguageNotifier.value);
}