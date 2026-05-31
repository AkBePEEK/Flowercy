import 'package:json_annotation/json_annotation.dart';
import 'product_card.dart';

part 'api_order.g.dart';

@JsonSerializable()
class ApiOrder {
  @JsonKey(name: 'order_id')
  final String orderId;
  final String status;
  @JsonKey(name: 'user_id')
  final String userId;
  final ProductCard product;
  final DeliveryInfo delivery;
  @JsonKey(name: 'florist_photo_url')
  final String? floristPhotoUrl;
  final List<OrderHistoryItem> history;

  ApiOrder({
    required this.orderId,
    required this.status,
    required this.userId,
    required this.product,
    required this.delivery,
    this.floristPhotoUrl,
    required this.history,
  });

  factory ApiOrder.fromJson(Map<String, dynamic> json) => _$ApiOrderFromJson(json);
  Map<String, dynamic> toJson() => _$ApiOrderToJson(this);
}

@JsonSerializable()
class DeliveryInfo {
  final String address;
  final String city;
  final String? notes;

  DeliveryInfo({
    required this.address,
    required this.city,
    this.notes,
  });

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) => _$DeliveryInfoFromJson(json);
  Map<String, dynamic> toJson() => _$DeliveryInfoToJson(this);
}

@JsonSerializable()
class OrderHistoryItem {
  final String timestamp;
  final String status;
  final String? note;

  OrderHistoryItem({
    required this.timestamp,
    required this.status,
    this.note,
  });

  factory OrderHistoryItem.fromJson(Map<String, dynamic> json) => _$OrderHistoryItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderHistoryItemToJson(this);
}
