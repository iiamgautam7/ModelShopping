import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/Badge.dart';
import '../Provider/Cart.dart';
import '../Provider/Products.dart';
import '../Widgets/AppDrawer.dart';
import '../Screens/CartScreen.dart';
import '../Widgets/Prodect_grid.dart';

enum filterOptions {
  showFavorites,
  showAll,
}

class ProductsOverView extends StatefulWidget {
  static const String routeName = '/ProductsOverview';
  const ProductsOverView({Key? key}) : super(key: key);

  @override
  _ProductsOverViewState createState() => _ProductsOverViewState();
}

class _ProductsOverViewState extends State<ProductsOverView> {
  bool _ifFavfs = false;
  bool _oneTime = true;
  bool _isLoading = false;
  Future<void> _refreshProducts(BuildContext ctx) async {
    await Provider.of<Products>(ctx, listen: false).fetchandSetProducts();
  }

  @override
  void didChangeDependencies() {
    if (_oneTime) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchandSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
      _oneTime = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Shop'),
        actions: [
          PopupMenuButton(
            onSelected: (filterOptions select) {
              setState(() {
                _ifFavfs =
                    (select == filterOptions.showFavorites) ? true : false;
              });
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: filterOptions.showFavorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: filterOptions.showAll,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (ctx, cartData, ch) => Badge(
              value: '${cartData.size}',
              child: ch!,
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () =>
                  Navigator.of(context).pushNamed(CartScreen.nameRoute),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _refreshProducts(context);
        },
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ProductGrid(_ifFavfs),
      ),
      drawer: AppDrawer(),
    );
  }
}
