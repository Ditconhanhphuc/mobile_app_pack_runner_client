import 'package:flutter/material.dart';

class KConstants {
  static const String themeModeKey = 'themeModeKey';
  // static final Uri baseUrl = Uri.parse('http://10.0.2.2:8000/api');
  static final Uri baseUrl = Uri.parse('http://54.66.38.252:8000/api');
  static const String googleMapsApiKey = 'AIzaSyAJFdHGhN7WNSAx8fOcLWEoI7WM6XVVZlE';
}

class KTextStyle {
  static const TextStyle titleTealText = TextStyle(
    color: Color(0xFF0F698C),
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle descriptionText = TextStyle(
    fontSize: 16.0,
  );
}

class KValue {
  static const String basicLayout = 'Basic Layout';
  static const String keyConcepts = 'Key Concepts';
}

class KColors {
  static const Color primary = Color(0xFF0F698C);
  static const Color secondary = Color(0xFFA0A4AB);
}
