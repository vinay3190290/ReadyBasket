import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:ready_basket1/setting%20page.dart';
import 'dart:convert';
import 'cart page.dart';
import 'loginpage.dart';



class PaymentPage extends StatefulWidget {
  final double total;

  PaymentPage({required this.total});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void openCheckout(BuildContext context) async {
    final userModel = Provider.of<UserModel>(context, listen: false);

    var options = {
      'key': 'rzp_test_HhsOEvvf2Mk23e',
      'amount': (widget.total * 100).toInt(),
      'currency': 'INR',
      'name': 'Ready Basket',
      'description': 'Grocery Order Payment',
      'prefill': {
        'contact': userModel.mobileNumber,
        'email': userModel.email,
      },
      'theme': {'color': '#F44336'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _saveOrderToBackend(String paymentId) async {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);

    List<Map<String, dynamic>> orderItems = cartModel.cartItems.entries.map((entry) {
      var product = entry.key;
      int quantity = entry.value;
      return {
        'name': product['name'],
        'price': product['price'],
        'old_price': product['old_price'],
        'quantity': quantity,
        'image': product['image'],
      };
    }).toList();

    var orderData = {
      'payment_id': paymentId,
      'customer_name': userModel.name,
      'email': userModel.email,
      'mobile': userModel.mobileNumber,
      'total': widget.total,
      'items': orderItems,
    };

    try {
      final response = await http.post(
        Uri.parse('http://192.168.144.146/readybasket/save_order.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(orderData),
      );

      print('Save order response: ${response.statusCode} - ${response.body}');
      final responseData = jsonDecode(response.body);

      if (response.statusCode != 200 || !responseData['success']) {
        throw Exception(responseData['message'] ?? 'Failed to save order');
      }
    } catch (e) {
      print('Error saving order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving order: $e')),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);

    await _saveOrderToBackend(response.paymentId!);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsPage(
          paymentId: response.paymentId!,
          cartItems: cartModel.cartItems,
          total: widget.total,
          customerName: userModel.name,
          email: userModel.email,
          mobile: userModel.mobileNumber,
        ),
      ),
    );

    cartModel.clearCart();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

    // Check if the user is logged in (mobileNumber is neither "N/A" nor empty)
    bool isLoggedIn = userModel.mobileNumber != "N/A" && userModel.mobileNumber.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text("Payment"),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total to Pay: ₹${widget.total.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoggedIn
                  ? () => openCheckout(context)
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isLoggedIn ? Colors.green : Colors.redAccent,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                isLoggedIn ? 'Pay ₹${widget.total.toStringAsFixed(2)}' : 'Login to Pay',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class OrderDetailsPage extends StatelessWidget {
  final String paymentId;
  final Map<Map<String, dynamic>, int> cartItems;
  final double total;
  final String customerName;
  final String email;
  final String mobile;
  final String baseUrl = 'http://192.168.144.146/readybasket/'; // Base URL for images

  OrderDetailsPage({
    required this.paymentId,
    required this.cartItems,
    required this.total,
    required this.customerName,
    required this.email,
    required this.mobile,
  });

  @override
  Widget build(BuildContext context) {
    print('Cart items: $cartItems');
    print('Cart items length: ${cartItems.length}');

    return Scaffold(
      appBar: AppBar(
        title: Text("Order Details"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order Confirmation",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text("Payment ID: $paymentId", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Customer: $customerName", style: TextStyle(fontSize: 16)),
            Text("Email: $email", style: TextStyle(fontSize: 16)),
            Text("Mobile: $mobile", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text("Order Items:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: cartItems.isEmpty
                  ? Center(child: Text("No items in this order"))
                  : ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  var product = cartItems.keys.elementAt(index);
                  int quantity = cartItems[product]!;
                  final imageUrl = product['image'] != null ? '$baseUrl${product['image']}' : null;

                  return ListTile(
                    leading: imageUrl != null
                        ? Image.network(
                      imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image for ${product['name']}: $error');
                        return Icon(Icons.error);
                      },
                    )
                        : Icon(Icons.image_not_supported),
                    title: Text(product['name'] ?? 'Unknown Product'),
                    subtitle: Row(
                      children: [
                        Text("Qty: $quantity, "),
                        Text(
                          "₹${product['price']?.toString() ?? '0.00'}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 6),
                        Text(
                          "₹${product['old_price']?.toString() ?? '0.00'}",
                          style: TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Total: ₹${total.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Back to cart"),
            ),
          ],
        ),
      ),
    );
  }
}