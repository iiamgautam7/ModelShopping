import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../Provider/product.dart';
import '../Provider/Products.dart';

class EditProductScreen extends StatefulWidget {
  static const String routeName = '/EditProducts';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _pricefocus = FocusNode();
  final _decrtfocus = FocusNode();
  final _imagsfocus = FocusNode();
  final _imageController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var addnew = NewProduct();
  var run1 = true;
  var isLoading = false;

  @override
  void didChangeDependencies() {
    if (run1) {
      if (ModalRoute.of(context) != null) {
        Object? isID = ModalRoute.of(context)!.settings.arguments;
        if (isID != null) {
          String id = isID as String;
          Product toEdit = Provider.of<Products>(context).findId(id);
          addnew.id = toEdit.id;
          addnew.title = toEdit.title;
          addnew.price = toEdit.price;
          addnew.description = toEdit.description;
          addnew.url = toEdit.imageUrl;
          addnew.favorite = toEdit.isFavorite;
          _imageController.text = toEdit.imageUrl;
          // print('${addnew.title} ${addnew.price} ${addnew.url} ${addnew.url}');
        }
      }
      run1 = false;
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _imagsfocus.addListener(_updateimageUrl);
    super.initState();
  }

  void _updateimageUrl() {
    if (!_imageController.text.startsWith('http') &&
        !_imageController.text.startsWith('https')) return;
    if (!_imagsfocus.hasFocus) setState(() {});
  }

  @override
  void dispose() {
    _imagsfocus.removeListener(_updateimageUrl);
    _pricefocus.dispose();
    _decrtfocus.dispose();
    _imagsfocus.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_form.currentState!.validate()) {
      _form.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    final _productData = Provider.of<Products>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit your Products'),
        actions: [
          IconButton(
            onPressed: () async {
              _saveForm();
              // print('Form saved. Loading shown');
              setState(() {
                isLoading = true;
              });
              try {
                // print('adding data');
                // print('${addnew.title} ,${addnew.price}, ${addnew.url}, ${addnew.url}, now sending this');
                await _productData.addItems(
                  id: addnew.id != '' ? addnew.id : '',
                  title: addnew.title,
                  price: addnew.price,
                  description: addnew.description,
                  imageUrl: addnew.url,
                  isfavorite: addnew.favorite,
                );
                // print('Data added');
              } catch (error) {
                // print('Error Occured');
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    content: Text('Oops!! Something went wrong...'),
                    actions: [
                      TextButton(
                        child: Text('Okay'),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                );
              } finally {
                // print('done adding with success. now changing screen.');
                setState(() {
                  isLoading = false;
                });
                Navigator.of(context).pop();
              }
            },
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _form,
                autovalidateMode: AutovalidateMode.always,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Title'),
                      initialValue: addnew.title,
                      textInputAction: TextInputAction.next,
                      autofocus: true,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_pricefocus);
                      },
                      validator: (value) {
                        if (value!.isEmpty)
                          return "Please provide a valid Input.";
                        return null;
                      },
                      onSaved: (value) {
                        addnew.title = value!;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Price'),
                      initialValue: '${addnew.price}',
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _pricefocus,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_decrtfocus);
                      },
                      validator: (value) {
                        if (value!.isEmpty || double.tryParse(value) == null)
                          return "Please provide a valid price.";
                        if (double.parse(value) < 0)
                          return 'Please enter a number greater than zero';
                        return null;
                      },
                      onSaved: (value) {
                        addnew.price = double.parse(value!);
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Description'),
                      initialValue: addnew.description,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _decrtfocus,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_decrtfocus);
                      },
                      validator: (value) {
                        if (value!.isEmpty)
                          return 'Please enter a description.';
                        if (value.length < 10)
                          return 'Please enter a longer description';
                        return null;
                      },
                      onSaved: (value) {
                        addnew.description = value!;
                      },
                    ),
                    Row(
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: _imageController.text.isEmpty
                              ? Center(
                                  child: Text('Enter your Image'),
                                )
                              : FittedBox(
                                  child: Image.network(_imageController.text),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageController,
                            focusNode: _imagsfocus,
                            onSaved: (value) {
                              addnew.url = value!;
                            },
                            validator: (value) {
                              if (value!.isEmpty)
                                return "Please enter product image URL";
                              if (!value.startsWith('http') &&
                                  !!value.startsWith('https'))
                                return "Please enter a valid url";
                              return null;
                            },
                            onFieldSubmitted: (_) async {
                              _saveForm();
                              // print('Form saved. Loading shown');
                              setState(() {
                                isLoading = true;
                              });
                              try {
                                // print('adding data');
                                await _productData.addItems(
                                  id: addnew.id != '' ? addnew.id : '',
                                  title: addnew.title,
                                  price: addnew.price,
                                  description: addnew.description,
                                  imageUrl: addnew.url,
                                  isfavorite: addnew.favorite,
                                );
                                // print('Data added');
                              } catch (error) {
                                // print('Error Occured');
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    content:
                                        Text('Oops!! Something went wrong...'),
                                    actions: [
                                      TextButton(
                                        child: Text('Okay'),
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(),
                                      ),
                                    ],
                                  ),
                                );
                              } finally {
                                // print('done adding with success. now changing screen.');
                                setState(() {
                                  isLoading = false;
                                });
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}

class NewProduct {
  String id = '';
  String title = '';
  double price = 0.0;
  String description = '';
  String url = '';
  bool favorite = false;
  NewProduct() {
    this.title = '';
    this.price = 0;
    this.description = '';
    this.url = '';
  }
}
