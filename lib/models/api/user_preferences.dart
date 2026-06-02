import 'package:json_annotation/json_annotation.dart';

part 'user_preferences.g.dart';

@JsonSerializable()
class UserPreferences {
  @JsonKey(name: 'user_id')
  final String? userId;
  final String? occasion;
  final List<String>? colors;
  final String? mood;
  final String? size;
  @JsonKey(name: 'flowers_include')
  final List<String>? flowersInclude;
  @JsonKey(name: 'flowers_avoid')
  final List<String>? flowersAvoid;
  @JsonKey(name: 'budget_max')
  final double? budgetMax;
  @JsonKey(name: 'top_n')
  final int? topN;
  @JsonKey(name: 'include_external')
  final bool? includeExternal;

  UserPreferences({
    this.userId,
    this.occasion,
    this.colors,
    this.mood,
    this.size,
    this.flowersInclude,
    this.flowersAvoid,
    this.budgetMax,
    this.topN,
    this.includeExternal,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);
}
