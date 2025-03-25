import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ready_basket1/setting%20page.dart';
import 'package:ready_basket1/vendor%20page.dart';
import 'dart:async';
import 'cart page.dart';
import 'package:provider/provider.dart';
import 'home page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => UserModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigateToHome();
  }

  void navigateToHome() async {
    // Navigate to HomePage after 1 second
    Timer(Duration(seconds: 1), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFF0004),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            top: 340,
            child: Container(
              width: 360,
              height: 571,
              child: Image.asset(
                'assets/shopping_girl.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            left: 11,
            top: 150,
            child: SizedBox(
              width: 422,
              height: 213,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    "Ready       \n          Basket          ",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IrishGrover',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 70,
            top: 335,
            child: SizedBox(
              width: 200,
              height: 80,
              child: Text(
                'grab your loved item',
                style: TextStyle(
                  color: Color(0xFF121010),
                  fontSize: 20,
                  fontFamily: 'Irish Grover',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class VendorLoginPage extends StatefulWidget {
  @override
  _VendorLoginPageState createState() => _VendorLoginPageState();
}

class _VendorLoginPageState extends State<VendorLoginPage> {
  TextEditingController mobileController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  // Hardcoded credentials for vendor login
  final String defaultMobile = "7995889915";
  final String defaultPassword = "12345";

  Future<void> loginVendor() async {
    if (mobileController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        errorMessage = "Please fill in all fields";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Simulate a network delay for a better user experience
      await Future.delayed(Duration(seconds: 1));

      // Check if the entered credentials match the hardcoded ones
      if (mobileController.text == defaultMobile && passwordController.text == defaultPassword) {
        // Credentials are correct, navigate to VendorHomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VendorHomePage()),
        );
      } else {
        // Credentials are incorrect, show an error message
        setState(() {
          errorMessage = "Invalid mobile number or password";
        });
      }
    } catch (e) {
      print('Error during vendor login: $e');
      setState(() {
        errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F6FF),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.8,
              child: Image.asset('assets/girl_on_cart.png', fit: BoxFit.cover),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: 315,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                        child: Text(
                          "Vendor Login",
                          style: TextStyle(
                            fontSize: 25,
                            fontFamily: 'IrishGrover',
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      if (errorMessage != null)
                        Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Text(
                            errorMessage!,
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: mobileController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "Enter your mobile number",
                            hintStyle: TextStyle(fontFamily: 'IrishGrover'),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(Icons.phone),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "Enter Password",
                            hintStyle: TextStyle(fontFamily: 'IrishGrover'),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: Icon(Icons.visibility),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      GestureDetector(
                        onTap: isLoading ? null : loginVendor,
                        child: Container(
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'IrishGrover',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      Text(
                        "Are you a customer?",
                        style: TextStyle(fontFamily: 'IrishGrover', fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        },
                        child: Container(
                          width: 150,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                          alignment: Alignment.center,
                          child: Text(
                            "Go to Home",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'IrishGrover',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategorySearch extends SearchDelegate {
  final List<String> categories = [
    'Vegetables',
    'Milk & Egg',
    'Beverages',
    'Rice, Oil and Dal',
    'Dry Fruits',
    'Packed Food',
    'Soap and Shampoo',
    'Tea & Coffee',
    'Ice Cream',
    'Munchies',
    'Sweets & Chocolates',
    'Cakes',
  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final matchingCategories = categories
        .where((category) => category.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (matchingCategories.isEmpty) {
      return Center(child: Text("No categories found for '$query'"));
    }

    return ListView.builder(
      itemCount: matchingCategories.length,
      itemBuilder: (context, index) {
        final category = matchingCategories[index];
        return ListTile(
          leading: Icon(Icons.category, color: Colors.redAccent),
          title: Text(category),
          onTap: () {
            close(context, category);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? categories
        : categories
        .where((category) => category.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final suggestion = suggestionList[index];
        return ListTile(
          leading: Icon(Icons.search, color: Colors.grey),
          title: Text(suggestion),
          onTap: () {
            query = suggestion;
            showResults(context);
          },
        );
      },
    );
  }
}

class ItemSearchDelegate extends SearchDelegate<String> {
  final Map<String, List<Map<String, dynamic>>> products;

  ItemSearchDelegate(this.products);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, "");
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildSearchResults(context);
  }

  Widget buildSearchResults(BuildContext context) {
    final List<Map<String, dynamic>> matchingItems = [];

    products.forEach((category, items) {
      for (var item in items) {
        if (item['name'].toLowerCase().contains(query.toLowerCase())) {
          matchingItems.add(item);
        }
      }
    });

    print("Search Query: $query");
    print("Matching Items: $matchingItems");

    if (matchingItems.isEmpty) {
      return Center(child: Text("No items found"));
    }

    return ListView.builder(
      itemCount: matchingItems.length,
      itemBuilder: (context, index) {
        var item = matchingItems[index];
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            child: Image.network(
              item['image'],
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                print('Search image error for ${item['image']}: $error');
                return Icon(Icons.broken_image, size: 50, color: Colors.grey);
              },
            ),
          ),
          title: Text(item['name']),
          subtitle: Text("₹${item['price']}"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ItemDetailsPage(item)),
            );
          },
        );
      },
    );
  }
}

class ItemDetailsPage extends StatefulWidget {
  final Map<String, dynamic> item;

  ItemDetailsPage(this.item);

  @override
  _ItemDetailsPageState createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  int quantity = 1;

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartModel>(
      builder: (context, cartModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.item['name']),
            backgroundColor: Colors.redAccent,
            actions: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  _navigateToPage(context, CartPage(cartItems: {}));
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.network(
                      widget.item['image'],
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('Details image error for ${widget.item['image']}: $error');
                        return Icon(Icons.broken_image, size: 200, color: Colors.grey);
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.item['name'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹${widget.item['price']}",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove, color: Colors.redAccent),
                            onPressed: () {
                              if (quantity > 1) {
                                setState(() {
                                  quantity--;
                                });
                              }
                            },
                          ),
                          Text(
                            '$quantity',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, color: Colors.redAccent),
                            onPressed: () {
                              setState(() {
                                quantity++;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Quantity: ${widget.item['quantity']}",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final itemToAdd = Map<String, dynamic>.from(widget.item);
                      for (int i = 0; i < quantity; i++) {
                        cartModel.addToCart(itemToAdd);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${widget.item['name']} (${quantity}x) added to cart!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'Add to Cart ($quantity)',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}