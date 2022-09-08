import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shopping_app/Models/Http.exception.dart';

import 'product.dart';

class Products with ChangeNotifier {
  String? token;
  String? uid;
  List<Product> _items = [];
  //  [
  //   // Product(
  //   //   id: 'p1',
  //   //   title: 'Red Shirt',
  //   //   description: 'A red shirt - it is pretty red!',
  //   //   price: 29.99,
  //   //   imageUrl:
  //   //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
  //   // ),
  //   // Product(
  //   //   id: 'p2',
  //   //   title: 'Trousers',
  //   //   description: 'A nice pair of trousers.',
  //   //   price: 59.99,
  //   //   imageUrl:
  //   //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
  //   // ),
  //   // Product(
  //   //   id: 'p3',
  //   //   title: 'Yellow Scarf',
  //   //   description: 'Warm and cozy - exactly what you need for the winter.',
  //   //   price: 19.99,
  //   //   imageUrl:
  //   //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
  //   // ),
  //   // Product(
  //   //   id: 'p4',
  //   //   title: 'A Pan',
  //   //   description: 'Prepare any meal you want.',
  //   //   price: 49.99,
  //   //   imageUrl:
  //   //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
  //   // ),
  // ];

  Products({this.token, this.uid, List<Product>? oldproducts})
      : _items = oldproducts == null ? [] : oldproducts;

  List<Product> get items {
    return [..._items];
  }

  List<Product> get onlyFavorite {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findId(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchandSetProducts([bool byfilter = false]) async {
    String filterString = byfilter ? '&orderBy="creatorId"&equalTo="$uid"' : '';
    try {
      var url = Uri.parse(
          'https://shopping-app-136-default-rtdb.firebaseio.com/products.json?auth=$token$filterString');
      final response = await http.get(url);
      if (response.statusCode >= 400)
        throw HttpException('Cannot fetch products ${response.body}');
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      // print(extractedData);
      List<Product> loadedProducts = [];
      url = Uri.parse(
          'https://shopping-app-136-default-rtdb.firebaseio.com/userFavorites/$uid.json?auth=$token');
      final favResponse = await http.get(url);
      // if(favResponse.statusCode>=400)
      // print('Cannot get favs');
      final favoriteData = json.decode(favResponse.body);
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          imageUrl: prodData['imageUrl'],
          price: prodData['price'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addItems({
    required String id,
    required String title,
    required double price,
    required String description,
    required String imageUrl,
    required bool isfavorite,
  }) async {
    // print('recieved: $id $title $price $imageUrl $description');
    int index = _items.indexWhere((element) => element.id == id);
    if (index == -1) {
      // print('adding new data');
      final url = Uri.parse(
          'https://shopping-app-136-default-rtdb.firebaseio.com/products.json?auth=$token');
      try {
        // print('sending post request');
        final response = await http.post(
          url,
          body: json.encode({
            'title': title,
            'price': price,
            'description': description,
            'imageUrl': imageUrl,
            // 'isFavorite': isfavorite,
            'creatorId': uid,
          }),
        );
        // print('post request success');
        Product p = Product(
          id: json.decode(response.body)['name'],
          title: title,
          description: description,
          imageUrl: imageUrl,
          price: price,
          isFavorite: isfavorite,
        );
        // print('adding item to list');
        _items.add(p);
        notifyListeners();
      } catch (error) {
        // print(error);
        throw error;
      }
    } else {
      try {
        final url = Uri.parse(
            'https://shopping-app-136-default-rtdb.firebaseio.com/products/$id.json?auth=$token');
        await http.patch(url,
            body: json.encode({
              'title': title,
              'price': price,
              'description': description,
              'imageUrl': imageUrl,
            }));
        Product p = Product(
          id: id,
          title: title,
          description: description,
          imageUrl: imageUrl,
          price: price,
          isFavorite: isfavorite,
        );
        _items[index] = p;
        notifyListeners();
      } catch (error) {
        print(error);
        throw error;
      }
    }
  }

  Future<void> removeItem(String id) async {
    final url = Uri.parse(
        'https://shopping-app-136-default-rtdb.firebaseio.com/products/$id.json?auth=$token');
    final indextoDel = _items.indexWhere((element) => element.id == id);
    Product? oldproduct = _items[indextoDel];

    _items.removeAt(indextoDel);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(indextoDel, oldproduct);
      notifyListeners();
      throw HttpException('Could Not delete Product!!');
    }
    oldproduct = null;
  }
}
