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
              icon: Icon(Icons.home),
              label: 'Overview',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money),
              label: 'Cash Flow',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Order',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Personal',
            ),
          ],
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        );
      },
    );
  }
}

// import 'package:client/data/notifiers.dart';
// import 'package:flutter/material.dart';

// class NavbarWidget extends StatelessWidget {
//   const NavbarWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder(
//       valueListenable: selectedPageNotifier,
//       builder: (context, selectedPage, child) {
//         return NavigationBar(
//           destinations: const [
//             NavigationDestination(
//               icon: Icon(Icons.home),
//               label: 'Home',
//             ),
//             NavigationDestination(
//               icon: Icon(Icons.person),
//               label: 'Profile',
//             ),
//           ],
//           onDestinationSelected: (int value) {
//             selectedPageNotifier.value = value;
//           },
//           selectedIndex: selectedPage,
//         );
//       },
//     );
//   }
// }
