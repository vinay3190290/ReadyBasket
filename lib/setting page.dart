import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'home page.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F0F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Settings",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: "IrishGrover",
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSettingsItem(
            context,
            icon: "assets/orders.png",
            title: "Orders",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrdersPage()),
              );
            },
          ),
          _buildSettingsItem(
            context,
            icon: "assets/profile.png",
            title: "My Profile",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          _buildSettingsItem(
            context,
            icon: "assets/P_P.png",
            title: "Privacy policy",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Account_PrivacyPage()),
              );
            },
          ),
          _buildSettingsItem(
            context,
            icon: "assets/notifications.png",
            title: "Notifications",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
          ),
          Spacer(),
          _buildLogoutButton(context),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context,
      {required String icon, required String title, required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Image.asset(icon, width: 40, height: 40),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: "CustomFont",
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.red),
          onTap: onTap,
        ),
        Divider(thickness: 1, color: Colors.black),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red, fontFamily: "CustomFont"),
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userModel = Provider.of<UserModel>(context, listen: false);
    _nameController.text = userModel.name;
    _emailController.text = userModel.email;
    _mobileController.text = userModel.mobileNumber;
  }

  Future<void> _saveProfile(BuildContext context) async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final name = _nameController.text;
    final email = _emailController.text;
    final mobile = _mobileController.text;

    try {
      final response = await http.post(
        Uri.parse('http://192.168.144.146/readybasket/save_profile.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'mobile': mobile,
        }),
      );

      print('Save profile response: ${response.statusCode} - ${response.body}');
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        userModel.setProfile(name, email, mobile);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile saved successfully!')),
        );
        Navigator.pop(context);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to save profile');
      }
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "My Profile",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Handwritten',
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Name *"),
            _buildInputField("Enter your name", _nameController),
            _buildLabel("Email *"),
            _buildInputField("Enter your Email", _emailController),
            _buildLabel("Mobile Number *"),
            _buildInputField("Enter your Mobile Number", _mobileController),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                onPressed: () => _saveProfile(context),
                child: Text(
                  "Save changes",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Handwritten',
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Handwritten',
        ),
      ),
    );
  }

  Widget _buildInputField(String hintText, TextEditingController controller, {bool readOnly = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black26,
          width: 0.3,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 16,
            fontFamily: 'Handwritten',
          ),
        ),
      ),
    );
  }
}

class UserModel with ChangeNotifier {
  String _name = "Guest";
  String _email = "";
  String _mobileNumber = "N/A";

  String get name => _name;
  String get email => _email;
  String get mobileNumber => _mobileNumber;

  void setProfile(String name, String email, String mobileNumber) {
    _name = name;
    _email = email;
    _mobileNumber = mobileNumber;
    notifyListeners();
  }
}

class Account_PrivacyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1EFF4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Account Privacy",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'YourCustomFont',
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Account Privacy and Policy",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'YourCustomFont',
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "At Ready Basket, we are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy outlines how we collect, use, store, and protect your data when you use our app.\n\n"
                    "1. Information We Collect\n"
                    "We collect the following personal information to provide and improve our services:\n"
                    "- Name: To personalize your account and order experience.\n"
                    "- Mobile Number: Used for login, account verification, and order notifications.\n"
                    "- Email Address: For order confirmations, updates, and support communication.\n"
                    "- Order Details: Including items purchased and payment information, to fulfill your orders.\n\n"
                    "2. How We Use Your Information\n"
                    "Your data is used solely to:\n"
                    "- Process and deliver your grocery orders.\n"
                    "- Provide customer support and respond to inquiries.\n"
                    "- Enhance your shopping experience through personalized recommendations.\n"
                    "- Notify you about order status, promotions, or app updates (with your consent).\n\n"
                    "3. Data Security\n"
                    "We prioritize your privacy with the following measures:\n"
                    "- Encryption: All sensitive data (e.g., mobile number, payment details) is encrypted during transmission and storage.\n"
                    "- Secure Servers: Your information is stored on protected servers with restricted access.\n"
                    "- No Third-Party Sharing: We do not sell, trade, or share your personal data with third parties, except as required to fulfill orders (e.g., delivery partners) or comply with legal obligations.\n\n"
                    "4. Your Control Over Data\n"
                    "- Access & Update: You can view and edit your account details (name, email) anytime in the Profile section.\n"
                    "- Deletion: Request account deletion by contacting support—your data will be removed within 30 days, except where legally required to retain it.\n\n"
                    "5. Cookies and Tracking\n"
                    "We may use minimal cookies or similar technologies to improve app performance and user experience. These do not collect personal identifiable information beyond what you provide.\n\n"
                    "6. Contact Us\n"
                    "If you have questions about your privacy or data, reach out to us at srinivasuluvinayg0161.sse@saveetha.com.\n\n"
                    "Your trust is our priority. By using Ready Basket, you agree to this Privacy Policy, designed to safeguard your information while delivering a seamless grocery experience.",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'YourCustomFont',
                  color: Colors.black,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool isWhatsAppEnabled = false;
  bool isPushNotificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationOption(
              title: "WhatsApp Messages",
              subtitle: "Get Updates From Us On WhatsApp",
              value: isWhatsAppEnabled,
              onChanged: (bool newValue) {
                setState(() {
                  isWhatsAppEnabled = newValue;
                });
              },
              titleColor: Colors.green,
            ),
            SizedBox(height: 20),
            _buildNotificationOption(
              title: "Push Notifications",
              subtitle: "Turn on to get live order updates & offers",
              value: isPushNotificationsEnabled,
              onChanged: (bool newValue) {
                setState(() {
                  isPushNotificationsEnabled = newValue;
                });
              },
              titleColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationOption({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color titleColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.green,
          inactiveTrackColor: Colors.red,
        ),
      ],
    );
  }
}




