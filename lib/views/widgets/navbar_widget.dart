import 'package:client/data/constants.dart';
import 'package:client/data/notifiers.dart';
import 'package:flutter/material.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        return BottomNavigationBar(
          currentIndex: selectedPage,
          onTap: (index) {
            selectedPageNotifier.value = index;
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.signal_cellular_alt),
              label: 'Overview',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.monetization_on),
              label: 'Cash Flow',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Order',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Personal',
            ),
          ],
          selectedItemColor: KColors.primary,
          unselectedItemColor: KColors.secondary,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        );
      },
    );
  }
}