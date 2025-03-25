import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ready_basket1/payment%20page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key, required Map<Map<String, dynamic>, int> cartItems});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartModel>(
      builder: (context, cartModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Your Cart"),
            backgroundColor: Colors.redAccent,
          ),
          body: cartModel.cartItems.isEmpty
              ? Center(child: Text("Your cart is empty", style: TextStyle(fontSize: 18)))
              : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: cartModel.cartItems.length,
                  itemBuilder: (context, index) {
                    var product = cartModel.cartItems.keys.elementAt(index);
                    int quantity = cartModel.cartItems[product]!;
                    print('Cart item: $product, Quantity: $quantity');
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Image.network(
                              product['image'] ?? 'http://192.168.144.146/readybasket/uploads/default.jpg',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('Image error for ${product['image']}: $error');
                                return Icon(Icons.broken_image, size: 80, color: Colors.grey);
                              },
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'] ?? 'Unknown',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    product['quantity'] ?? 'N/A',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "₹${product['price'] ?? 0.0}",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove, color: Colors.red),
                                  onPressed: () {
                                    cartModel.updateQuantity(product, quantity - 1);
                                  },
                                ),
                                Text(
                                  '$quantity',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add, color: Colors.red),
                                  onPressed: () {
                                    cartModel.updateQuantity(product, quantity + 1);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ₹${cartModel.getTotalCost().toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentPage(total: cartModel.getTotalCost()),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      ),
                      child: Text(
                        'Pay ₹${cartModel.getTotalCost().toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CartModel extends ChangeNotifier {
  Map<Map<String, dynamic>, int> cartItems = {};

  void addToCart(Map<String, dynamic> product) {
    String name = product['name'] ?? 'Unknown';
    print("Adding to cart: $product");
    cartItems[product] = (cartItems[product] ?? 0) + 1;
    print("Added ${product['name']} to cart. Cart now: $cartItems");
    notifyListeners();
  }

  void updateQuantity(Map<String, dynamic> product, int newQuantity) {
    if (newQuantity <= 0) {
      cartItems.remove(product);
    } else {
      cartItems[product] = newQuantity;
    }
    notifyListeners();
  }

  double getTotalCost() {
    double total = 0;
    cartItems.forEach((product, quantity) {
      total += product['price'] * quantity;
    });
    return total;
  }

  void clearCart() {
    cartItems.clear();
    notifyListeners();
  }
}