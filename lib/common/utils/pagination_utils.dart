import 'package:flutter/material.dart';
import 'package:riverpod_example1/common/provider/pagination_provider.dart';

class PaginationUtils {
  static void paginate({
    required ScrollController controller,
    required PaginationProvider provider,
  }) {
    // 현재 위치가
    // 최대 길이보다 조금 덜되는 위치까지 왔다면
    // 새로운 데이터를 추가 요청

    // cotroller.offset - 현재 스크롤 위치
    // controller.position.maxScrollExtent - 스크롤 맨 아래의 위치
    if (controller.offset > controller.position.maxScrollExtent - 300) {
      provider.paginate(
        fetchMore: true,
      );
    }
  }
}
