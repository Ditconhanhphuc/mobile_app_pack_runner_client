// lib/presentation/pages/about_us/about_us_page.dart
import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About Us")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("🏢 Công ty: Pack Runner", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("📍 Địa chỉ: 123 Đường ABC, Quận XYZ, TP.HCM"),
            SizedBox(height: 8),
            Text("📞 Hotline: 1900 123 456"),
            Text("📧 Email: contact@packrunner.vn"),
            SizedBox(height: 8),
            Text("📄 Giấy phép kinh doanh: Số 0123456789 - Cấp ngày 01/01/2022"),
          ],
        ),
      ),
    );
  }
}
