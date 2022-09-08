import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/Cart.dart';
import '../Provider/Products.dart';

class ProductDetail extends StatelessWidget {
  final id;
  ProductDetail(this.id);

  @override
  Widget build(BuildContext context) {
    final item = Provider.of<Products>(context, listen: false).findId(id);
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '₹${item.price}',
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            SizedBox(height: 20),
            Text(
              item.description,
              style: TextStyle(
                fontSize: 20,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Consumer<Cart>(
        builder: (ctx, cart, ch) => FloatingActionButton(
          child: Icon(Icons.shopping_cart),
          onPressed: () => cart.addItem(id, item.price, item.title),
        ),
      ),
    );
  }
}
