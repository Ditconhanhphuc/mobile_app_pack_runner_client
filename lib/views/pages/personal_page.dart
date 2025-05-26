import 'package:client/data/constants.dart';
import 'package:client/views/routes/app_routes.dart';
import 'package:client/views/widgets/history_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:client/data/models/order.dart';
import 'package:client/data/services/order_service.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  final OrderService orderService = OrderService();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // Phần nền xanh có bo góc dưới
            Container(
              height: 280,
              decoration: const BoxDecoration(
                color: KColors.primary,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              padding: const EdgeInsets.all(16),
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person,
                            color: KColors.primary, size: 40),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Huỳnh Thị Hà Giang",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              "ID: 256E002167",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                            context, AppRoutes.accountInformation);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white), // Viền có màu
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16)), // Bo góc nhẹ
                        padding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6), // Canh lề cho đẹp
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Account Information",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 8), // Khoảng cách giữa text và icon
                          Icon(Icons.arrow_forward,
                              size: 16, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _actionButton(
                          'assets/icons/account/reward.svg', "Get Reward"),
                      _actionButton('assets/icons/account/add_friend.svg',
                          "Invite Friends"),
                      _actionButton('assets/icons/account/finance.svg',
                          "Finance Management"),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(height: 50), // Để tạo khoảng trống cho Box đè lên
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Phần lịch sử đặt vé
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "History",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          // ListView.builder(
                          //   shrinkWrap: true,
                          //   physics: const NeverScrollableScrollPhysics(),
                          //   itemCount: 2,
                          //   itemBuilder: (context, index) => HistoryItem(
                          //       iconPath: "assets/icons/account/3d_box.svg",
                          //       from: "Sai Gon Gateway",
                          //       to: "Phuong Trang Bus Line",
                          //       price: "100 000 VND",
                          //       dateTime: "10:00, January 15, 2025"),
                          // ),
                          FutureBuilder<List<Order>>(
                            future: orderService.fetchOrders(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                String errorMessage =
                                    'Không thể tải đơn hàng: ${snapshot.error}';
                                bool isAuthError = snapshot.error
                                        .toString()
                                        .contains('401') ||
                                    snapshot.error
                                        .toString()
                                        .contains('No authentication token');
                                if (isAuthError) {
                                  errorMessage = 'Chưa đăng nhập';
                                }
                                if (mounted) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(errorMessage)),
                                    );
                                  });
                                }
                                return Column(
                                  children: [
                                    Center(child: Text(errorMessage)),
                                    const SizedBox(height: 8),
                                    if (isAuthError)
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, AppRoutes.home);
                                        },
                                        child: const Text('Đăng nhập'),
                                      )
                                    else
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(
                                              () {}); // Retry fetching orders
                                        },
                                        child: const Text('Thử lại'),
                                      ),
                                    const SizedBox(height: 8),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: 2,
                                      itemBuilder: (context, index) =>
                                          HistoryItem(
                                        iconPath:
                                            "assets/icons/account/3d_box.svg",
                                        from: "Sai Gon Gateway",
                                        to: "Phuong Trang Bus Line",
                                        price: "100 000 VND",
                                        dateTime: "10:00, January 15, 2025",
                                      ),
                                    ),
                                  ],
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                // Fallback: Dữ liệu tĩnh nếu API không trả về
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: 2,
                                  itemBuilder: (context, index) => HistoryItem(
                                    iconPath: "assets/icons/account/3d_box.svg",
                                    from: "Sai Gon Gateway",
                                    to: "Phuong Trang Bus Line",
                                    price: "100 000 VND",
                                    dateTime: "10:00, January 15, 2025",
                                  ),
                                );
                              }

                              final orders = snapshot.data!;
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: orders.length > 2
                                    ? 2
                                    : orders.length, // Limit to 2 items
                                itemBuilder: (context, index) {
                                  final order = orders[index];
                                  final shipment = order.shipments.isNotEmpty
                                      ? order.shipments[0]
                                      : null;

                                  return HistoryItem(
                                    iconPath: "assets/icons/account/3d_box.svg",
                                    from: shipment?.senderAddress ?? 'Unknown',
                                    to: shipment?.receiverAddress ?? 'Unknown',
                                    price: '${order.totalPrice} VND',
                                    dateTime: _formatDateTime(order.created),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, AppRoutes.historyOrder);
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    "View History",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Box chứa Gold Member & Redeem Points - đặt chồng lên nền xanh
        Positioned(
          top: 250, // Để box này đè lên phần dưới của nền xanh
          left: 20,
          right: 20,
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset('assets/icons/account/member.svg',
                              width: 24),
                          SizedBox(
                            width: 10,
                          ),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Member Details",
                                  style: TextStyle(fontSize: 12)),
                              Text("Gold",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward,
                          color: KColors.primary, size: 18),
                    ],
                  ),
                  Divider(thickness: 1, color: KColors.secondary),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset('assets/icons/account/redeem.svg',
                              width: 24),
                          SizedBox(
                            width: 10,
                          ),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Redeem Points",
                                  style: TextStyle(fontSize: 12)),
                              Text("0 PK",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_forward,
                      color: KColors.primary, size: 18),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton(String iconPath, String label) {
    return SizedBox(
      width: 100, // Đặt chiều rộng cố định cho tất cả các button
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Căn giữa theo chiều dọc
        children: [
          SvgPicture.asset(
            iconPath,
            width: 33,
            height: 33,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center, // Căn giữa chữ nếu xuống dòng
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTime) {
    final parsedDate = DateTime.parse(dateTime).toLocal();
    return '${parsedDate.hour}:${parsedDate.minute.toString().padLeft(2, '0')}, ${parsedDate.day} ${_getMonthName(parsedDate.month)}, ${parsedDate.year}';
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
