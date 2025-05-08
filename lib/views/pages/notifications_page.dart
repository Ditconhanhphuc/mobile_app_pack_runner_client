import 'package:client/views/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  // Mẫu dữ liệu thông báo
  final List<Map<String, String>> notifications = const [
    {
      'title': 'Đơn hàng mới',
      'body': 'Bạn vừa nhận được một đơn hàng mới.',
      'id': '1',
      'time': '2025-05-06T10:30:00'
    },
    {
      'title': 'Cập nhật hệ thống',
      'body': 'Hệ thống sẽ bảo trì vào lúc 0h00.',
      'id': '2',
      'time': '2025-05-05T21:00:00'
    },
    {
      'title': 'Khuyến mãi',
      'body': 'Nhận ưu đãi 20% cho đơn hàng tiếp theo!',
      'id': '3',
      'time': '2025-05-04T09:15:00'
    },
  ];

  String formatTime(String rawTime) {
    final DateTime dt = DateTime.parse(rawTime);
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông Báo')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.notificationDetail,
                  arguments: notification,
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(notification['body'] ?? ''),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          formatTime(notification['time'] ?? ''),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
