import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

// ─────────────────────────────────────────────────────────────
// ПЕРЕВОДЫ — все строки приложения
// ─────────────────────────────────────────────────────────────
class AppTranslations {
  final String languageCode;
  AppTranslations(this.languageCode);

  static final Map<String, Map<String, String>> _data = {
    'en': {
      // Navigation
      'home': 'Home',
      'search': 'Search',
      'favorites': 'Favorites',
      'cart': 'Cart',
      'profile': 'Profile',
      // Profile
      'myOrders': 'My Orders',
      'savedAddresses': 'Saved Addresses',
      'language': 'Language',
      'logout': 'Log out',
      'deleteAccount': 'Delete Account',
      'settings': 'Settings',
      'notifications': 'Notifications',
      'about_us': 'About us',
      'app_name': 'Flowery App',
      'about_app_description': 'Your favorite flower delivery app. Made with ❤️ in Astana.',
      // Cart
      'cartEmpty': 'Your cart is empty',
      'browseFlowers': 'Browse flowers',
      'addSomeFlowers': 'Add some flowers to get started',
      'goToCheckout': 'Go to checkout',
      'total': 'Total',
      'delivery': 'Delivery',
      'price': 'Price',
      'clearCart': 'Clear cart?',
      'removeAllItems': 'Remove all items from your cart?',
      'commentSeller': 'Comment for the seller',
      'promocode': 'Promocode',
      'usePromocode': 'Use',
      'youHavePromocode': 'You have one promocode',
      'error_load_cart': 'Failed to load cart',
      'people_add_to_order': 'People add to the order',
      'postcard': 'Postcard',
      'clear': 'Clear',
      'cart_is_empty': 'Cart is empty',
      // Orders
      'orderDetails': 'Order details',
      'recipient': 'Recipient',
      'address': 'Address',
      'payment': 'Payment',
      'payOrder': 'Pay for the order',
      'myOrdersTitle': 'My Orders',
      'activeOrders': 'Active',
      'historyOrders': 'History',
      'noActiveOrders': 'No active orders',
      'repeatOrder': 'Repeat order',
      'orderComposition': 'Order composition',
      'courierComment': 'Comment for the courier',
      'addComment': 'Add',
      // Addresses
      'savedAddressesTitle': 'Saved addresses',
      'addAddress': 'Add address',
      'noAddresses': 'No saved addresses yet',
      'defaultAddress': 'Default',
      'street': 'Street',
      'apartment': 'Apt./Office',
      'city': 'City',
      'deleteAddress': 'Delete address?',
      // Auth
      'signIn': 'Sign In',
      'signUp': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'forgotPassword': 'Forgot password?',
      'noAccount': 'Don\'t have an account?',
      'haveAccount': 'Already have an account?',
      // Common
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'retry': 'Retry',
      'yes': 'Yes',
      'no': 'No',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'back': 'Back',
      'selectLanguage': 'Select Language',
      'notFound': 'Page not found',
      'goHome': 'Go to main',
      'error_load_shops': 'Failed to load shops',
      'no_shops_found': 'No shops found',
      'most_popular': 'Most popular',
      'search_hint_full': 'Flowers, markets, or gifts',
      'rating': 'rating',
      'review': 'review',
      'free_delivery': 'Free delivery',
      'bouquets': 'Bouquets',
      'markets': 'Markets',
      'no_favorite_bouquets': 'No favorite bouquets yet',
      'no_favorite_bouquets_hint': 'Tap the heart icon on any bouquet to save it',
      'no_favorite_markets': 'No favorite markets yet',
      'removed_from_favorites': 'removed from favorites',
      'error_load_favorites': 'Failed to load favorites',
      'error_load_addresses': 'Failed to load addresses',
      'address_selected': 'Address selected',
      'address_deleted': 'Address deleted',
      'error_delete_address': 'Failed to delete address',
      'delete_address_confirm': 'Are you sure you want to delete',
      'no_addresses_hint': 'Add your first address for faster checkout',
      'error_save_address': 'Failed to save',
      'flowers_and_bouquets': 'Flowers and bouquets',
      'sweets_and_gifts': 'Sweets and gifts',
      'included_flowers': 'Included flowers',
      'included_sweets': 'Included sweets',
      'includes': 'Includes',
      'excludes': 'Excludes',
      'apply_filters': 'Apply filters',
      'shops_nearby': 'shops nearby',
      'today': 'Today',
      'paid': 'Paid',
      'unknown': 'Unknown',
      'no_products_category': 'No products available for',
      // Flower types
      'roses': 'Roses',
      'tulips': 'Tulips',
      'peonies': 'Peonies',
      'peony_roses': 'Peony roses',
      'chrysanthemums': 'Chrysanthemums',
      'alstroemerias': 'Alstroemerias',
      'amaryllis': 'Amaryllis',
      'anemones': 'Anemones',
      'asters': 'Asters',
      'cornflowers': 'Cornflowers',
      'carnations': 'Carnations',
      // Sweets types
      'chocolate': 'Chocolate',
      'macarons': 'Macarons',
      'cupcakes': 'Cupcakes',
      'cookies': 'Cookies',
      'candy': 'Candy',
      'marshmallows': 'Marshmallows',
      'caramel': 'Caramel',
      'nuts': 'Nuts',
      'berries': 'Berries',
      'honey': 'Honey',
      'cakes': 'Cakes',
      'gift_boxes': 'Gift boxes',
      // Filters
      'price_filter': 'Price',
      'sweets_type': 'Sweets type',
      'delivery_time': 'Delivery time',
      'gift_box': 'Gift box',
      'product_not_found': 'Product not found',
      'shop_not_found': 'Shop not found',
      'added_to_favorites': 'Added to favorites',
      'removed_from_favorites_msg': 'Removed from favorites',
      'added_to_cart_msg': 'Added to cart',
      'failed_to_add_to_cart': 'Failed to add to cart',
      'verified_availability': 'Verified availability',
      'description': 'Description',
      'size': 'Size',
      'width': 'Width',
      'height': 'Height',
      'go_to_store': 'Go to store',
      'contact_shop': 'Contact shop',
      'buyer_protection': 'Buyer protection',
      'buyer_protection_desc': 'If the item doesn\'t match the description, you can return it at the shop\'s expense or receive a full refund.',
      'cancellation_policy': 'Cancellation policy',
      'cancellation_policy_desc': 'Free cancellation is available until delivery starts. You will receive a full refund.',
      'report_listing': 'Report this listing',
      'working_hours': 'Working hours',
      'about': 'About',
      'reviews_count': 'reviews',
      'items_count': 'items',
      'sales_count': 'sales',
      'free_delivery_in_hours': 'Free delivery in 2 hours',
      'paid_delivery': 'Paid delivery',
      'add_to_cart': 'Add to cart',
      'user_not_found': 'User not found',
      'wrong_password': 'Incorrect password',
      'invalid_credential': 'Incorrect email or password',
      'invalid_email': 'Please enter a valid email address',
      'user_disabled': 'This account has been disabled',
      'too_many_requests': 'Too many attempts. Try again later',
      'general_error': 'Something went wrong. Please try again.',
      'network_error': 'Network error. Check your connection.',
      'fill_all_fields': 'Please fill in all fields',
      'enter_valid_email': 'Please enter a valid email address',
      'passwords_dont_match': 'Passwords don\'t match',
      'min_6_chars': 'Minimum 6 characters',
      'confirm_password_hint': 'Re-enter your password',
      'welcome_to_flowery': 'Welcome to Flowery',
      'find_dream_flowers': 'Find your dream flowers!',
      'sign_up_apple': 'Sign Up with Apple',
      'sign_up_google': 'Sign Up with Google',
      'sign_up_email': 'Sign Up with Email',
      'or': 'or',
      'enter_email_hint': 'Enter your email',
      'enter_password_hint': 'Enter your password',
      'signing_in_btn': 'Signing in...',
      'registration_success_msg': 'Registration successful! 🎉',
      'email_already_in_use': 'This email is already registered',
      'operation_not_allowed': 'Registration is disabled',
      'enter_email_error': 'Enter email',
      'enter_password_error': 'Enter password',
      'confirm_password_error': 'Confirm password',
      'order_id_not_provided': 'Order ID not provided',
      'failed_to_load_order': 'Failed to load order',
      'order_repeated_success': 'Order repeated successfully! 🌸',
      'failed_to_repeat_order': 'Failed to repeat order',
      'order_not_found': 'Order not found',
      'order_number_label': 'Order',
      'faster_delivery': 'Faster',
      'delivery_time_subtitle': 'in 45 - 55 min.',
      'another_time': 'Another time',
      'choose_date_time': 'Choose date and time',
      'bank_card': 'Bank card',
      'pay_now': 'Pay now',
      'upon_receipt': 'Upon receipt',
      'payment_receipt': 'Payment receipt',
      'apt_office_floor_entrance': 'Apt./Office/Floor/Entrance',
      'apt_office_floor_entrance_hint': 'Apt. 510 /...',
      'important_details': 'Important details',
      'important_details_hint': 'For example: include your name in the SMS or arrange a surprise',
      'select_label': 'Select',
      'order_placed_title': 'Order placed!',
      'order_placed_msg': 'Your order has been placed successfully.',
      'failed_to_place_order': 'Failed to place order. Try again.',
      'order_status_placed': 'The order has been placed',
      'order_status_collecting': 'Collecting the order',
      'order_status_delivery': 'The courier is on his way',
      'order_status_delivered': 'The order has been delivered',
      'order_cancelled_msg': 'Order cancelled',
      'cancel_order_confirm_title': 'Cancel order?',
      'cancel_order_confirm_msg': 'Are you sure you want to cancel this order?',
      'support': 'Support',
      'call_support': 'Call support',
      'chat_with_us': 'Chat with us',
      'details': 'Details',
      'no_orders_yet': 'No orders yet 🌸',
      'order_preview': 'Order',
      'courier_comment_hint': 'Please write your wishes regarding the order composition, packaging and decoration.',
      'ready': 'Ready',
      'edit_address': 'Edit address',
      'add_new_address': 'Add new address',
      'street_address': 'Street address *',
      'street_required': 'Street is required',
      'street_hint': 'e.g., Uly Dala Avenue, 31',
      'apt_office_floor_label': 'Apartment / Office / Floor',
      'apt_office_floor_example': 'e.g., Apt. 510, 5th floor',
      'city_label': 'City *',
      'city_required': 'City is required',
      'city_hint': 'e.g., Astana',
      'set_as_default': 'Set as default address',
      'save_changes': 'Save changes',
      'error_load_profile': 'Failed to load profile',
      'error_sign_out': 'Failed to sign out. Please try again.',
      'flowers': 'Flowers',
      'sweets': 'Sweets',
      'plants': 'Plants',
      'bears': 'Bears',
      'balloons': 'Balloons',
      'ai_florist_title': 'AI Florist',
      'ai_florist_description': 'Choose flowers, set budget and occasion — AI will generate the perfect bouquet. Send it to a florist!',
      'generation': 'Generation',
      'to_florist': 'To Florist',
      'create_ai_bouquet': 'Create AI Bouquet',
      'top_pick': 'Top pick',
      'top_choice': 'Top Choice',
      'status_placed': 'Order placed',
      'status_collecting': 'Collecting order',
      'status_delivery': 'Courier is on the way',
      'status_in_progress': 'Order in progress',
      'delivery_today': 'We deliver flowers today',
      // Search
      'searchHint': 'Search flowers, shops...',
      'searchResults': 'Search results',
      'noResults': 'Nothing found',
      // Logs/Errors
      'error_loading_product': 'Error loading product',
      'error_loading_shop': 'Error loading shop',
      'seed_complete': 'Seed complete!',
    },
    'ru': {
      // Navigation
      'home': 'Главная',
      'search': 'Поиск',
      'favorites': 'Избранное',
      'cart': 'Корзина',
      'profile': 'Профиль',
      // Profile
      'myOrders': 'Мои заказы',
      'savedAddresses': 'Адреса',
      'language': 'Язык',
      'logout': 'Выйти',
      'deleteAccount': 'Удалить аккаунт',
      'settings': 'Настройки',
      'notifications': 'Уведомления',
      'about_us': 'О нас',
      'app_name': 'Flowery App',
      'about_app_description': 'Ваше любимое приложение для доставки цветов. Сделано с ❤️ в Астане.',
      // Cart
      'cartEmpty': 'Корзина пуста',
      'browseFlowers': 'Посмотреть цветы',
      'addSomeFlowers': 'Добавьте цветы для начала',
      'goToCheckout': 'Оформить заказ',
      'total': 'Итого',
      'delivery': 'Доставка',
      'price': 'Цена',
      'clearCart': 'Очистить корзину?',
      'removeAllItems': 'Удалить все товары из корзины?',
      'commentSeller': 'Комментарий продавцу',
      'promocode': 'Промокод',
      'usePromocode': 'Применить',
      'youHavePromocode': 'У вас есть промокод',
      'error_load_cart': 'Не удалось загрузить корзину',
      'people_add_to_order': 'Добавьте к заказу',
      'postcard': 'Открытка',
      'clear': 'Очистить',
      'cart_is_empty': 'Корзина пуста',
      // Orders
      'orderDetails': 'Детали заказа',
      'recipient': 'Получатель',
      'address': 'Адрес',
      'payment': 'Оплата',
      'payOrder': 'Оплатить заказ',
      'myOrdersTitle': 'Мои заказы',
      'activeOrders': 'Активные',
      'historyOrders': 'История',
      'noActiveOrders': 'Нет активных заказов',
      'repeatOrder': 'Повторить заказ',
      'orderComposition': 'Состав заказа',
      'courierComment': 'Комментарий курьеру',
      'addComment': 'Добавить',
      // Addresses
      'savedAddressesTitle': 'Сохранённые адреса',
      'addAddress': 'Добавить адрес',
      'noAddresses': 'Нет сохранённых адресов',
      'defaultAddress': 'По умолчанию',
      'street': 'Улица',
      'apartment': 'Кв./Офис',
      'city': 'Город',
      'deleteAddress': 'Удалить адрес?',
      // Auth
      'signIn': 'Войти',
      'signUp': 'Регистрация',
      'email': 'Email',
      'password': 'Пароль',
      'forgotPassword': 'Забыли пароль?',
      'noAccount': 'Нет аккаунта?',
      'haveAccount': 'Уже есть аккаунт?',
      // Common
      'save': 'Сохранить',
      'cancel': 'Отмена',
      'delete': 'Удалить',
      'edit': 'Редактировать',
      'retry': 'Повторить',
      'yes': 'Да',
      'no': 'Нет',
      'loading': 'Загрузка...',
      'error': 'Ошибка',
      'success': 'Успешно',
      'back': 'Назад',
      'selectLanguage': 'Выберите язык',
      'notFound': 'Страница не найдена',
      'goHome': 'На главную',
      'error_load_profile': 'Не удалось загрузить профиль',
      'error_sign_out': 'Ошибка выхода. Попробуйте еще раз.',
      'flowers': 'Цветы',
      'sweets': 'Сладости',
      'plants': 'Растения',
      'bears': 'Медведи',
      'balloons': 'Шары',
      'ai_florist_title': 'AI Флорист',
      'ai_florist_description': 'Выберите цветы, укажите бюджет и повод — AI создаст идеальный букет. Отправьте его флористу!',
      'generation': 'Генерация',
      'to_florist': 'Флористу',
      'create_ai_bouquet': 'Создать букет с AI',
      'top_pick': 'Лучший выбор',
      'top_choice': 'Топ выбор',
      'status_placed': 'Заказ оформлен',
      'status_collecting': 'Сборка заказа',
      'status_delivery': 'Курьер в пути',
      'status_in_progress': 'Заказ выполняется',
      'delivery_today': 'Доставим цветы сегодня',
      // Search
      'searchHint': 'Поиск цветов, магазинов...',
      'searchResults': 'Результаты поиска',
      'noResults': 'Ничего не найдено',
      // Logs/Errors
      'error_loading_product': 'Ошибка загрузки товара',
      'error_loading_shop': 'Ошибка загрузки магазина',
      'seed_complete': 'Сидирование завершено!',
    },
    'kk': {
      // Navigation
      'home': 'Басты',
      'search': 'Іздеу',
      'favorites': 'Таңдаулы',
      'cart': 'Себет',
      'profile': 'Профиль',
      // Profile
      'myOrders': 'Менің тапсырыстарым',
      'savedAddresses': 'Мекенжайлар',
      'language': 'Тіл',
      'logout': 'Шығу',
      'deleteAccount': 'Аккаунтты жою',
      'settings': 'Параметрлер',
      'notifications': 'Хабарламалар',
      'about_us': 'Біз туралы',
      'app_name': 'Flowery App',
      'about_app_description': 'Сіздің сүйікті гүл жеткізу қолданбаңыз. Астанада ❤️-мен жасалған.',
      // Cart
      'cartEmpty': 'Себет бос',
      'browseFlowers': 'Гүлдерді қарау',
      'addSomeFlowers': 'Бастау үшін гүл қосыңыз',
      'goToCheckout': 'Тапсырысты рәсімдеу',
      'total': 'Барлығы',
      'delivery': 'Жеткізу',
      'price': 'Баға',
      'clearCart': 'Себетті тазалау?',
      'removeAllItems': 'Барлық тауарларды себеттен жою?',
      'commentSeller': 'Сатушыға пікір',
      'promocode': 'Промокод',
      'usePromocode': 'Қолдану',
      'youHavePromocode': 'Сізде промокод бар',
      'error_load_cart': 'Себетті жүктеу мүмкін болмады',
      'people_add_to_order': 'Тапсырысқа қосыңыз',
      'postcard': 'Ашық хат',
      'clear': 'Тазалау',
      'cart_is_empty': 'Себет бос',
      // Orders
      'orderDetails': 'Тапсырыс мәліметтері',
      'recipient': 'Алушы',
      'address': 'Мекенжай',
      'payment': 'Төлем',
      'payOrder': 'Тапсырысты төлеу',
      'myOrdersTitle': 'Тапсырыстарым',
      'activeOrders': 'Белсенді',
      'historyOrders': 'Тарих',
      'noActiveOrders': 'Белсенді тапсырыс жоқ',
      'repeatOrder': 'Тапсырысты қайталау',
      'orderComposition': 'Тапсырыс құрамы',
      'courierComment': 'Курьерге пікір',
      'addComment': 'Қосу',
      // Addresses
      'savedAddressesTitle': 'Сақталған мекенжайлар',
      'addAddress': 'Мекенжай қосу',
      'noAddresses': 'Сақталған мекенжай жоқ',
      'defaultAddress': 'Әдепкі',
      'street': 'Көше',
      'apartment': 'Пәтер/Кеңсе',
      'city': 'Қала',
      'deleteAddress': 'Мекенжайды жою?',
      // Auth
      'signIn': 'Кіру',
      'signUp': 'Тіркелу',
      'email': 'Email',
      'password': 'Құпия сөз',
      'forgotPassword': 'Құпия сөзді ұмыттыңыз ба?',
      'noAccount': 'Аккаунт жоқ па?',
      'haveAccount': 'Аккаунт бар ма?',
      // Common
      'save': 'Сақтау',
      'cancel': 'Болдырмау',
      'delete': 'Жою',
      'edit': 'Өңдеу',
      'retry': 'Қайталау',
      'yes': 'Иә',
      'no': 'Жоқ',
      'loading': 'Жүктелуде...',
      'error': 'Қате',
      'success': 'Сәтті',
      'back': 'Артқа',
      'selectLanguage': 'Тілді таңдаңыз',
      'notFound': 'Бет табылмады',
      'goHome': 'Басты бетке',
      'error_load_profile': 'Профильді жүктеу мүмкін болмады',
      'error_sign_out': 'Шығу қатесі. Қайталап көріңіз.',
      'flowers': 'Гүлдер',
      'sweets': 'Тәттілер',
      'plants': 'Өсімдіктер',
      'bears': 'Қонжықтар',
      'balloons': 'Шарлар',
      'ai_florist_title': 'AI Флорист',
      'ai_florist_description': 'Гүлдерді таңдаңыз, бюджет пен себепті көрсетіңіз — AI тамаша букет жасайды. Оны флористке жіберіңіз!',
      'generation': 'Генерация',
      'to_florist': 'Флористке',
      'create_ai_bouquet': 'AI-мен букет жасау',
      'top_pick': 'Үздік таңдау',
      'top_choice': 'Топ таңдау',
      'status_placed': 'Тапсырыс қабылданды',
      'status_collecting': 'Тапсырыс жиналуда',
      'status_delivery': 'Курьер жолда',
      'status_in_progress': 'Тапсырыс орындалуда',
      'delivery_today': 'Гүлдерді бүгін жеткіземіз',
      // Search
      'searchHint': 'Гүл, дүкен іздеу...',
      'searchResults': 'Іздеу нәтижелері',
      'noResults': 'Ештеңе табылмады',
      // Logs/Errors
      'error_loading_product': 'Өнімді жүктеу қатесі',
      'error_loading_shop': 'Дүкенді жүктеу қатесі',
      'seed_complete': 'Сидтеу аяқталды!',
    },
  };

