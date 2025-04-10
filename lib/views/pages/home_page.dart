import 'package:client/data/constants.dart';
import 'package:client/views/pages/create_order_page.dart';
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

  // Khai bao bien cho phan Return Processing
  int _selectedTabIndex = 0;
  final List<String> _tabs = ["Return Processing", "Partial Delivery"];

  // Khai báo biến phần header (time))
  late DateTimeRange selectedDateRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 6)),
      end: now,
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F3),
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
                            IconButton(
                              icon: SvgPicture.asset(
                                "assets/icons/home_header_calendar.svg",
                                width: 28,
                                height: 28,
                              ),
                              onPressed: () {
                                // debugPrint("Calendar Icon Pressed!");
                                _pickDateRange();
                              },
                            ),
                            Text(
                              "${DateFormat("dd/MM/yyyy").format(selectedDateRange!.start)} - ${DateFormat("dd/MM/yyyy").format(selectedDateRange!.end)}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const CreateOrderPage();
                          },
                        ),
                      );
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
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
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

  // ----------- Return Processing Section -----------

  Widget _buildReturnProcessingSection() {
    double returnedPercentage = 30;
    double returningPercentage = 70;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 120,
                child: const Text("Return Processing",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Row(
                  children: [
                    ToggleButtons(
                      borderRadius: BorderRadius.circular(4),
                      borderWidth: 0,
                      constraints:
                          const BoxConstraints(maxWidth: 100, minHeight: 40),
                      isSelected: List.generate(
                          _tabs.length, (index) => index == _selectedTabIndex),
                      onPressed: (index) {
                        setState(() {
                          _selectedTabIndex = index;
                        });
                      },
                      selectedColor: Colors.black, // Màu chữ khi chọn
                      fillColor: Color(0xFFECEDF1), // Màu nền khi được chọn
                      children: _tabs
                          .map((tab) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(tab,
                                    style: const TextStyle(fontSize: 16)),
                              ))
                          .toList(),
                    )
                  ],
                ),
              ),
            ],
          ),
          _selectedTabIndex == 0
              ? _buildReturnProcessingContent()
              : _buildPartialDeliveryContent(
                  returnedPercentage, returningPercentage),
        ],
      ),
    );
  }

  Widget _buildReturnProcessingContent() {
    List<Map<String, dynamic>> returnStatuses = [
      {
        "title": "Pending Return Processing",
        "count": 0,
        "color": Color(0xFFFA3D2F),
        "icon": "assets/icons/home_return_pending.svg"
      },
      {
        "title": "Unable to Contact",
        "count": 0,
        "color": Color(0xFF55B498),
        "icon": "assets/icons/home_return_nocontact.svg"
      },
      {
        "title": "Customer Rejected Delivery",
        "count": 0,
        "color": Color(0xFFFDB03C),
        "icon": "assets/icons/home_return_reject.svg"
      },
      {
        "title": "Wrong Delivery Address",
        "count": 0,
        "color": KColors.primary,
        "icon": "assets/icons/home_return_incorrectAdd.svg"
      },
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 2,
          mainAxisSpacing: 16,
        ),
        itemCount: returnStatuses.length,
        itemBuilder: (context, index) {
          var status = returnStatuses[index];
          return Card(
            elevation: 0,
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  SvgPicture.asset(
                    status["icon"],
                    height: 48,
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      status["title"],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${status["count"]} orders",
                    style: TextStyle(
                      color: status["color"],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPartialDeliveryContent(
      double returnedPercentage, double returningPercentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Total partially signed orders:",
                      style: TextStyle(fontSize: 16)),
                  Text(
                      "${(returnedPercentage + returningPercentage).toInt()} orders",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              SizedBox(height: 16),
              CustomPaint(
                size: Size(100, 50), // Đặt kích thước cho nửa vòng tròn
                painter:
                    HalfCircleChart(returnedPercentage, returningPercentage),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.circle, color: Color(0xFF25CC9B), size: 18),
                  SizedBox(width: 5),
                  Column(
                    children: [
                      Text(
                        "${returnedPercentage.toInt()} orders",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Returned",
                        style:
                            TextStyle(color: Color(0xFF686E75), fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(width: 30),
                  Icon(Icons.circle, color: Color(0xFFD0D4DE), size: 18),
                  SizedBox(width: 5),
                  Column(
                    children: [
                      Text(
                        "${returningPercentage.toInt()} orders",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Returning",
                        style:
                            TextStyle(color: Color(0xFF686E75), fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildInfoCard(
                        "Total COD Amount", "0 VND", Color(0xFFF2F7FF)!),
                    SizedBox(height: 14),
                    _buildInfoCard(
                        "Total Signed COD Amount", "0 VND", Color(0xFFE8FEF7)!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Căn trái text trong Column
        children: [
          Expanded(
            // Đảm bảo chiều rộng bằng nhau
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Căn trái text
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                SizedBox(height: 4), // Tạo khoảng cách giữa hai dòng
                Text(
                  value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ----------- End Return Processing Section -----------

// CustomPainter để vẽ biểu đồ tròn (Pie Chart)
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

// Vẽ hafl pie chart cho phần return processing
class HalfCircleChart extends CustomPainter {
  final double returnedPercentage;
  final double returningPercentage;

  HalfCircleChart(this.returnedPercentage, this.returningPercentage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height);
    final double totalPercentage = returnedPercentage + returningPercentage;
    final double startAngle = -3.14; // Bắt đầu từ bên trái
    final double returnedAngle = (returnedPercentage / totalPercentage) * 3.14;
    final double returningAngle =
        (returningPercentage / totalPercentage) * 3.14;

    paint.color = Color(0xFF25CC9B);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle,
        returnedAngle, false, paint);

    paint.color = Color(0xFFD0D4DE);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        startAngle + returnedAngle, returningAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
