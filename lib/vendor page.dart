import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'main.dart';




class VendorHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("welcome to dashboard"),
        leading: Icon(Icons.arrow_back),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Navigate to VendorLoginPage and replace the current route
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => VendorLoginPage()),
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Add Product Button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VendorDashboard()),
                );
              },
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.add_a_photo, size: 50),
              ),
            ),
            SizedBox(height: 8),
            Text("add product", style: TextStyle(fontSize: 16)),
            SizedBox(height: 30),
            // Products in Shop Button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VendorProductListPage()),
                );
              },
              child: Container(
                height: 100,
                width: 100,
                child: Image.asset(
                  'assets/rice_oil_dal.png', // Replace with your image asset
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text("products in shop", style: TextStyle(fontSize: 16)),
            SizedBox(height: 30),
            // Orders Button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VendorOrderListPage()),
                );
              },
              child: Container(
                height: 100,
                width: 100,
                child: Icon(
                  Icons.shopping_cart, // Use an appropriate icon or image
                  size: 50,
                  color: Colors.grey[600],
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 8),
            Text("orders", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}




class VendorOrderListPage extends StatefulWidget {
  @override
  _VendorOrderListPageState createState() => _VendorOrderListPageState();
}

class _VendorOrderListPageState extends State<VendorOrderListPage> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  final String baseUrl = 'http://192.168.144.146/readybasket/'; // Base URL for images

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.144.146/readybasket/get_orders.php'),
      );

      print('Fetch orders response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            orders = List<Map<String, dynamic>>.from(data['orders']);
            isLoading = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch orders');
        }
      } else {
        throw Exception('Failed to fetch orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching orders: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customer Orders"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? Center(child: Text("No orders found"))
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order ID: ${order['id']}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Payment ID: ${order['payment_id'] ?? 'N/A'}",
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text("Customer: ${order['customer_name']}"),
                  Text("Mobile: ${order['mobile']}"),
                  Text("Email: ${order['email'] ?? 'N/A'}"),
                  Text("Total: ₹${order['total']}"),
                  Text("Placed on: ${order['created_at']}"),
                  SizedBox(height: 8),
                  Text(
                    "Items:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...order['items'].map<Widget>((item) {
                    final itemImageUrl = item['image'] != null ? '$baseUrl${item['image']}' : null;
                    return Padding(
                      padding: EdgeInsets.only(left: 16, top: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (itemImageUrl != null)
                            Image.network(
                              itemImageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading image for ${item['name']}: $error');
                                return Icon(Icons.error);
                              },
                            )
                          else
                            Icon(Icons.image_not_supported, size: 50),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name']),
                                Text("Price: ₹${item['price']} (Old: ₹${item['old_price']})"),
                                Text("Quantity: ${item['quantity']}"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}



class VendorProductListPage extends StatefulWidget {
  @override
  _VendorProductListPageState createState() => _VendorProductListPageState();
}

class _VendorProductListPageState extends State<VendorProductListPage> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;
  final String baseUrl = 'http://192.168.144.146/readybasket/'; // Base URL for images

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.144.146/readybasket/get_products.php'),
      );

      print('Fetch products response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            products = List<Map<String, dynamic>>.from(data['products']);
            isLoading = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch products');
        }
      } else {
        throw Exception('Failed to fetch products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $e')),
      );
    }
  }

  Future<void> deleteProduct(String productName) async {
    print('Attempting to delete product with name: $productName');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete_product.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': productName}),
      );

      print('Delete product response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            products.removeWhere((product) => product['name'] == productName);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Product deleted successfully!")),
          );
        } else {
          throw Exception(data['message'] ?? 'Failed to delete product');
        }
      } else {
        throw Exception('Failed to delete product: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error deleting product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Products in Shop"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : products.isEmpty
          ? Center(child: Text("No products found"))
          : GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.7,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final imageUrl = '$baseUrl${product['image_path']}';
          print('Image URL for ${product['name']}: $imageUrl');

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateProductPage(product: product),
                ),
              );
            },
            child: Card(
              elevation: 5,
              child: Column(
                children: [
                  Image.network(
                    imageUrl,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image for ${product['name']}: $error');
                      return Icon(Icons.error);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      product['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text("₹${product['price']}"),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      final productName = product['name'];
                      if (productName != null && productName is String && productName.isNotEmpty) {
                        deleteProduct(productName);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: Product name is missing or invalid")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text("Delete"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


class UpdateProductPage extends StatefulWidget {
  final Map<String, dynamic> product;

  UpdateProductPage({required this.product});

  @override
  _UpdateProductPageState createState() => _UpdateProductPageState();
}

class _UpdateProductPageState extends State<UpdateProductPage> {
  File? _image;
  final picker = ImagePicker();
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController oldPriceController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  String selectedCategory = 'Vegetables';
  List<String> categories = [
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
  final String baseUrl = 'http://192.168.144.146/readybasket/'; // Base URL for images

  @override
  void initState() {
    super.initState();
    // Pre-fill fields with product data
    nameController.text = widget.product['name'] ?? '';
    priceController.text = widget.product['price']?.toString() ?? '';
    oldPriceController.text = widget.product['old_price']?.toString() ?? '';
    stockController.text = widget.product['stock']?.toString() ?? '';
    quantityController.text = widget.product['quantity'] ?? '';
    selectedCategory = widget.product['category'] ?? 'Vegetables';
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        print('Image picked: ${_image!.path}');
      } else {
        print('No image selected');
      }
    });
  }

  Future<void> updateProduct() async {
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        oldPriceController.text.isEmpty ||
        stockController.text.isEmpty ||
        quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fill all fields.")),
      );
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/update_product.php'),
    );

    // Send the product name instead of ID
    request.fields['name'] = widget.product['name']; // Use the original name to identify the product
    request.fields['price'] = priceController.text;
    request.fields['old_price'] = oldPriceController.text;
    request.fields['stock'] = stockController.text;
    request.fields['quantity'] = quantityController.text;
    request.fields['category'] = selectedCategory;
    if (_image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
    }

    print('Updating product: ${request.fields}');
    if (_image != null) print('Image file: ${_image!.path}');

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseBody);
        if (jsonResponse['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Product updated successfully!")),
          );
          Navigator.pop(context); // Go back to product list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed: ${jsonResponse['message'] ?? 'Unknown error'}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode} - $responseBody")),
        );
      }
    } catch (e) {
      print('Error updating product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Product")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: _image == null
                    ? Image.network(
                  '$baseUrl${widget.product['image_path']}', // Prepend baseUrl to image path
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading image: $error');
                    return Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.add_a_photo, size: 50),
                    );
                  },
                )
                    : Image.file(_image!, height: 150),
              ),
              SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Product Name"),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: oldPriceController,
                decoration: InputDecoration(labelText: "Old Price"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stockController,
                decoration: InputDecoration(labelText: "Stock"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: "Quantity (e.g., 1 kg)"),
              ),
              DropdownButton<String>(
                value: selectedCategory,
                items: categories.map((String category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateProduct,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: Text("Update Product"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VendorDashboard extends StatefulWidget {
  @override
  _VendorDashboardState createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  File? _image;
  final picker = ImagePicker();
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController oldPriceController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  String selectedCategory = 'Vegetables';
  List<String> categories = ['Vegetables', 'Milk & Egg', 'Beverages','Rice, Oil and Dal','Dry Fruits','Packed Food','Soap and Shampoo','Tea & Coffee','Ice Cream','Munchies','Sweets & Chocolates','Cakes',];

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        print('Image picked: ${_image!.path}');
      } else {
        print('No image selected');
      }
    });
  }

  Future<void> uploadProduct() async {
    if (_image == null ||
        nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        oldPriceController.text.isEmpty ||
        stockController.text.isEmpty ||
        quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fill all fields and pick an image.")),
      );
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.144.146/readybasket/add_product.php'), // Ensure correct URL
    );

    request.fields['name'] = nameController.text;
    request.fields['price'] = priceController.text;
    request.fields['old_price'] = oldPriceController.text;
    request.fields['stock'] = stockController.text;
    request.fields['quantity'] = quantityController.text;
    request.fields['category'] = selectedCategory;
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    print('Uploading product: ${request.fields}');
    print('Image file: ${_image!.path}');

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseBody);
        if (jsonResponse['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Product added successfully!")),
          );
          nameController.clear();
          priceController.clear();
          oldPriceController.clear();
          stockController.clear();
          quantityController.clear();
          setState(() {
            _image = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed: ${jsonResponse['message']}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print('Error uploading product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Products to Homepage")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: _image == null
                    ? Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.add_a_photo, size: 50),
                )
                    : Image.file(_image!, height: 150),
              ),
              SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Product Name"),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: oldPriceController,
                decoration: InputDecoration(labelText: "Old Price"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stockController,
                decoration: InputDecoration(labelText: "Stock"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: "Quantity (e.g., 1 kg)"),
              ),
              DropdownButton<String>(
                value: selectedCategory,
                items: categories.map((String category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: uploadProduct,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: Text("Add Product"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}