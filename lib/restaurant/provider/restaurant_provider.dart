import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_example1/common/model/cursor_pagination_model.dart';
import 'package:riverpod_example1/common/model/pagination_params.dart';
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

class RestaurantStateNotifier extends StateNotifier<CursorPaginationBase> {
  final RestaurantRepository repository;

  RestaurantStateNotifier({
    required this.repository,
  }) : super(CursorPaginationLoading()) {
    // Notifier가 호출될 때(ref.read(restaurantProvider)) paginate가 실행되도록
    paginate();
  }

  Future<void> paginate({
    int fetchCount = 20,
    // 추가로 데이터 더 가져오기
    // true - 추가로 데이터 더 가져옴
    // false - 새로고침 (현재 상태를 덮어씌움)
    bool fetchMore = false,
    // 강제로 다시 로딩하기
    // true - CursorPaginationLoading()
    bool forceRefetch = false,
  }) async {
    try {
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
      print(state);
      if (state is CursorPagination && !forceRefetch) {
        // if문을 통과할 경우 CursorPagination일테니
        // state를 CursorPagination으로 고정(만약 state가 CursorPagination이 아니면 에러남.)
        final pState = state as CursorPagination;

        //
        if (!pState.meta.hasMore) {
          return;
        }
      }

      final isLoading = state is CursorPaginationLoading;
      final isRefetching = state is CursorPaginationRefetchig;
      final isFetechingMore = state is CursorPaginationFetchingMore;

      // 2번 반환 상황
      if (fetchMore && (isLoading || isRefetching || isFetechingMore)) {
        return;
      }

      // PaginationParams 생성
      PaginationParams paginationParams = PaginationParams(
        count: fetchCount,
      );

      if (fetchMore) {
        final pState = state as CursorPagination;

        state = CursorPaginationFetchingMore(
          meta: pState.meta,
          data: pState.data,
        );

        paginationParams = paginationParams.copyWith(
          after: pState.data.last.id,
        );
      }
      // 데이터를 처음부터 가져오는 상황
      else {
        // 만약에 데이터가 있는 상황이라면
        // 기존 데이터를 보존한 채로 Fetch (API요청)를 진행
        if (state is CursorPagination && !forceRefetch) {
          final pState = state as CursorPagination;

          state = CursorPaginationRefetchig(
            meta: pState.meta,
            data: pState.data,
          );
        }
        // 나머지 상황
        else {
          state = CursorPaginationLoading();
        }
      }

      final resp = await repository.paginate(
        paginationParams: paginationParams,
      );

      if (state is CursorPaginationFetchingMore) {
        final pState = state as CursorPaginationFetchingMore;

        // 기존 데이터에
        // 새로운 데이터 추가
        state = resp.copyWith(
          data: [
            ...pState.data,
            ...resp.data,
          ],
        );
      } else {
        state = resp;
      }
    } catch (e) {
      state = CursorPaginationError(message: '데이터를 가져오지 못했습니다.');
    }
  }

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
