import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cartItems = cartProvider.cartItems;

    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
      ),
      body: cartItems.isEmpty
          ? Center(child: Text('Your cart is empty.'))
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final product = cartItems[index];
                return ListTile(
                  title: Text(product.title),
                  subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      context.read<CartProvider>().removeFromCart(product);
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: ListTile(
        title: Text('Total: \$${cartProvider.cartTotal.toStringAsFixed(2)}'),
        trailing: ElevatedButton(
          onPressed: () {
            // Implement the checkout logic here
          },
          child: Text('Checkout'),
        ),
      ),
    );
  }
}

