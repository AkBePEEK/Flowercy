// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductCard _$ProductCardFromJson(Map<String, dynamic> json) => ProductCard(
      id: ProductCard._stringFromJson(json['id']),
      name: ProductCard._stringFromJson(json['name']),
      price: ProductCard._doubleFromJson(json['price']),
      imageUrl: ProductCard._stringFromJson(json['imageUrl']),
      provider: ProductCard._stringFromJson(json['provider']),
      storeId: ProductCard._stringFromJson(json['storeId']),
      inStock: ProductCard._boolFromJson(json['inStock']),
      description: json['description'] as String?,
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$ProductCardToJson(ProductCard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'imageUrl': instance.imageUrl,
      'provider': instance.provider,
      'storeId': instance.storeId,
      'inStock': instance.inStock,
      'description': instance.description,
      'reason': instance.reason,
    };
