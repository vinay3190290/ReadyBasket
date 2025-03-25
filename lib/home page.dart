import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:ready_basket1/setting%20page.dart';
import 'cart page.dart';
import 'category page.dart';
import 'main.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, List<Map<String, dynamic>>> products = {};
  bool isLoading = true;
  String selectedCategory = 'Vegetables';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
            if (products.isNotEmpty && !products.containsKey(selectedCategory)) {
              selectedCategory = products.keys.first;
            }
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

  void _addToCart(Map<String, dynamic> product) {
    print('Adding to cart: $product');
    try {
      Provider.of<CartModel>(context, listen: false).addToCart(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product['name']} added to cart!')),
      );
    } catch (e) {
      print('Add to cart error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to cart: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, userModel, child) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text("Ready Basket"),
            backgroundColor: Colors.redAccent,
            leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.person),
                onPressed: () {
                  _navigateToPage(context, ProfilePage());
                },
              ),
              Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () {
                      _navigateToPage(context, CartPage(cartItems: {}));
                    },
                  ),
                  if (Provider.of<CartModel>(context).cartItems.isNotEmpty)
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
                          '${Provider.of<CartModel>(context).cartItems.length}',
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
          drawer: Drawer(
            child: Column(
              children: [
                DrawerHeader(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello! ",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userModel.name,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        leading: Icon(Icons.home),
                        title: Text('Home'),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.category),
                        title: Text('Categories'),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToPage(context, CategoriesPage(cartItems: {}));
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text('Profile'),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToPage(context, ProfilePage());
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.settings),
                        title: Text('Settings'),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToPage(context, SettingsPage());
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.shopping_cart),
                        title: Text('Cart'),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToPage(context, CartPage(cartItems: {}));
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.store),
                        title: Text('Vendor Login'),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToPage(context, VendorLoginPage());
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () {
                      Provider.of<UserModel>(context, listen: false).setProfile("Guest", "", "");
                      Provider.of<CartModel>(context, listen: false).clearCart();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Text(
                        "Log out",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontFamily: "CustomFont",
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // New search bar and text
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "Choose the \n               item you love",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: GestureDetector(
                  onTap: () {
                    showSearch(
                      context: context,
                      delegate: ItemSearchDelegate(products),
                    );
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: TextField(
                              enabled: false, // Disable typing to trigger onTap only
                              decoration: InputDecoration(
                                hintText: 'Search for..',
                                hintStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'IrishGrover',
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(6),
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Image.asset(
                              'assets/search.png',
                              width: 40,
                              height: 40,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Existing category selection and grid
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: products.keys.map((category) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      child: Container(
                        width: 100,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: selectedCategory == category ? Colors.red : Colors.black),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/${category.toLowerCase().replaceAll(" & ", "_").replaceAll(" ", "_")}.png',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.broken_image, size: 60, color: Colors.grey);
                              },
                            ),
                            SizedBox(height: 5),
                            Text(category, style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: products[selectedCategory]?.length ?? 0,
                  itemBuilder: (context, index) {
                    var product = products[selectedCategory]![index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Image.network(
                              product['image'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('Image error for ${product['image']}: $error');
                                return Icon(Icons.broken_image, size: 60, color: Colors.grey);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'],
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 1),
                                Text(
                                  product['quantity'],
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                SizedBox(height: 0),
                                Row(
                                  children: [
                                    Text(
                                      "₹${product['price']}",
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "₹${product['old_price']}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: ElevatedButton(
                              onPressed: () => _addToCart(product),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                minimumSize: Size(double.infinity, 36),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Add',
                                style: TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ),
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
                icon: Image.asset('assets/home.png', width: 30, height: 30),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () => _navigateToPage(context, CategoriesPage(cartItems: {})),
                  child: Image.asset('assets/Categories.png', width: 30, height: 30),
                ),
                label: 'Categories',
              ),
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () => _navigateToPage(context, SettingsPage()),
                  child: Image.asset('assets/settings.png', width: 30, height: 30),
                ),
                label: 'Settings',
              ),
            ],
            selectedItemColor: Colors.redAccent,
            type: BottomNavigationBarType.fixed,
          ),
        );
      },
    );
  }
}