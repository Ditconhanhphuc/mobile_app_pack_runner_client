import 'package:client/data/constants.dart';
import 'package:client/views/pages/create_order_page.dart';
import 'package:client/views/pages/history_order_page.dart';
import 'package:client/views/widgets/history_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
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
                      onPressed: () {},
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
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 2,
                            itemBuilder: (context, index) => HistoryItem(
                              iconPath: "assets/icons/account/3d_box.svg",
                              from: "Sai Gon Gateway",
                              to: "Phuong Trang Bus Line",
                              price: "100 000 VND",
                              dateTime: "10:00, January 15, 2025"
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const HistoryOrderPage()),
                                );
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

  // Widget _historyItem(String iconPath, String from, String to, String price) {
  //   return Card(
  //     margin: const EdgeInsets.symmetric(vertical: 8),
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: Padding(
  //       padding: const EdgeInsets.all(12),
  //       child: Row(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           SvgPicture.asset(
  //             iconPath,
  //             width: 33,
  //             height: 33,
  //           ),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 RichText(
  //                   text: TextSpan(
  //                     style: const TextStyle(color: Colors.black, fontSize: 16),
  //                     children: [
  //                       const TextSpan(text: "From "),
  //                       TextSpan(
  //                         text: from,
  //                         style: const TextStyle(
  //                             fontWeight: FontWeight.bold,
  //                             fontSize: 16,
  //                             color: KColors.primary),
  //                       ),
  //                       const TextSpan(text: " to "),
  //                       TextSpan(
  //                         text: to,
  //                         style: const TextStyle(
  //                             fontWeight: FontWeight.bold,
  //                             fontSize: 16,
  //                             color: KColors.primary),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 const SizedBox(height: 4),
  //                 const Text("16:24, January 17, 2025",
  //                     style: TextStyle(color: Colors.grey, fontSize: 12)),
  //                 Row(
  //                   children: [
  //                     TextButton(
  //                       onPressed: () {
  //                         Navigator.push(
  //                           context,
  //                           MaterialPageRoute(
  //                             builder: (context) {
  //                               return const CreateOrderPage();
  //                             },
  //                           ),
  //                         );
  //                       },
  //                       child: const Text("Book again",
  //                           style: TextStyle(
  //                               color: KColors.primary, fontSize: 14)),
  //                     ),
  //                     Icon(
  //                       Icons.arrow_forward,
  //                       color: KColors.primary,
  //                       size: 18,
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //           const SizedBox(width: 12),
  //           Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
}
