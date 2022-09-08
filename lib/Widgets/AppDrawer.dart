import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/Provider/Auth.dart';

import '../Screens/product_overview_Screen.dart';
import '../Screens/OrdersScreen.dart';
import '../Screens/UserProductsScreen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DrawerHeader(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.top),
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [Colors.purple, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )),
            child: Center(
              child: Text(
                'Let\'s Go Shopping!!',
                style: TextStyle(
                  fontSize: 30,
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text(
              'Shop',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            onTap: () => Navigator.pushReplacementNamed(
                context, ProductsOverView.routeName),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text(
              'Your Orders',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            onTap: () =>
                Navigator.pushReplacementNamed(context, OrderScreen.routeName),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person_add),
            title: Text(
              'Your Products',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            onTap: () => Navigator.pushReplacementNamed(
                context, UserProductScreeen.routeName),
          ),
          Divider(),
          Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: ListTile(
              tileColor: Theme.of(context).primaryColor,
              hoverColor: Theme.of(context).accentColor,
              shape: StadiumBorder(),
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/');
                Provider.of<Auth>(context, listen: false).logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}
