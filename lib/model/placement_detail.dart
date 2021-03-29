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
@JsonSerializable()
class Owner extends Decoder<Owner>{

  int id;
  String email, fullName;
  String photo;

  Owner({
    this.id,
    this.email,
    this.photo,
    this.fullName
  });

  factory Owner.fromJson(Map<String, dynamic> json) =>_$OwnerFromJson(json);
  Map<String, dynamic> toJson() => _$OwnerToJson(this);

  @override
  Owner fromJSON(Map<String, dynamic> json) {
    return Owner.fromJson(json);
  }

}
