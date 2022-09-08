import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/Cart.dart';
import '../Provider/product.dart';
import '../Provider/Auth.dart';
import '../Screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  final VoidCallback _reloadScreen;
  ProductItem(this._reloadScreen);

  @override
  Widget build(BuildContext context) {
    final _productData = Provider.of<Product>(context, listen: false);
    final _authdata = Provider.of<Auth>(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => ProductDetail(_productData.id),
              ),
            );
          },
          child: Image.network(
            _productData.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          title: Text(_productData.title),
          backgroundColor: Colors.black45,
          leading: Consumer<Product>(
            builder: (ctx, _productData, _) => IconButton(
              icon: _productData.isFavorite
                  ? Icon(Icons.favorite)
                  : Icon(Icons.favorite_border),
              onPressed: () async {
                try {
                  await _productData.toggleFavorites(
                      _authdata.token!, _authdata.userId!);
                  _reloadScreen();
                } catch (_) {
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'An error Occured!! Favorite cannot be changed',
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          trailing: Consumer<Cart>(
            builder: (ctx, _cartData, _) => IconButton(
              icon: _cartData.items.containsKey(_productData.id)
                  ? Icon(Icons.shopping_cart)
                  : Icon(Icons.shopping_cart_outlined),
              onPressed: () {
                _cartData.addItem(
                    _productData.id, _productData.price, _productData.title);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added item in the Cart'),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () =>
                          _cartData.removeSingleItem(_productData.id),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
