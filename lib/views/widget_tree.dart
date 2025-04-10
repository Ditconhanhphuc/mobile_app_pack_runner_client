import 'package:client/data/constants.dart';
import 'package:client/data/notifiers.dart';
import 'package:client/views/pages/cash_flow_page.dart';
import 'package:client/views/pages/create_order_page.dart';
import 'package:client/views/pages/home_page.dart';
import 'package:client/views/pages/order_page.dart';
import 'package:client/views/pages/personal_page.dart';
import 'package:client/views/widgets/navbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

List<Widget> pages = [
  const HomePage(),
  const CashFlowPage(),
  const OrderPage(),
  const PersonalPage(),
];

List<String> appBarTitles = [
  'Home',
  'Cash Flow Management',
  'Order',
  'Account Setup'
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        bool isHomePage = selectedPage == 0;
        bool isOrderPage = selectedPage == 2;
        bool isPersonalPage = selectedPage == 3;

        return Scaffold(
          appBar: isHomePage
              ? null
              : AppBar(
                  title: Text(appBarTitles[selectedPage],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: isPersonalPage ? KColors.primary : Colors.white,
                  foregroundColor: isPersonalPage ? Colors.white : Colors.black,
                  leading: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {},
                  ),
                  actions: isOrderPage
                      ? [
                          IconButton(
                            icon: SvgPicture.asset(
                              'assets/icons/search.svg',
                              width: 24,
                              height: 24,
                            ),
                            onPressed: () {
                              print("Tìm kiếm trong OrderPage");
                            },
                          ),
                          IconButton(
                            icon: SvgPicture.asset(
                              'assets/icons/home_header_add.svg',
                              width: 34,
                              height: 34,
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
                        ]
                      : [],
                ),
          body: pages[selectedPage],
          bottomNavigationBar: const NavbarWidget(),
        );
      },
    );
  }
}
