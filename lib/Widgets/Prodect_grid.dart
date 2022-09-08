import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/Products.dart';
import '../../Widgets/product_item.dart';

class ProductGrid extends StatefulWidget {
  final bool onlyFav;
  ProductGrid(this.onlyFav);

  @override
  _ProductGridState createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  void _reload() {
    if (widget.onlyFav)
      setState(() {
        //reload
      });
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context, listen: false);
    final _loadedProducts =
        widget.onlyFav ? productsData.onlyFavorite : productsData.items;
    // print(_loadedProducts.length);
    return GridView.builder(
      padding: EdgeInsets.all(10),
      itemCount: _loadedProducts.length,
      itemBuilder: (ctx, index) {
        return ChangeNotifierProvider.value(
          value: _loadedProducts[index],
          child: ProductItem(_reload),
        );
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
