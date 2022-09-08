import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/Screens/Edit_product_Screen.dart';
import 'package:shopping_app/Widgets/AppDrawer.dart';

import '../Widgets/UserProductItem.dart';
import '../Provider/Products.dart';

class UserProductScreeen extends StatelessWidget {
  static const String routeName = '/UserProductScreen';

  Future<void> _refreshProducts(BuildContext ctx) async {
    await Provider.of<Products>(ctx, listen: false).fetchandSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final _productData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Own Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                Navigator.of(context).pushNamed(EditProductScreen.routeName),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, state) =>
            state.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<Products>(
                      builder: (ctx, productData, _) => ListView.builder(
                        padding: EdgeInsets.all(10),
                        itemCount: productData.items.length,
                        itemBuilder: (_, index) => UserProductItem(
                          productData.items[index].id,
                          productData.items[index].title,
                          productData.items[index].imageUrl,
                        ),
                      ),
                    ),
                  ),
      ),
      drawer: AppDrawer(),
    );
  }
}
