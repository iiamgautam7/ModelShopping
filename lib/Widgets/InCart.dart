import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/Cart.dart';

class InCart extends StatelessWidget {
  final CartItem product;
  final String id;
  InCart(this.product, this.id);
  @override
  Widget build(BuildContext context) {
    final myCart = Provider.of<Cart>(context, listen: false);
    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).errorColor,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(
          Icons.delete,
          color: Colors.white70,
          size: 40,
        ),
      ),
      onDismissed: (_) => myCart.removeItem(id),
      confirmDismiss: (_) => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Are you sure?'),
          content:
              Text('Do you really want to remove this item from your cart?'),
          actions: [
            TextButton(
              child: Text('Yes'),
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
            TextButton(
              child: Text('No'),
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
          ],
        ),
      ),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: FittedBox(child: Text('₹${product.price}')),
              ),
            ),
            title: Text(product.title),
            subtitle: Text('₹${product.price * product.quantity}'),
            trailing: Text('${product.quantity} x'),
          ),
        ),
      ),
    );
  }
}
