// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'placement_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlacementDetail _$PlacementDetailFromJson(Map<String, dynamic> json) {
  return PlacementDetail(
    id: json['id'] as int,
  );
}

Map<String, dynamic> _$PlacementDetailToJson(PlacementDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
    };

Owner _$OwnerFromJson(Map<String, dynamic> json) {
  return Owner(
    id: json['id'] as int,
    email: json['email'] as String,
    photo: json['photo'] as String,
    fullName: json['fullName'] as String,
  );
}

Map<String, dynamic> _$OwnerToJson(Owner instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'fullName': instance.fullName,
      'photo': instance.photo,
    };
