import 'package:client/data/constants.dart';
import 'package:client/views/pages/signin_page.dart';
import 'package:client/views/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool agreeToTerms = false;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController shippingScaleController = TextEditingController();
  final TextEditingController industryController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController dobController = TextEditingController();

  Future<void> registerUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    final url = Uri.parse('${KConstants.baseUrl}/register/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': usernameController.text,
        'email': emailController.text,
        'password': passwordController.text,
        'phone_number': phoneController.text,
        'date_of_birth': dobController.text,
        'group': 'User', // optional, based on your backend
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registered successfully")),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SigninPage(),
        ),
      );
    } else {
      final data = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${data['message'] ?? 'Registration failed'}"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Sign Up',
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
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTextField(
                    'Username', 'Enter username', usernameController),
                buildTextField('Shipping Scale', 'Choose shipping scale',
                    shippingScaleController),
                buildTextField(
                    'Industry', 'Choose industry', industryController),
                buildTextField(
                    'Phone Number', 'Enter your phone number', phoneController),
                buildTextField(
                    'Email', 'Enter your email address', emailController),
                buildTextField(
                    'Date of Birth', 'Enter your date of birth', dobController),
                buildTextField(
                    'Password', 'Enter your password', passwordController,
                    obscureText: true),
                buildTextField('Confirm Password', 'Enter your password',
                    confirmPasswordController,
                    obscureText: true),
                SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox.adaptive(
                      value: agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          agreeToTerms = value!;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'I have read and agree to the ',
                          children: [
                            TextSpan(
                              text: 'Terms of Service, Privacy Policy, ',
                              style: TextStyle(
                                  color: KColors.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: 'and ',
                            ),
                            TextSpan(
                              text: 'Personal Data Protection Policy ',
                              style: TextStyle(
                                  color: KColors.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: 'of PackRunner. ',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  // onPressed: () {
                  //   if (agreeToTerms) {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) {
                  //           return const SigninPage();
                  //         },
                  //       ),
                  //     );
                  //   } else {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(
                  //         content: Text('Please agree to terms and conditions'),
                  //       ),
                  //     );
                  //   }
                  // },
                  onPressed: () {
                    if (agreeToTerms) {
                      registerUser(); // instead of Navigator.push
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Please agree to terms and conditions')),
                      );
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
                    'Sign up',
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                ),
                SizedBox(height: 15),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const SigninPage();
                          },
                        ),
                      );
                    },
                    child: const Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        children: [
                          TextSpan(
                            text: 'Log in now',
                            style: TextStyle(
                              color: KColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      String label, String hint, TextEditingController controller,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFB4B4B4)),
              filled: true,
              fillColor: Colors.white,
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFDCDCDC)),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFDCDCDC)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
