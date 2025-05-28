// import 'package:flutter/material.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'home_page.dart';
// import 'signin_page.dart';

// class BiometricLoginPage extends StatefulWidget {
//   const BiometricLoginPage({super.key});

//   @override
//   _BiometricLoginPageState createState() => _BiometricLoginPageState();
// }

// class _BiometricLoginPageState extends State<BiometricLoginPage> {
//   final LocalAuthentication auth = LocalAuthentication();
//   String? savedPhone;

//   @override
//   void initState() {
//     super.initState();
//     _initBiometricFlow();
//   }

//   Future<void> _initBiometricFlow() async {
//     final prefs = await SharedPreferences.getInstance();
//     savedPhone = prefs.getString('saved_phone');

//     final bool isSupported = await auth.isDeviceSupported();
//     final bool canCheckBiometrics = await auth.canCheckBiometrics;
//     final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();

//     debugPrint('Device supported: $isSupported');
//     debugPrint('Can check biometrics: $canCheckBiometrics');
//     debugPrint('Available biometrics: $availableBiometrics');
//     debugPrint('Saved phone: $savedPhone');

//     bool isAuthenticated = false;

//     if (isSupported && canCheckBiometrics && availableBiometrics.isNotEmpty) {
//       try {
//         isAuthenticated = await auth.authenticate(
//           localizedReason: 'Please authenticate to continue',
//           options: const AuthenticationOptions(
//             biometricOnly: true,
//             stickyAuth: true,
//           ),
//         );
//       } catch (e) {
//         debugPrint('Biometric error: $e');
//       }
//     }

//     if (!mounted) return;

//     if (isAuthenticated && savedPhone != null) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => SigninPage(prefilledPhone: savedPhone!),
//         ),
//       );
//     } else {
//       // Nếu không auth được hoặc không có số điện thoại => về trang Sign In bình thường
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => const SigninPage(),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(child: CircularProgressIndicator()),
//     );
//   }
// }
