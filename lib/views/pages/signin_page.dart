import 'dart:convert';

import 'package:client/data/constants.dart';
import 'package:client/views/pages/otp_verification_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  // Function to handle sign-in
  Future<void> loginUser(String phoneNumber, String password) async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('${KConstants.baseUrl}/login/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phone_number': phoneNumber,
        'password': password,
      }),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationPage(
            phoneNumber: phoneNumber,
          ),
        ),
      );
    } else {
      final data = json.decode(response.body);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(data['error'] ?? 'Login failed.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Sign In',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 0.5, color: Color(0xFFDCDCDC)),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              TextField(
                controller: phoneNumberController,
                decoration: InputDecoration(
                  hintText: 'Enter your phone number',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text('Forgot password?',
                      style: TextStyle(color: KColors.primary)),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                // onPressed: () {
                //   Navigator.pushAndRemoveUntil(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) {
                //         return WidgetTree();
                //       },
                //     ),
                //     (route) => false,
                //   );
                // },
                onPressed: isLoading
                    ? null
                    : () {
                        final phoneNumber = phoneNumberController.text;
                        final password = passwordController.text;
                        if (phoneNumber.isNotEmpty && password.isNotEmpty) {
                          loginUser(phoneNumber, password);
                        } else {
                          // Show validation error
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: KColors.primary,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              ),
              SizedBox(height: 100),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('Or'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Image.asset('assets/images/apple.jpg'),
                    iconSize: 40,
                    onPressed: () {},
                  ),
                  SizedBox(width: 20),
                  IconButton(
                    icon: Image.asset('assets/images/google.jpg'),
                    iconSize: 40,
                    onPressed: () {},
                  ),
                  SizedBox(width: 20),
                  IconButton(
                    icon: Image.asset('assets/images/facebook.jpg'),
                    iconSize: 40,
                    onPressed: () {},
                  ),
                ],
              ),
              Spacer(),
              Text(
                'By logging in, you agree to our',
                style: TextStyle(color: Color(0xFF818181)),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Terms of Service & Privacy Policy',
                  style: TextStyle(
                      color: KColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
