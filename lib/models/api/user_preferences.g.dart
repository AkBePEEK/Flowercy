// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    UserPreferences(
      userId: json['user_id'] as String?,
      occasion: json['occasion'] as String?,
      colors:
          (json['colors'] as List<dynamic>?)?.map((e) => e as String).toList(),
      mood: json['mood'] as String?,
      size: json['size'] as String?,
      flowersInclude: (json['flowers_include'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      flowersAvoid: (json['flowers_avoid'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      budgetMax: (json['budget_max'] as num?)?.toDouble(),
      topN: (json['top_n'] as num?)?.toInt(),
      includeExternal: json['include_external'] as bool?,
    );

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'occasion': instance.occasion,
      'colors': instance.colors,
      'mood': instance.mood,
      'size': instance.size,
      'flowers_include': instance.flowersInclude,
      'flowers_avoid': instance.flowersAvoid,
      'budget_max': instance.budgetMax,
      'top_n': instance.topN,
      'include_external': instance.includeExternal,
    };
