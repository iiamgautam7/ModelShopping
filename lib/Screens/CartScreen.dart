import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/Orders.dart';
import '../Widgets/InCart.dart';
import '../Provider/Cart.dart';

class CartScreen extends StatelessWidget {
  static const String nameRoute = '/CartScreen';
  @override
  Widget build(BuildContext context) {
    final myCart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(10),
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount ',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '${myCart.totalAmt}',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(myCart: myCart)
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: myCart.size,
              itemBuilder: (ctx, i) => InCart(
                myCart.items.values.toList()[i],
                myCart.items.keys.toList()[i],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.myCart,
  }) : super(key: key);

  final Cart myCart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
        child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW'),
        onPressed: (widget.myCart.items.isEmpty || _isLoading)
            ? null
            : () async {
                setState(() {
                  _isLoading = true;
                });
                try {
                  await Provider.of<Orders>(context, listen: false).addOrder(
                    widget.myCart.items.values.toList(),
                    widget.myCart.totalAmt,
                  );
                } catch (error) {
                  print('In cartScreen: ordering...    $error');
                } finally {
                  // print('done');
                  setState(() {
                    _isLoading = false;
                  });
                }
                widget.myCart.clear();
              });
  }
}
// () => FutureBuilder(
//               future: 
//                       builder: (ctx,orderData) {
//                         if(orderData.connectionState==ConnectionState.waiting)
                        
//                       },
//                       )