import 'package:client/data/models/order.dart';
import 'package:client/data/services/order_service.dart';
import 'package:flutter/material.dart';
import '../widgets/history_item.dart';

class HistoryOrderPage extends StatefulWidget {
  const HistoryOrderPage({Key? key}) : super(key: key);

  @override
  _HistoryOrderPageState createState() => _HistoryOrderPageState();
}

class _HistoryOrderPageState extends State<HistoryOrderPage> {
  final OrderService _orderService = OrderService();
  String _selectedFilter = "1 week";

  final List<Map<String, String>> sampleOrders = [
    {
      "icon": "assets/icons/account/3d_box.svg",
      "from": "Sai Gon Gateway",
      "to": "Phuong Trang Bus Line",
      "price": "100 000 VND",
      "dateTime": "16:24, January 17, 2025"
    },
    {
      "icon": "assets/icons/account/3d_box.svg",
      "from": "Ben Thanh Market",
      "to": "District 7",
      "price": "150 000 VND",
      "dateTime": "10:00, January 15, 2025"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildFilterRow(),
            Expanded(child: _buildOrderList()),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        "Order History",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Filter:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          DropdownButton<String>(
            value: _selectedFilter,
            items: const [
              DropdownMenuItem(value: "1 week", child: Text("1 Week")),
              DropdownMenuItem(value: "2 weeks", child: Text("2 Weeks")),
              DropdownMenuItem(value: "1 month", child: Text("1 Month")),
              DropdownMenuItem(value: "custom", child: Text("Custom")),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedFilter = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    return FutureBuilder<List<Order>>(
      future: _orderService.fetchOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final orderList = snapshot.data;

        if (orderList == null || orderList.isEmpty) {
          // Hiển thị dữ liệu mẫu nếu không có dữ liệu thực
          return ListView.builder(
            itemCount: sampleOrders.length,
            itemBuilder: (context, index) {
              final order = sampleOrders[index];
              return HistoryItem(
                iconPath: order["icon"]!,
                from: order["from"]!,
                to: order["to"]!,
                price: order["price"]!,
                dateTime: order["dateTime"]!,
              );
            },
          );
        }

        return ListView.builder(
          itemCount: orderList.length,
          itemBuilder: (context, index) {
            final order = orderList[index];
            final shipment =
                order.shipments.isNotEmpty ? order.shipments[0] : null;

            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
              child: HistoryItem(
                iconPath: "assets/icons/account/3d_box.svg",
                from: shipment?.senderAddress ?? 'Unknown',
                to: shipment?.receiverAddress ?? 'Unknown',
                price: '${order.totalPrice} VND',
                dateTime: _formatDateTime(order.created),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDateTime(String dateTime) {
    try {
      final parsedDate = DateTime.parse(dateTime).toLocal();
      final hour = parsedDate.hour.toString().padLeft(2, '0');
      final minute = parsedDate.minute.toString().padLeft(2, '0');
      return '$hour:$minute, ${parsedDate.day} ${_getMonthName(parsedDate.month)}, ${parsedDate.year}';
    } catch (_) {
      return 'Unknown Date';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
