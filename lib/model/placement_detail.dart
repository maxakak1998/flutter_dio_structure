import 'package:json_annotation/json_annotation.dart';
import 'package:mysample/api/api_controller.dart';
import 'package:mysample/api/api_response.dart';

part 'placement_detail.g.dart';

@JsonSerializable()
class PlacementDetail extends Decoder<PlacementDetail> {
  final int id;

  factory PlacementDetail.fromJson(Map<String, dynamic> json) =>
      _$PlacementDetailFromJson(json);

  Map<String, dynamic> toJson() => _$PlacementDetailToJson(this);

  PlacementDetail({this.id});

  @override
  PlacementDetail fromJSON(Map<String, dynamic> json) {
    return PlacementDetail.fromJson(json);
  }
}