  /// Allows calling the object as a function: t('key')
  String call(String key) {
    return _data[languageCode]?[key] ?? _data['en']?[key] ?? key;
  }

  // Getters for backward compatibility (optional but helpful)
  String get home => this('home');
  String get search => this('search');
  String get favorites => this('favorites');
  String get cart => this('cart');
  String get profile => this('profile');
  String get myOrders => this('myOrders');
  String get savedAddresses => this('savedAddresses');
  String get language => this('language');
  String get logout => this('logout');
  String get deleteAccount => this('deleteAccount');
  String get settings => this('settings');
  String get cartEmpty => this('cartEmpty');
  String get browseFlowers => this('browseFlowers');
  String get addSomeFlowers => this('addSomeFlowers');
  String get goToCheckout => this('goToCheckout');
  String get total => this('total');
  String get delivery => this('delivery');
  String get price => this('price');
  String get clearCart => this('clearCart');
  String get removeAllItems => this('removeAllItems');
  String get commentSeller => this('commentSeller');
  String get promocode => this('promocode');
  String get usePromocode => this('usePromocode');
  String get youHavePromocode => this('youHavePromocode');
  String get orderDetails => this('orderDetails');
  String get recipient => this('recipient');
  String get address => this('address');
  String get payment => this('payment');
  String get payOrder => this('payOrder');
  String get myOrdersTitle => this('myOrdersTitle');
  String get activeOrders => this('activeOrders');
  String get historyOrders => this('historyOrders');
  String get noActiveOrders => this('noActiveOrders');
  String get repeatOrder => this('repeatOrder');
  String get orderComposition => this('orderComposition');
  String get courierComment => this('courierComment');
  String get addComment => this('addComment');
  String get savedAddressesTitle => this('savedAddressesTitle');
  String get addAddress => this('addAddress');
  String get noAddresses => this('noAddresses');
  String get defaultAddress => this('defaultAddress');
  String get street => this('street');
  String get apartment => this('apartment');
  String get city => this('city');
  String get deleteAddress => this('deleteAddress');
  String get signIn => this('signIn');
  String get signUp => this('signUp');
  String get email => this('email');
  String get password => this('password');
  String get forgotPassword => this('forgotPassword');
  String get noAccount => this('noAccount');
  String get haveAccount => this('haveAccount');
  String get save => this('save');
  String get cancel => this('cancel');
  String get delete => this('delete');
  String get edit => this('edit');
  String get retry => this('retry');
  String get yes => this('yes');
  String get no => this('no');
  String get loading => this('loading');
  String get error => this('error');
  String get success => this('success');
  String get back => this('back');
  String get selectLanguage => this('selectLanguage');
  String get notFound => this('notFound');
  String get goHome => this('goHome');
  String get searchHint => this('searchHint');
  String get searchResults => this('searchResults');
  String get noResults => this('noResults');
  String get notifications => this('notifications');
  String get about_us => this('about_us');
  String get app_name => this('app_name');
  String get about_app_description => this('about_app_description');
  String get error_load_profile => this('error_load_profile');
  String get error_sign_out => this('error_sign_out');
  String get error_load_cart => this('error_load_cart');
  String get people_add_to_order => this('people_add_to_order');
  String get postcard => this('postcard');
  String get clear => this('clear');
  String get cart_is_empty => this('cart_is_empty');
}

// ✅ Глобальная функция смены языка — вызывай отовсюду
Future<void> setAppLanguage(String code) async {
  appLanguageNotifier.value = code;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', code);
  } catch (_) {}
}

// ✅ Глобальная переменная t для быстрого доступа
AppTranslations get t => getTranslations();

// ✅ Получить текущие переводы
AppTranslations getTranslations() {
  return AppTranslations(appLanguageNotifier.value);
}

mixin LanguageStateMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    appLanguageNotifier.addListener(_onLangChanged);
  }

  @override
  void dispose() {
    appLanguageNotifier.removeListener(_onLangChanged);
    super.dispose();
  }

  void _onLangChanged() {
    if (mounted) setState(() {});
  }
}
