import 'package:flutter/widgets.dart';
import 'package:riverpod_example1/common/component/pagination_list_view.dart';
import 'package:riverpod_example1/product/component/product_card.dart';
import 'package:riverpod_example1/product/model/product_model.dart';
import 'package:riverpod_example1/product/provider/product_provider.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PaginationListView<ProductModel>(
      provider: productProvider,
      itemBuilder: <ProductModel>(_, index, model) {
        return ProductCard.fromProductModel(
          model: model,
        );
      },
    );
  }
}
