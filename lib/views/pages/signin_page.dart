import 'dart:convert';
import 'package:client/views/pages/face_camera_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/data/constants.dart';
import 'package:client/views/pages/otp_verification_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';

class SigninPage extends StatefulWidget {
  final String? prefilledPhone;
  const SigninPage({Key? key, this.prefilledPhone}) : super(key: key);

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? savedPhone;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledPhone != null) {
      phoneNumberController.text = widget.prefilledPhone!;
      savedPhone = widget.prefilledPhone; // Cập nhật savedPhone
    } else {
      loadSavedPhoneNumber();
    }
    // Lắng nghe thay đổi trong phoneNumberController
    phoneNumberController.addListener(() {
      setState(() {
        savedPhone = phoneNumberController.text.isNotEmpty
            ? phoneNumberController.text
            : null;
      });
    });
  }

  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    print('Initial camera permission status: $status');
    if (!status.isGranted) {
      // Kiểm tra lại trạng thái trước khi yêu cầu
      status = await Permission.camera.status;
      print('Recheck camera permission status: $status');
      if (!status.isGranted) {
        status = await Permission.camera.request();
        print('Camera permission after request: $status');
        if (status.isDenied || status.isPermanentlyDenied) {
          print('Opening app settings for camera permission');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Camera access is required for face login. Please enable it in Settings > Privacy > Camera.'),
              action: SnackBarAction(
                label: 'Open Settings',
                onPressed: () async {
                  await openAppSettings();
                },
              ),
            ),
          );
          return false;
        }
      }
    }
    print('Camera permission final status: $status');
    return status.isGranted;
  }

  Future<void> loadSavedPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    savedPhone = prefs.getString('saved_phone');
    if (savedPhone != null) {
      phoneNumberController.text = savedPhone!;
    }
    setState(() {}); // để UI cập nhật lại suffixIcon
  }

  Future<void> _handleFaceIDLogin() async {
    bool granted = await _requestCameraPermission();
    if (!granted) {
      print('Camera permission not granted');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please grant camera permission')),
      );
      return;
    }

    try {
      final cameras = await availableCameras();
      print('Available cameras: ${cameras.length}');
      if (cameras.isEmpty) {
        print('No cameras available');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No cameras available on this device')),
        );
        return;
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () {
          print('No front camera found, using default camera');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No front camera found')),
          );
          return cameras.first;
        },
      );

      print('Using camera: ${frontCamera.name}');
      final XFile? capturedImage = await Navigator.push<XFile?>(
        context,
        MaterialPageRoute(
          builder: (_) => FaceCameraPage(camera: frontCamera),
        ),
      );

      if (capturedImage != null) {
        print('Image captured: ${capturedImage.path}');
        await _sendImageToApi(capturedImage);
      } else {
        print('No image captured');
      }
    } catch (e) {
      print('Error accessing camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accessing camera: $e')),
      );
    }
  }

  Future<void> _sendImageToApi(XFile image) async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('${KConstants.baseUrl}/face-login/');
    var request = http.MultipartRequest('POST', url);
    request.files
        .add(await http.MultipartFile.fromPath('face_image', image.path));
    request.fields['phone_number'] = savedPhone ??
        phoneNumberController
            .text; // Sử dụng savedPhone hoặc phoneNumberController.text

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('Face login response: $responseBody');

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationPage(
                phoneNumber: savedPhone ?? phoneNumberController.text),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Face login failed: $responseBody')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error sending image to server: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending image to server: $e')),
      );
    }
  }

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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_phone', phoneNumber);
      await prefs.setBool('isLoggedIn', true);
      print('Saved phone: $phoneNumber, isLoggedIn: true'); // Log để debug

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationPage(phoneNumber: phoneNumber),
        ),
      );
    } else {
      final data = json.decode(response.body);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(data['error'] ?? 'Login failed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 0.5, color: Color(0xFFDCDCDC)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    TextField(
                      controller: phoneNumberController,
                      decoration: _inputDecoration('Enter your phone number'),
                    ),
                    const SizedBox(height: 20),
                    // TextField(
                    //   controller: passwordController,
                    //   obscureText: true,
                    //   decoration: _inputDecoration('Password'),
                    // ),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: (savedPhone != null ||
                                phoneNumberController.text.isNotEmpty)
                            ? IconButton(
                                icon: Icon(Icons.face),
                                onPressed: () {
                                  _handleFaceIDLogin();
                                },
                              )
                            : null,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(color: KColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              final phone = phoneNumberController.text;
                              final pass = passwordController.text;
                              if (phone.isNotEmpty && pass.isNotEmpty) {
                                loginUser(phone, pass);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KColors.primary,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.white, fontSize: 18.0),
                      ),
                    ),
                    const SizedBox(height: 40),
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
                    const SizedBox(height: 10),
                    _socialIconsRow(),
                    const Spacer(), // ❌ Xoá Spacer nếu không dùng IntrinsicHeight
                    const SizedBox(height: 20),
                    const Text(
                      'By logging in, you agree to our',
                      style: TextStyle(color: Color(0xFF818181)),
                      textAlign: TextAlign.center,
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Terms of Service & Privacy Policy',
                        style: TextStyle(
                          color: KColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _socialIconsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Image.asset('assets/images/apple.jpg'),
          iconSize: 40,
          onPressed: () {},
        ),
        const SizedBox(width: 20),
        IconButton(
          icon: Image.asset('assets/images/google.jpg'),
          iconSize: 40,
          onPressed: () {},
        ),
        const SizedBox(width: 20),
        IconButton(
          icon: Image.asset('assets/images/facebook.jpg'),
          iconSize: 40,
          onPressed: () {},
        ),
      ],
    );
  }
}

// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:client/data/constants.dart';
// import 'package:client/views/pages/otp_verification_page.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class SigninPage extends StatefulWidget {
//   final String? prefilledPhone;
//   const SigninPage({super.key, this.prefilledPhone});

//   @override
//   State<SigninPage> createState() => _SigninPageState();
// }

// class _SigninPageState extends State<SigninPage> {
//   final phoneNumberController = TextEditingController();
//   final passwordController = TextEditingController();
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.prefilledPhone != null) {
//       phoneNumberController.text = widget.prefilledPhone!;
//     } else {
//       loadSavedPhoneNumber();
//     }
//   }

//   Future<void> loadSavedPhoneNumber() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? savedPhone = prefs.getString('saved_phone');
//     if (savedPhone != null) {
//       phoneNumberController.text = savedPhone;
//     }
//   }

//   // Function to handle sign-in
//   Future<void> loginUser(String phoneNumber, String password) async {
//     setState(() {
//       isLoading = true;
//     });

//     final url = Uri.parse('${KConstants.baseUrl}/login/');
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         'phone_number': phoneNumber,
//         'password': password,
//       }),
//     );

//     setState(() {
//       isLoading = false;
//     });

//     if (response.statusCode == 200) {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setString('saved_phone', phoneNumber);
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => OtpVerificationPage(
//             phoneNumber: phoneNumber,
//           ),
//         ),
//       );
//     } else {
//       final data = json.decode(response.body);
//       showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: const Text('Error'),
//             content: Text(data['error'] ?? 'Login failed.'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Close'),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text('Sign In',
//             style: TextStyle(fontWeight: FontWeight.bold)),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         bottom: const PreferredSize(
//           preferredSize: Size.fromHeight(1.0),
//           child: Divider(height: 0.5, color: Color(0xFFDCDCDC)),
//         ),
//       ),
//       body: SafeArea(
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           color: Colors.white,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(height: 20),
//                 TextField(
//                   controller: phoneNumberController,
//                   decoration: InputDecoration(
//                     hintText: 'Enter your phone number',
//                     filled: true,
//                     fillColor: Colors.grey[200],
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 TextField(
//                   controller: passwordController,
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     hintText: 'Password',
//                     filled: true,
//                     fillColor: Colors.grey[200],
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                 ),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     onPressed: () {},
//                     child: Text('Forgot password?',
//                         style: TextStyle(color: KColors.primary)),
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 ElevatedButton(
//                   // onPressed: () {
//                   //   Navigator.pushAndRemoveUntil(
//                   //     context,
//                   //     MaterialPageRoute(
//                   //       builder: (context) {
//                   //         return WidgetTree();
//                   //       },
//                   //     ),
//                   //     (route) => false,
//                   //   );
//                   // },
//                   onPressed: isLoading
//                       ? null
//                       : () {
//                           final phoneNumber = phoneNumberController.text;
//                           final password = passwordController.text;
//                           if (phoneNumber.isNotEmpty && password.isNotEmpty) {
//                             loginUser(phoneNumber, password);
//                           } else {
//                             // Show validation error
//                           }
//                         },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: KColors.primary,
//                     minimumSize: Size(double.infinity, 50),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: const Text(
//                     'Login',
//                     style: TextStyle(color: Colors.white, fontSize: 18.0),
//                   ),
//                 ),
//                 SizedBox(height: 100),
//                 const Row(
//                   children: [
//                     Expanded(child: Divider()),
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 10),
//                       child: Text('Or'),
//                     ),
//                     Expanded(child: Divider()),
//                   ],
//                 ),
//                 SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     IconButton(
//                       icon: Image.asset('assets/images/apple.jpg'),
//                       iconSize: 40,
//                       onPressed: () {},
//                     ),
//                     SizedBox(width: 20),
//                     IconButton(
//                       icon: Image.asset('assets/images/google.jpg'),
//                       iconSize: 40,
//                       onPressed: () {},
//                     ),
//                     SizedBox(width: 20),
//                     IconButton(
//                       icon: Image.asset('assets/images/facebook.jpg'),
//                       iconSize: 40,
//                       onPressed: () {},
//                     ),
//                   ],
//                 ),
//                 Spacer(),
//                 Text(
//                   'By logging in, you agree to our',
//                   style: TextStyle(color: Color(0xFF818181)),
//                 ),
//                 GestureDetector(
//                   onTap: () {},
//                   child: Text(
//                     'Terms of Service & Privacy Policy',
//                     style: TextStyle(
//                         color: KColors.primary, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 SizedBox(height: 40),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
