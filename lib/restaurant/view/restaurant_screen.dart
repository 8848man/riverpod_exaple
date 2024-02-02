import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_example1/common/component/pagination_list_view.dart';
import 'package:riverpod_example1/restaurant/component/restaurant_card.dart';
import 'package:riverpod_example1/restaurant/provider/restaurant_provider.dart';
import 'package:riverpod_example1/restaurant/view/restaurant_detail_screen.dart';

class RestaurantScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PaginationListView(
      provider: restaurantProvider,
      itemBuilder: <RestaurantModel>(_, index, model) {
        return GestureDetector(
          child: RestaurantCard.fromModel(
            model: model,
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RestaurantDetailScreen(
                  id: model.id,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
