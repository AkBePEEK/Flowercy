import 'package:json_annotation/json_annotation.dart';

part 'product_card.g.dart';

@JsonSerializable()
class ProductCard {
  @JsonKey(fromJson: _stringFromJson)
  final String id;
  @JsonKey(fromJson: _stringFromJson)
  final String name;
  @JsonKey(fromJson: _doubleFromJson)
  final double price;
  @JsonKey(name: 'imageUrl', fromJson: _stringFromJson)
  final String imageUrl;
  @JsonKey(fromJson: _stringFromJson)
  final String provider;
  @JsonKey(name: 'storeId', fromJson: _stringFromJson)
  final String storeId;
  @JsonKey(fromJson: _boolFromJson)
  final bool inStock;
  final String? description;
  final String? reason;

  ProductCard({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.provider,
    required this.storeId,
    required this.inStock,
    this.description,
    this.reason,
  });

  static String _stringFromJson(dynamic value) => value?.toString() ?? '';

  static double _doubleFromJson(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static bool _boolFromJson(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return false;
  }

  factory ProductCard.fromJson(Map<String, dynamic> json) => _$ProductCardFromJson(json);
  Map<String, dynamic> toJson() => _$ProductCardToJson(this);
}
