import 'package:client/data/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedFilter = "Last 1 week";
  DateTime? startDate;
  DateTime? endDate;

  final List<String> filterOptions = [
    "Last 1 week",
    "Last 2 weeks",
    "This month",
    "Last month",
    "Custom range"
  ];

  final List<String> orderStatuses = [
    "Total Orders Picked Up",
    "Processing",
    "In Transit",
    "Awaiting Re-Delivery",
    "Delivered, Pending Payment",
    "Reconciled, Payment Completed",
    "Successful Return",
    "Lost or Damaged Items"
  ];

  int notPickedUpOrders = 5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void filterData(String filter) async {
    if (filter == "Custom range") {
      DateTime? pickedStart = await pickDate(context, "Select start date");
      if (pickedStart == null) return;

      DateTime? pickedEnd =
          await pickDate(context, "Select end date", pickedStart);
      if (pickedEnd == null) return;

      setState(() {
        startDate = pickedStart;
        endDate = pickedEnd;
        selectedFilter =
            "Custom: ${DateFormat('dd/MM/yyyy').format(startDate!)} - ${DateFormat('dd/MM/yyyy').format(endDate!)}";
      });
    } else {
      setState(() {
        selectedFilter = filter;
      });
    }
  }

  Future<DateTime?> pickDate(BuildContext context, String title,
      [DateTime? minDate]) async {
    return await showDatePicker(
      context: context,
      initialDate: minDate ?? DateTime.now(),
      firstDate: minDate ?? DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: KColors.primary),
          ),
          child: child!,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: KColors.primary,
            unselectedLabelColor: Colors.black,
            indicatorColor: KColors.primary,
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: "Picked Up"),
              Tab(text: "Not Picked Up"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildPickedUpOrders(),
                buildNotPickedUpOrders(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPickedUpOrders() {
    return Container(
      color: Color(0xFFF2F2F3),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Overview",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  height: 40,
                  width: 260,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: KColors.primary, width: 1),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedFilter,
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down, color: KColors.primary),
                      onChanged: (String? newValue) async {
                        if (newValue == "Custom range") {
                          DateTime? start = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (start != null) {
                            DateTime? end = await showDatePicker(
                              context: context,
                              initialDate: start.add(Duration(days: 1)),
                              firstDate: start,
                              lastDate: DateTime(2100),
                            );
                            if (end != null) {
                              setState(() {
                                selectedFilter =
                                    "${DateFormat('dd/MM/yyyy').format(start)} - ${DateFormat('dd/MM/yyyy').format(end)}";
                                if (!filterOptions.contains(selectedFilter)) {
                                  filterOptions.add(selectedFilter);
                                }
                              });
                            }
                          }
                        } else {
                          setState(() {
                            selectedFilter = newValue!;
                          });
                        }
                      },
                      items: filterOptions
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              value,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: orderStatuses.length,
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.grey[300], thickness: 0.5),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(orderStatuses[index],
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16)),
                        Text("0 orders",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNotPickedUpOrders() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "There are $notPickedUpOrders orders not picked up.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          // thêm danh sách đơn hàng chưa lấy ở đây
        ],
      ),
    );
  }
}
