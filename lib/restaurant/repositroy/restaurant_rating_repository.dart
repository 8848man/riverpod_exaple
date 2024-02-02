import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_example1/common/const/data.dart';
import 'package:riverpod_example1/common/dio/dio.dart';
import 'package:riverpod_example1/common/model/cursor_pagination_model.dart';
import 'package:riverpod_example1/common/model/pagination_params.dart';
import 'package:riverpod_example1/common/repository/base_pagination_repository.dart';
import 'package:riverpod_example1/rating/model/rating_model.dart';

part 'restaurant_rating_repository.g.dart';

final restaurantRatingRepositoryProvider =
    Provider.family<RestaurantRatingRepository, String>((ref, id) {
  final dio = ref.watch(dioProvider);

  return RestaurantRatingRepository(dio,
      baseUrl: 'http://$ip/restaurant/$id/rating');
});

// http://ip/restaurant/:rid/rating
@RestApi()
abstract class RestaurantRatingRepository
    implements IBasePaginationRepository<RatingModel> {
  factory RestaurantRatingRepository(Dio dio, {String baseUrl}) =
      _RestaurantRatingRepository;

  @GET('/')
  @Headers({
    'authorization': 'true',
  })
  Future<CursorPagination<RatingModel>> paginate({
    // @Queries는 레트로핏에서 지원하는 패러미터 전달자(?)인듯
    @Queries() PaginationParams? paginationParams = const PaginationParams(),
  });
}
