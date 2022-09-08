import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_app/Models/Http.exception.dart';
import '../Provider/Cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime datetime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.datetime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String? authToken;
  final String? userId;

  Orders(this._orders, {this.authToken, this.userId});

  UnmodifiableListView<OrderItem> get orders {
    return UnmodifiableListView<OrderItem>(_orders);
  }

  Future<void> fetchandSetOrders() async {
    final url = Uri.parse(
        'https://shopping-app-136-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final response = await http.get(url);
    // print(response.statusCode);
    if (response.statusCode >= 400) {
      print(json.decode(response.body));
      throw HttpException('Cannot get Orders');
    }
    final extractedData = json.decode(response.body);
    // print(extractedData);
    if (extractedData == null) {
      _orders = [];
      return;
    }
    final List<OrderItem> loadedorders = [];
    if (extractedData.isEmpty) return;
    extractedData.forEach((orderId, orderdata) {
      loadedorders.add(OrderItem(
        id: orderId,
        amount: orderdata['amount'],
        datetime: DateTime.parse(orderdata['datetime']),
        products: (orderdata['products'] as List<dynamic>)
            .map((item) => CartItem(
                  id: item['id'],
                  title: item['title'],
                  quantity: item['quantity'],
                  price: item['price'],
                ))
            .toList(),
      ));
    });
    _orders = loadedorders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final timeStamp = DateTime.now();
    final url = Uri.parse(
        'https://shopping-app-136-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final response = await http.post(
      url,
      body: json.encode({
        'amount': total,
        'datetime': timeStamp.toIso8601String(),
        'products': cartProducts
            .map((e) => {
                  'id': e.id,
                  'title': e.title,
                  'quantity': e.quantity,
                  'price': e.price,
                })
            .toList(),
      }),
    );
    if (response.statusCode >= 400 ||
        json.decode(response.body)['error'] != null) {
      throw HttpException("Error in adding orders");
    }
    // print(json.decode(response.body));
    _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          products: cartProducts,
          datetime: timeStamp,
        ));
    notifyListeners();
  }
}
