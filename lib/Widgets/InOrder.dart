import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../Provider/Orders.dart';

class InOrder extends StatefulWidget {
  final OrderItem order;
  InOrder(this.order);

  @override
  _InOrderState createState() => _InOrderState();
}

class _InOrderState extends State<InOrder> {
  var _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.deepPurple[100],
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text('Ordered a total of: ₹${widget.order.amount}'),
              subtitle: Text('On: '+
                  DateFormat('dd MM yyyy hh:mm').format(widget.order.datetime)),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            if (_expanded)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15,vertical: 4),
                height: min(widget.order.products.length * 20.0 + 20, 100),
                child: ListView(
                  children: widget.order.products
                      .map((prod) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                prod.title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${prod.quantity} x ₹${prod.price}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[850],
                                ),
                              ),
                            ],
                          ))
                      .toList(),
                ),
              ),
          ],
        ));
  }
}