class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  final String baseUrl = 'http://192.168.144.146/readybasket/';

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    print('Fetching orders for mobile: ${userModel.mobileNumber}');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get_orders.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile': userModel.mobileNumber}),
      );

      print('Fetch orders response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            orders = List<Map<String, dynamic>>.from(data['orders'] ?? []);
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
    return Consumer<UserModel>(
      builder: (context, userModel, child) {
        // If the user is logged out (i.e., "Guest" or mobileNumber is "N/A" or empty), clear the orders
        if (userModel.name == "Guest" || userModel.mobileNumber == "N/A" || userModel.mobileNumber.isEmpty) {
          if (orders.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                orders = [];
                isLoading = false;
              });
            });
          }
        }

        return Scaffold(
          backgroundColor: Color(0xFFF7F6FF),
          appBar: AppBar(
            title: Text("My Orders", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : orders.isNotEmpty
              ? _buildOrderDetails(context)
              : _buildNoOrders(context),
        );
      },
    );
  }

  Widget _buildOrderDetails(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
        print('Order $index items: $items');

        if (items.isEmpty) {
          return Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: Text("No items in this order"),
          );
        }

        final firstItem = items[0];
        print('First item: $firstItem');
        final imageUrl = firstItem['image'] != null ? '$baseUrl${firstItem['image']}' : null;
        print('Image URL for ${firstItem['name'] ?? 'Unknown'}: $imageUrl');

        // Parse total and old_price to double
        final double total = double.tryParse(order['total']?.toString() ?? '0.0') ?? 0.0;
        final double oldPrice = double.tryParse(firstItem['old_price']?.toString() ?? '0.0') ?? 0.0;

        return Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (imageUrl != null)
                    Image.network(
                      imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image for ${firstItem['name'] ?? 'Unknown'}: $error');
                        return Icon(Icons.broken_image, size: 60, color: Colors.grey);
                      },
                    )
                  else
                    Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstItem['name'] ?? 'Unknown Item',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Text(
                              "Placed on ${order['created_at'] ?? 'N/A'}",
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "₹${total.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "₹${oldPrice.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 1),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RateOrderPage(order: order)),
                        );
                      },
                      child: Text("Rate Order", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),


                  ),
                  VerticalDivider(),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                      child: Text(
                        "Order Again",
                        style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoOrders(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No Orders Yet",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            "Start shopping to see your orders here!",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

  Widget _buildNoOrders(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart, size: 100, color: Colors.grey),
          SizedBox(height: 10),
          Text("No orders yet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text("Browse Products"),
          ),
        ],
      ),
    );
  }



class RateOrderPage extends StatefulWidget {
  final Map<String, dynamic> order;

  RateOrderPage({required this.order});

  @override
  _RateOrderPageState createState() => _RateOrderPageState();
}

class _RateOrderPageState extends State<RateOrderPage> {
  Map<int, int> ratings = {};

  @override
  void initState() {
    super.initState();
    final items = List<Map<String, dynamic>>.from(widget.order['items']);
    for (int i = 0; i < items.length; i++) {
      ratings[i] = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(widget.order['items']);
    return Scaffold(
      backgroundColor: Color(0xFFF7F6FF),
      appBar: AppBar(
        title: Text("How was your order?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildRatingItem(item['name'], item['image'], index);
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print('Ratings submitted: $ratings');
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: Text("Submit", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingItem(String title, String image, int index) {
    return Card(
      child: ListTile(
        leading: Image.network(
          image,
          width: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
        ),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: List.generate(5, (starIndex) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  ratings[index] = starIndex + 1;
                });
              },
              child: Icon(
                starIndex < (ratings[index] ?? 0) ? Icons.star : Icons.star_border,
                size: 30,
                color: starIndex < (ratings[index] ?? 0) ? Colors.amber : Colors.grey,
              ),
            );
          }),
        ),
      ),
    );
  }
}