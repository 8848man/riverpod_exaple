import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_example1/common/model/cursor_pagination_model.dart';
import 'package:riverpod_example1/restaurant/model/restaurant_model.dart';
import 'package:riverpod_example1/restaurant/repositroy/restaurant_repository.dart';

final restaurantProvider =
    StateNotifierProvider<RestaurantStateNotifier, CursorPaginationBase>(
  (ref) {
    final repository = ref.watch(restaurantRepositoryProvider);

    final notifier = RestaurantStateNotifier(repository: repository);

    return notifier;
  },
);

class RestaurantStateNotifier extends StateNotifier<CursorPaginationBase> {
  final RestaurantRepository repository;

  RestaurantStateNotifier({
    required this.repository,
  }) : super(CursorPaginationLoading()) {
    // Notifier가 호출될 때(ref.read(restaurantProvider)) paginate가 실행되도록
    paginate();
  }

  void paginate({
    int fetchCount = 20,
    // 추가로 데이터 더 가져오기
    // true - 추가로 데이터 더 가져옴
    // false - 새로고침 (현재 상태를 덮어씌움)
    bool fetchModer = false,
    // 강제로 다시 로딩하기
    // true - CursorPaginationLoading()
    bool forceRefetch = false,
  }) async {
    // 5가지 가능성
    // state의 상태만큼 있다.
    // 1) CursorPagination - 정상적으로 데이터가 있는 상태
    // 2) CursorPaginationLoading - 데이터가 로딩중인 상태 (현재 캐시 없음)
    // 3) CursorPaginationError - 에러가 있는 상태
    // 4) CursorPaginationRefetching - 첫 번째 페이지부터 다시 데이터를 가져올 때
    // 5) CursorPaginationFetchMore - 추가 데이터를 paginate해오라는 요청을 받았을 때

    // 바로 반환하는 상황
    // 1) hasMore = false (기존 상태에서 이미 다음 데이터가 없다는 값을 들고 있다면)
    // 2) 로딩중 - fetchMore : true일 때에는 함수 실행 X (가져오는 도중에 다시 요청하면 같은 데이터가 올 수 있다.)
    //    fetchMore : false일 때(새로고침의 의도가 있을 때)
    if (state is CursorPagination && !forceRefetch) {
      // if문을 통과할 경우 CursorPagination일테니
      // state를 CursorPagination으로 고정(만약 state가 CursorPagination이 아니면 에러남.)
      final pState = state as CursorPagination;

      if (!pState.meta.hasMore) {
        return;
      }
    }
  }
}
