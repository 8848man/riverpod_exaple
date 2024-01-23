import 'package:riverpod_example1/common/utils/data_utils.dart';
import 'package:riverpod_example1/restaurant/model/restaurant_model.dart';
import 'package:json_annotation/json_annotation.dart';


part 'restaurant_detail_model.g.dart';
// 이 모델은 왜 RestaurantModel을 extends받았나? -> 중복되는 값 작업을 최소화하기 위해

@JsonSerializable()
class RestaurantDetailModel extends RestaurantModel {
  final String detail;
  final List<RestaurantProductModel> products;

  RestaurantDetailModel({
    required super.id,
    required super.name,
    required super.thumbUrl,
    required super.tags,
    required super.priceRange,
    required super.ratings,
    required super.ratingsCount,
    required super.deliveryTime,
    required super.deliveryFee,
    required this.detail,
    required this.products,
  });

  factory RestaurantDetailModel.fromJson(Map<String, dynamic> json) =>
      _$RestaurantDetailModelFromJson(json);
}

// 왜 만들었나? -> List<Map<String, dynamic>>으로 받아도 되지만, 객체화해서 dynamic들을 명시하기 위해

@JsonSerializable()
class RestaurantProductModel {
  final String id;
  final String name;
  @JsonKey(
    fromJson: DataUtils.pathToUrl,
  )
  final String imgUrl;
  final String detail;
  final int price;

  RestaurantProductModel(
      {required this.id,
      required this.name,
      required this.imgUrl,
      required this.detail,
      required this.price});

  factory RestaurantProductModel.fromJson(Map<String, dynamic> json) =>
      _$RestaurantProductModelFromJson(json);
}
