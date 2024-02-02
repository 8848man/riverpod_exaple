import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_example1/common/model/cursor_pagination_model.dart';
import 'package:riverpod_example1/common/model/pagination_params.dart';
import 'package:riverpod_example1/common/provider/pagination_provider.dart';
import 'package:riverpod_example1/restaurant/model/restaurant_model.dart';
import 'package:riverpod_example1/restaurant/repositroy/restaurant_repository.dart';

final restaurantDetailProvider =
    Provider.family<RestaurantModel?, String>((ref, id) {
  final state = ref.watch(restaurantProvider);

  if (state is! CursorPagination) {
    return null;
  }

  return state.data.firstWhere((element) => element.id == id);
});

final restaurantProvider =
    StateNotifierProvider<RestaurantStateNotifier, CursorPaginationBase>(
  (ref) {
    final repository = ref.watch(restaurantRepositoryProvider);

    final notifier = RestaurantStateNotifier(repository: repository);

    return notifier;
  },
);

class RestaurantStateNotifier
    extends PaginationProvider<RestaurantModel, RestaurantRepository> {
  RestaurantStateNotifier({
    required super.repository,
  });

  getDetail({
    required String id,
  }) async {
    // 만약에 아직 데이터가 하나도 없는 상태라면 (CursorPagination이 아니라면)
    // 데이터를 가져오는 시도를 한다.
    if (state is! CursorPagination) {
      await this.paginate();
    }

    // state가 CursorPagination이 아닐 때 그냥 return
    if (state is! CursorPagination) {
      return;
    }

    final pState = state as CursorPagination;

    final resp = await repository.getRestaurantDetail(id: id);

    // [RestaurantMode(1), RestaurantMode(2), RestaurantMode(3)]이 있을 때
    // id : 2인 Detail 모델을 가져와라
    // getDetail(id: 2); 요청을 하면
    // [RestaurantMode(1), RestaurantDetailMode(2), RestaurantMode(3)] id가 2인 RestaurantModel을 DetailModel로 바꿔준다.
    state = pState.copyWith(
      data: pState.data
          .map<RestaurantModel>((e) => e.id == id ? resp : e)
          .toList(),
    );
  }
}
