import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Khai bao bien cho phan statistical
  bool isOrderSelected = true;
  int orderNumber = 10;
  int customerNumber = 20;

  // Dữ liệu đơn hàng
  Map<String, double> orderStatistics = {
    "Dispatched": 25.0,
    "In Transit": 35.0,
    "Completed": 30.0,
    "Returned": 10.0,
  };

  // Dữ liệu khách hàng
  Map<String, double> customerStatistics = {
    "New Customer": 60.0,
    "Old Customer": 40.0,
  };

  // Màu sắc
  Map<String, Color> orderColors = {
    "Dispatched": const Color(0xFFFDB03C),
    "In Transit": const Color(0xFF25CC9B),
    "Completed": const Color(0xFF007EFF),
    "Returned": const Color(0xFFFA3D2F),
  };

  Map<String, Color> customerColors = {
    "New Customer": const Color(0xFF007EFF),
    "Old Customer": const Color(0xFFB4B4B4),
  };
  // Khai bao bien cho phan statistical

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: const AppDrawer(),
      body: Column(
        children: [
          _buildHeader(context),
          SizedBox(height: 70), // Đảm bảo header không bị notch che mất
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildOrderSection(),
                  _buildStatisticalSection(),
                  _buildReturnProcessingSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------- Header (Part 1) -----------
  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Container(
            height: 192, // Chiều cao phù hợp với thiết kế
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/home_CBT.png"),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon: SvgPicture.asset(
                              'assets/icons/home_header_menu.svg',
                              width: 32,
                              height: 32,
                            ),
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.25,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              _getGreeting(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 0,
          child: Transform.translate(
            offset: const Offset(0, 62), // Đẩy xuống 62px
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 39, 192, 253),
                    Color(0xFFEFFBFF)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/home_header_live.svg",
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Live ${DateFormat("HH:mm dd/MM/yyyy").format(DateTime.now())}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 180, 228, 247),
                              Color(0xFFEFFBFF)
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              "assets/icons/home_header_calendar.svg",
                              width: 28,
                              height: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${DateFormat("dd/MM/yyyy").format(DateTime.now().subtract(const Duration(days: 6)))} - ${DateFormat("dd/MM/yyyy").format(DateTime.now())}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),
                    ],
                  ),
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/home_header_add.svg',
                      width: 40,
                      height: 40,
                    ),
                    onPressed: () {
                      // Xử lý khi bấm nút "+"
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Get time to greeting function
  String _getGreeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning,";
    } else if (hour < 18) {
      return "Good Afternoon,";
    } else {
      return "Good Evening,";
    }
  }

  // ----------- End Header (Part 1) -----------

  // ----------- Order Section -----------
  Widget _buildOrderSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "New Order",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 14),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Order"),
                    Text(
                      "0 orders",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("COD Payment"),
                    Text(
                      "0 VND",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30),
            Divider(
                thickness: 1,
                color: Color.fromARGB(255, 230, 230, 230),
                height: 1),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOrderStatusItem(
                    "assets/icons/home_order_arisen.svg", "Arisen", true),
                _buildOrderStatusItem(
                    "assets/icons/home_order_picked.svg", "Picked Up", false),
                _buildOrderStatusItem(
                    "assets/icons/home_order_comp.svg", "Completed", false),
                _buildOrderStatusItem(
                    "assets/icons/home_order_fee.svg", "Shipping Fee", false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusItem(String iconPath, String label, bool isActive) {
    return Column(
      children: [
        Container(
          // padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? Colors.amber[100] : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: SvgPicture.asset(
            iconPath,
            width: 50,
            height: 50,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.amber : Colors.black,
          ),
        ),
      ],
    );
  }

  // ----------- End Order Section -----------

  // ----------- Statistical Section -----------

  Widget _buildStatisticalSection() {
    Map<String, double> statistics =
        isOrderSelected ? orderStatistics : customerStatistics;
    Map<String, Color> statusColors =
        isOrderSelected ? orderColors : customerColors;
    int displayNumber = isOrderSelected ? orderNumber : customerNumber;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Statistical",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Row(
                  children: [
                    _buildToggleButton("Order", isOrderSelected, () {
                      setState(() {
                        isOrderSelected = true;
                      });
                    }),
                    _buildToggleButton("Customer", !isOrderSelected, () {
                      setState(() {
                        isOrderSelected = false;
                      });
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 154,
                    height: 154,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  CustomPaint(
                    size: const Size(124, 124),
                    painter: PieChartPainter(statistics, statusColors),
                  ),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isOrderSelected ? "Order Number" : "Order Number",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF545961),
                          ),
                        ),
                        Text(
                          "$displayNumber",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: statistics.entries.map((entry) {
                  return _buildStatusItem(
                    entry.key,
                    statusColors[entry.key] ?? Colors.grey,
                    entry.value,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFECEDF1) : Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
      ),
    );
  }

  Widget _buildStatusItem(String title, Color color, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(Icons.circle, size: 18, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${percentage.toStringAsFixed(1)}%",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF737D86)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------- End Statistical Section -----------

  Widget _buildReturnProcessingSection() {
    return Container(
      height: 100,
      color: Colors.red[100],
      child: const Center(child: Text("Return Processing Section")),
    );
  }
}

// 🎨 CustomPainter để vẽ biểu đồ tròn (Pie Chart)
class PieChartPainter extends CustomPainter {
  final Map<String, double> statistics;
  final Map<String, Color> colors;

  PieChartPainter(this.statistics, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);

    double startAngle = -pi / 2; // Bắt đầu từ góc trên cùng

    double total = statistics.values.reduce((a, b) => a + b);

    statistics.forEach((key, value) {
      final sweepAngle = (value / total) * 2 * pi; // Góc quay theo phần trăm
      paint.color = colors[key] ?? Colors.grey;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    });
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) => true;
}

// Drawer Menu
// class AppDrawer extends StatelessWidget {
//   const AppDrawer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           const DrawerHeader(
//             decoration: BoxDecoration(
//               color: Colors.blueAccent,
//             ),
//             child: Text(
//               "Menu",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//               ),
//             ),
//           ),
//           ListTile(
//             leading: const Icon(Icons.dashboard),
//             title: const Text("Overview"),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) {
//                     return const HomePage();
//                   },
//                 ),
//               );
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.attach_money),
//             title: const Text("Cashflow"),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) {
//                     return const CashFlowPage();
//                   },
//                 ),
//               );
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.shopping_cart),
//             title: const Text("Order"),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) {
//                     return const OrderPage();
//                   },
//                 ),
//               );
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.person),
//             title: const Text("Personal"),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) {
//                     return const PersonalPage();
//                   },
//                 ),
//               );
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.settings),
//             title: const Text("Settings"),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) {
//                     return const OnboardingPage();
//                   },
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
