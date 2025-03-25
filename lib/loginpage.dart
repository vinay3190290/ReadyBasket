import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:ready_basket1/setting%20page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController mobileController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> signUpUser() async {
    // Client-side validation for 10-digit mobile number
    String mobile = mobileController.text.trim();
    if (mobile.isEmpty) {
      setState(() {
        errorMessage = "Please enter a mobile number";
      });
      return;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(mobile)) {
      setState(() {
        errorMessage = "Invalid mobile number. Must be exactly 10 digits.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Check if the user exists (login)
      final response = await http.post(
        Uri.parse('http://192.168.144.146/readybasket/check_user.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile_number': mobile}),
      );

      print('Check user response: ${response.statusCode} - ${response.body}');
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        // User exists, update UserModel and navigate back
        Provider.of<UserModel>(context, listen: false).setProfile(
          "User", // Default name, since the PHP script doesn't return a name
          "", // Default email, since the PHP script doesn't return an email
          mobile,
        );
        Navigator.pop(context); // Go back to PaymentPage
      } else if (response.statusCode == 404 && responseData['status'] == 'error' && responseData['message'] == 'Mobile number not found. Please sign up') {
        // User does not exist, proceed to register the user
        await registerUser(mobile);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to check user');
      }
    } catch (e) {
      print('Error checking user: $e');
      setState(() {
        errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> registerUser(String mobile) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.144.146/readybasket/register_user.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobile_number': mobile,
        }),
      );

      print('Register user response: ${response.statusCode} - ${response.body}');
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        // Registration successful, update UserModel and navigate back
        Provider.of<UserModel>(context, listen: false).setProfile(
          'User', // Default name
          '', // Default email
          mobile,
        );
        Navigator.pop(context); // Go back to PaymentPage
      } else {
        throw Exception(responseData['message'] ?? 'Failed to register user');
      }
    } catch (e) {
      print('Error registering user: $e');
      setState(() {
        errorMessage = 'Error: $e';
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
              opacity: 1,
              child: Image.asset(
                'assets/girl_on_cart.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 200,
            child: Container(
              width: 315,
              height: 500,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    "Ready Basket",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IrishGrover', // Use a decorative font
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: TextField(
                      controller: mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Mobile Number",
                        hintText: "Enter your mobile number",
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  if (errorMessage != null)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  SizedBox(height: 20),
                  // Sign Up Button
                  GestureDetector(
                    onTap: isLoading ? null : signUpUser,
                    child: Container(
                      width: 130,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}