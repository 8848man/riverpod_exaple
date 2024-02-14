import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_example1/common/component/pagination_list_view.dart';
import 'package:riverpod_example1/product/component/product_card.dart';
import 'package:riverpod_example1/product/model/product_model.dart';
import 'package:riverpod_example1/product/provider/product_provider.dart';
import 'package:riverpod_example1/restaurant/view/restaurant_detail_screen.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PaginationListView<ProductModel>(
      provider: productProvider,
      itemBuilder: <ProductModel>(_, index, model) {
        return GestureDetector(
          onTap: () {
            context.go('/restaurant/${model.restaurant.id}');
            // context.goNamed(
            // );
          },
          child: ProductCard.fromProductModel(
            model: model,
          ),
        );
      },
    );
  }
}
