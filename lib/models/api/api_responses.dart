import 'package:json_annotation/json_annotation.dart';
import 'product_card.dart';

part 'api_responses.g.dart';

@JsonSerializable()
class RecommendationResponse {
  final List<ProductCard>? results;
  final List<ProductCard>? bouquets; // Added to match /recommend response
  @JsonKey(name: 'user_id')
  final String? userId;

  RecommendationResponse({this.results, this.bouquets, this.userId});

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) => _$RecommendationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationResponseToJson(this);
}

@JsonSerializable()
class ImageGenerationResponse {
  @JsonKey(name: 'image_base64')
  final String? imageBase64;
  @JsonKey(name: 'image_path')
  final String? imagePath;

  ImageGenerationResponse({this.imageBase64, this.imagePath});

  factory ImageGenerationResponse.fromJson(Map<String, dynamic> json) => _$ImageGenerationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ImageGenerationResponseToJson(this);
}

@JsonSerializable()
class ThreeDStructureResponse {
  final List<Map<String, dynamic>>? coordinates;
  @JsonKey(name: 'total_count')
  final int? totalCount;

  ThreeDStructureResponse({this.coordinates, this.totalCount});

  factory ThreeDStructureResponse.fromJson(Map<String, dynamic> json) => _$ThreeDStructureResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ThreeDStructureResponseToJson(this);
}

@JsonSerializable()
class CatalogFlowersResponse {
  final List<Map<String, dynamic>>? flowers;

  CatalogFlowersResponse({this.flowers});

  factory CatalogFlowersResponse.fromJson(Map<String, dynamic> json) => _$CatalogFlowersResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CatalogFlowersResponseToJson(this);
}

@JsonSerializable()
class ComposeBouquetResponse {
  final List<Map<String, dynamic>>? variations;

  ComposeBouquetResponse({this.variations});

  factory ComposeBouquetResponse.fromJson(Map<String, dynamic> json) => _$ComposeBouquetResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ComposeBouquetResponseToJson(this);
}
