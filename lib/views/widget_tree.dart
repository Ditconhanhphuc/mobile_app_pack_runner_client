import 'package:client/data/notifiers.dart';
import 'package:client/views/pages/cash_flow_page.dart';
import 'package:client/views/pages/home_page.dart';
import 'package:client/views/pages/order_page.dart';
import 'package:client/views/pages/personal_page.dart';
import 'package:client/views/widgets/navbar_widget.dart';
import 'package:flutter/material.dart';

List<Widget> pages = [
  const HomePage(), 
  const CashFlowPage(),
  const OrderPage(),
  const PersonalPage(),
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        bool isHomePage = selectedPage == 0; // Kiểm tra nếu đang ở HomePage

        return Scaffold(
          appBar: isHomePage
              ? null // Nếu là HomePage, không hiển thị AppBar
              : AppBar(
                  title: const Text('Client'),
                ),
          body: pages[selectedPage], // Hiển thị trang hiện tại
          bottomNavigationBar: const NavbarWidget(),
        );
      },
    );
  }
}
