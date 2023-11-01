import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'cart.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        initialRoute: '/',
        debugShowCheckedModeBanner: false, // Remove the debug banner
        routes: {
          '/': (context) => ProductListPage(),
          '/cart': (context) => CartPage(),
        },
      ),
    );
  }
}


class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String image;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.image,
  });
}

class CartProvider with ChangeNotifier {
  List<Product> _cartItems = [];
  List<Product> get cartItems => _cartItems;

  double get cartTotal => _cartItems.fold(0.0, (total, product) => total + product.price);

  void addToCart(Product product) {
    _cartItems.add(product);
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _cartItems.remove(product);
    notifyListeners();
  }
}

class ProductService {
  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Product> products = data.map((item) => Product(
        id: item['id'],
        title: item['title'],
        price: item['price'].toDouble(),
        description: item['description'],
        image: item['image'],
      )).toList();

      return products;
    } else {
      throw Exception('Failed to load products');
    }
  }
}

class Cart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        home: ProductListPage(),
      ),
    );
  }
}

class ProductListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('E-commerce Store'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).pushNamed('/cart');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: ProductService.fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          } else {
            List<Product> products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(products[index].title),
                  subtitle: Text('\$${products[index].price.toStringAsFixed(2)}'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ProductDetailPage(product: products[index]),
                    ));
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}


class ProductDetailPage extends StatelessWidget {
  final Product product;

  ProductDetailPage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Detail'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(product.image),
            Text(product.title),
            Text('\$${product.price.toStringAsFixed(2)}'),
            Text(product.description),
            ElevatedButton(
              onPressed: () {
                context.read<CartProvider>().addToCart(product);
              },
              child: Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}

