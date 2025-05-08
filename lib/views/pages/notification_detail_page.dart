import 'package:flutter/material.dart';

class NotificationDetailPage extends StatelessWidget {
  const NotificationDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notification = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;

    if (notification == null) {
      return const Scaffold(
        body: Center(child: Text('Không có dữ liệu thông báo.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chi Tiết Thông Báo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification['title'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(notification['body'] ?? '', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
