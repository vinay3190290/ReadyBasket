import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'cart page.dart';
import 'home page.dart';
import 'main.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key, required Map cartItems});

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  Map<String, List<Map<String, dynamic>>> products = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      print('Fetching products...');
      final response = await http.get(Uri.parse('http://192.168.144.146/readybasket/get_products.php'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('Parsed JSON: $jsonData');
        if (jsonData['success']) {
          Map<String, List<Map<String, dynamic>>> fetchedProducts = {};
          for (var product in jsonData['products']) {
            String category = product['category'] ?? 'Unknown';
            if (!fetchedProducts.containsKey(category)) {
              fetchedProducts[category] = [];
            }
            fetchedProducts[category]!.add({
              'name': product['name'] ?? 'Unknown',
              'price': double.tryParse(product['price']?.toString() ?? '0.0') ?? 0.0,
              'quantity': product['quantity'] ?? 'N/A',
              'old_price': double.tryParse(product['old_price']?.toString() ?? '0.0') ?? 0.0,
              'image': product['image_path'] != null
                  ? 'http://192.168.144.146/readybasket/${product['image_path']}'
                  : 'http://192.168.144.146/readybasket/uploads/default.jpg',
            });
          }
          print('Fetched products: $fetchedProducts');
          setState(() {
            products = fetchedProducts;
            isLoading = false;
          });
        } else {
          throw Exception(jsonData['message']);
        }
      } else {
        throw Exception('Failed to load products: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  final List<Map<String, String>> categories = [
    {"name": "Vegetables", "image": "assets/c_vegetables.png"},
    {"name": "Dairy, Eggs", "image": "assets/dairy.png"},
    {"name": "Rice, Oil and Dal", "image": "assets/rice_oil_dal.png"},
    {"name": "Dry Fruits", "image": "assets/dry_fruits.png"},
    {"name": "Packed Food", "image": "assets/packed_food.png"},
    {"name": "Soap and Shampoo", "image": "assets/soap_shampoo.png"},
    {"name": "Tea & Coffee", "image": "assets/tea_coffee.png"},
    {"name": "Ice Cream", "image": "assets/ice_cream.png"},
    {"name": "Munchies", "image": "assets/munchies.png"},
    {"name": "Sweets & Chocolates", "image": "assets/sweets_chocolates.png"},
    {"name": "Beverages", "image": "assets/cool_drinks.png"},
    {"name": "Cakes", "image": "assets/cakes.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Categories"),
        actions: [
          GestureDetector(
            onTap: () {
              showSearch(
                context: context,
                delegate: ItemSearchDelegate(products),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Image.asset(
                'assets/search.png',
                width: 30,
                height: 30,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                String categoryName = categories[index]['name']!;
                return GestureDetector(
                  onTap: () {
                    List<Map<String, dynamic>> categoryProducts = products[categoryName] ?? [];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroceryScreen(category: categoryName, products: categoryProducts),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.asset(categories[index]['image']!, fit: BoxFit.cover),
                      ),
                      Text(categoryName),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/Categories.png', width: 30, height: 30),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () => _navigateToPage(context, HomePage()),
              child: Image.asset('assets/home.png', width: 30, height: 30),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () => _navigateToPage(context, CartPage(cartItems: {})),
              child: Image.asset('assets/cart.png', width: 30, height: 30),
            ),
            label: 'Cart',
          ),
        ],
        selectedItemColor: Colors.redAccent,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class GroceryScreen extends StatelessWidget {
  final String category;
  final List<Map<String, dynamic>> products;

  GroceryScreen({super.key, required this.category, required this.products});

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartModel>(
      builder: (context, cartModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(category),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () {
                      _navigateToPage(context, CartPage(cartItems: {}));
                    },
                  ),
                  if (cartModel.cartItems.isNotEmpty)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 15,
                          minHeight: 15,
                        ),
                        child: Text(
                          '${cartModel.cartItems.length}',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                var product = products[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Image.network(
                          product["image"],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            print('Image error for ${product['image']}: $error');
                            return Icon(Icons.broken_image, size: 100, color: Colors.grey);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product["name"],
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 1),
                            Text(
                              product["quantity"],
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            SizedBox(height: 0),
                            Row(
                              children: [
                                Text(
                                  "₹${product["price"]}",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "₹${product["old_price"]}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  backgroundColor: Colors.white,
                                  side: BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => cartModel.addToCart(product),
                                child: Text("Add to Cart", style: TextStyle(fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}