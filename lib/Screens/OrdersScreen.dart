import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/Orders.dart';
import '../Widgets/AppDrawer.dart';
import '../Widgets/InOrder.dart';

class OrderScreen extends StatelessWidget {
  static const String routeName = '/OrderScreen';

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<Orders>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: orderProvider.fetchandSetOrders(),
        builder: (ctx, orderData) {
          if (orderData.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (orderData.hasError) {
              return Center(
                child: Text(
                    'An error in fetching orders(in orders SCreen)...${orderData.error}'),
              );
            } else {
              return orderProvider.orders.isNotEmpty
                  ? ListView.builder(
                      itemCount: orderProvider.orders.length,
                      itemBuilder: (ctx, index) {
                        return InOrder(orderProvider.orders[index]);
                      })
                  : Center(
                      child: Image.asset(
                        'assets/images/EmptyOrder.jpg',
                        fit: BoxFit.contain,
                      ),
                    );
            }
          }
        },
      ),
    );
  }
}
