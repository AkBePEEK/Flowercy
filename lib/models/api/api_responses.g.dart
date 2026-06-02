// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_responses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendationResponse _$RecommendationResponseFromJson(
        Map<String, dynamic> json) =>
    RecommendationResponse(
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => ProductCard.fromJson(e as Map<String, dynamic>))
          .toList(),
      bouquets: (json['bouquets'] as List<dynamic>?)
          ?.map((e) => ProductCard.fromJson(e as Map<String, dynamic>))
          .toList(),
      userId: json['user_id'] as String?,
    );

Map<String, dynamic> _$RecommendationResponseToJson(
        RecommendationResponse instance) =>
    <String, dynamic>{
      'results': instance.results,
      'bouquets': instance.bouquets,
      'user_id': instance.userId,
    };

ImageGenerationResponse _$ImageGenerationResponseFromJson(
        Map<String, dynamic> json) =>
    ImageGenerationResponse(
      imageBase64: json['image_base64'] as String?,
      imagePath: json['image_path'] as String?,
    );

Map<String, dynamic> _$ImageGenerationResponseToJson(
        ImageGenerationResponse instance) =>
    <String, dynamic>{
      'image_base64': instance.imageBase64,
      'image_path': instance.imagePath,
    };

ThreeDStructureResponse _$ThreeDStructureResponseFromJson(
        Map<String, dynamic> json) =>
    ThreeDStructureResponse(
      coordinates: (json['coordinates'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      totalCount: (json['total_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ThreeDStructureResponseToJson(
        ThreeDStructureResponse instance) =>
    <String, dynamic>{
      'coordinates': instance.coordinates,
      'total_count': instance.totalCount,
    };

CatalogFlowersResponse _$CatalogFlowersResponseFromJson(
        Map<String, dynamic> json) =>
    CatalogFlowersResponse(
      flowers: (json['flowers'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$CatalogFlowersResponseToJson(
        CatalogFlowersResponse instance) =>
    <String, dynamic>{
      'flowers': instance.flowers,
    };

ComposeBouquetResponse _$ComposeBouquetResponseFromJson(
        Map<String, dynamic> json) =>
    ComposeBouquetResponse(
      variations: (json['variations'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$ComposeBouquetResponseToJson(
        ComposeBouquetResponse instance) =>
    <String, dynamic>{
      'variations': instance.variations,
    };
