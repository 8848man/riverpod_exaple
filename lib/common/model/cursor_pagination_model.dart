import 'package:json_annotation/json_annotation.dart';
import 'package:riverpod_example1/restaurant/model/restaurant_model.dart';

part 'cursor_pagination_model.g.dart';

// Error, Loading, Success 모든 상태를 받아올 수 있도록 하는 추상클래스
abstract class CursorPaginationBase {}

// 페이지네이션에서
// Error가 발생했을 때
class CursorPaginationError extends CursorPaginationBase {
  final String message;

  CursorPaginationError({required this.message});
}

// data is CursorPaginationLoading == true (로딩중인지)를 체크하기 위해 만드는 로직
class CursorPaginationLoading extends CursorPaginationBase {}

//
@JsonSerializable(
  genericArgumentFactories: true,
)
class CursorPagination<T> extends CursorPaginationBase {
  final CursorPaginationMeta meta;
  final List<T> data;

  CursorPagination({required this.meta, required this.data});

  factory CursorPagination.fromJson(
          Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$CursorPaginationFromJson(json, fromJsonT);
}

@JsonSerializable()
class CursorPaginationMeta {
  final int count;
  final bool hasMore;

  CursorPaginationMeta({
    required this.count,
    required this.hasMore,
  });

  factory CursorPaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$CursorPaginationMetaFromJson(json);
}

// 새로고침할 때
class CursorPaginationRefetchig<T> extends CursorPagination<T> {
  CursorPaginationRefetchig({required super.meta, required super.data});
}

// 리스트의 맨 아래로 내려서
// 추가 데이터를 요청하는 중일 때
class CursorPaginationFetchingMore<T> extends CursorPagination<T> {
  CursorPaginationFetchingMore({required super.meta, required super.data});
}
