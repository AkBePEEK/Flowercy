import 'dart:async';

enum PaymentMethod {
  card,
  kaspi,
  cash,
}

class PaymentResult {
  final bool success;
  final String? message;
  final String? transactionId;

  PaymentResult({required this.success, this.message, this.transactionId});
}

class PaymentService {
  // ✅ Симуляция обработки платежа
  Future<PaymentResult> processPayment({
    required PaymentMethod method,
    required int amount,
    Map<String, dynamic>? details,
  }) async {
    // Имитация сетевой задержки
    await Future.delayed(const Duration(seconds: 2));

    switch (method) {
      case PaymentMethod.card:
        // В реальном приложении здесь был бы вызов Stripe/Adyen/etc.
        return PaymentResult(
          success: true,
          message: 'Платеж по карте успешно обработан',
          transactionId: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
        );
      case PaymentMethod.kaspi:
        // Имитация оплаты через Kaspi.kz
        return PaymentResult(
          success: true,
          message: 'Оплата через Kaspi.kz успешно завершена',
          transactionId: 'KASPI-${DateTime.now().millisecondsSinceEpoch}',
        );
      case PaymentMethod.cash:
        // При оплате наличными платеж считается успешным (будет оплачено при получении)
        return PaymentResult(
          success: true,
          message: 'Заказ будет оплачен при получении',
        );
    }
  }
}
