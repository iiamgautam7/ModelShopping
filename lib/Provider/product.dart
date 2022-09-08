import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Models/Http.exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.isFavorite = false,
  });

  Future<void> toggleFavorites(String token, String uid) async {
    final oldStatus = isFavorite;
    final url = Uri.parse(
        'https://shopping-app-136-default-rtdb.firebaseio.com/userFavorites/$uid/$id.json?auth=$token');
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final response = await http.put(
        url,
        body: json.encode(isFavorite),
      );
      if (response.statusCode >= 400) {
        isFavorite = oldStatus;
        notifyListeners();
        throw HttpException('Cannot toggle Favorites');
      }
    } catch (error) {
      isFavorite = oldStatus;
      notifyListeners();
      print('An error occured /n $error');
      throw HttpException('Cannot toggle Favorites');
    }
  }
}
