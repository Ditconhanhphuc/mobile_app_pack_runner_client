import 'package:flutter/material.dart';
import '../widgets/history_item.dart';

class HistoryOrderPage extends StatefulWidget {
  const HistoryOrderPage({Key? key}) : super(key: key);

  @override
  _HistoryOrderPageState createState() => _HistoryOrderPageState();
}

class _HistoryOrderPageState extends State<HistoryOrderPage> {
  // Dữ liệu mẫu
  final List<Map<String, String>> orders = [
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
    {
      "icon": "assets/icons/account/3d_box.svg",
      "from": "Ben Thanh Market",
      "to": "District 7",
      "price": "150 000 VND",
      "dateTime": "10:00, January 15, 2025"
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
      appBar: AppBar(
        title: const Text("Order History",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1), 
          child: Divider(
              height: 1, color: Colors.grey.shade300),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Filter:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: "1 week",
                    items: const [
                      DropdownMenuItem(value: "1 week", child: Text("1 Week")),
                      DropdownMenuItem(
                          value: "2 weeks", child: Text("2 Weeks")),
                      DropdownMenuItem(
                          value: "1 month", child: Text("1 Month")),
                      DropdownMenuItem(value: "custom", child: Text("Custom")),
                    ],
                    onChanged: (value) {
                      // Xử lý filter theo thời gian
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20), // Thêm padding 2 bên
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return HistoryItem(
                    iconPath: orders[index]["icon"]!,
                    from: orders[index]["from"]!,
                    to: orders[index]["to"]!,
                    price: orders[index]["price"]!,
                    dateTime: orders[index]["dateTime"]!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
