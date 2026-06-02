// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiOrder _$ApiOrderFromJson(Map<String, dynamic> json) => ApiOrder(
      orderId: json['order_id'] as String,
      status: json['status'] as String,
      userId: json['user_id'] as String,
      product: ProductCard.fromJson(json['product'] as Map<String, dynamic>),
      delivery: DeliveryInfo.fromJson(json['delivery'] as Map<String, dynamic>),
      floristPhotoUrl: json['florist_photo_url'] as String?,
      history: (json['history'] as List<dynamic>)
          .map((e) => OrderHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ApiOrderToJson(ApiOrder instance) => <String, dynamic>{
      'order_id': instance.orderId,
      'status': instance.status,
      'user_id': instance.userId,
      'product': instance.product,
      'delivery': instance.delivery,
      'florist_photo_url': instance.floristPhotoUrl,
      'history': instance.history,
    };

DeliveryInfo _$DeliveryInfoFromJson(Map<String, dynamic> json) => DeliveryInfo(
      address: json['address'] as String,
      city: json['city'] as String,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$DeliveryInfoToJson(DeliveryInfo instance) =>
    <String, dynamic>{
      'address': instance.address,
      'city': instance.city,
      'notes': instance.notes,
    };

OrderHistoryItem _$OrderHistoryItemFromJson(Map<String, dynamic> json) =>
    OrderHistoryItem(
      timestamp: json['timestamp'] as String,
      status: json['status'] as String,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$OrderHistoryItemToJson(OrderHistoryItem instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'status': instance.status,
      'note': instance.note,
    };
