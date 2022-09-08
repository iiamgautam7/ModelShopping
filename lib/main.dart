import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Screens/splash_screen.dart';
import '../Screens/auth_screen.dart';
import '../Screens/Edit_product_Screen.dart';
import '../Screens/CartScreen.dart';
import '../Screens/OrdersScreen.dart';
import '../Screens/product_overview_Screen.dart';
import '../Screens/UserProductsScreen.dart';

import '../Provider/Products.dart';
import '../Provider/Cart.dart';
import '../Provider/Orders.dart';
import '../Provider/Auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (ctx) => Products(),
          update: (ctx, authData, oldProducts) => Products(
            oldproducts: oldProducts == null ? [] : oldProducts.items,
            token: authData.token,
            uid: authData.userId,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => Orders([]),
          update: (ctx, authData, previosOrders) => Orders(
            previosOrders == null ? [] : previosOrders.orders,
            authToken: authData.token,
            userId: authData.userId,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Cart>(
          create: (ctx) => Cart({}),
          update: (ctx, authdata, preoviosCart) => Cart(
            preoviosCart == null ? {} : preoviosCart.items,
            token: authdata.token,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, authData, _) => MaterialApp(
          title: 'My Shop',
          theme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.deepPurple,
            primaryColor: Colors.deepPurple[400],
            accentColor: Colors.deepOrangeAccent,
            dividerColor: Colors.black12,
            textTheme: TextTheme(
              headline6: TextStyle(
                fontFamily: 'Anton',
              ),
            ),
          ),
          themeMode: ThemeMode.dark,
          home: authData.isAuth
              ? ProductsOverView()
              : FutureBuilder(
                  future: authData.tryAutologin(),
                  builder: (ctx, snapshot) =>
                      (snapshot.connectionState == ConnectionState.waiting)
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductsOverView.routeName: (ctx) => ProductsOverView(),
            CartScreen.nameRoute: (ctx) => CartScreen(),
            OrderScreen.routeName: (ctx) => OrderScreen(),
            UserProductScreeen.routeName: (ctx) => UserProductScreeen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}

// class MyHomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Your Shop'),
//       ),
//       body: Center(
//         child: Text('Happy Shopping'),
//       ),
//     );
//   }
// }
