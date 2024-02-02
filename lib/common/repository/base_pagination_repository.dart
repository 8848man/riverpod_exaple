import 'package:riverpod_example1/common/model/cursor_pagination_model.dart';
import 'package:riverpod_example1/common/model/model_with_id.dart';
import 'package:riverpod_example1/common/model/pagination_params.dart';
import 'package:riverpod_example1/restaurant/model/restaurant_model.dart';

abstract class IBasePaginationRepository<T extends IModelWithId> {
  Future<CursorPagination<T>> paginate({
    // @Queries는 레트로핏에서 지원하는 패러미터 전달자(?)인듯
    PaginationParams? paginationParams = const PaginationParams(),
  });
}
