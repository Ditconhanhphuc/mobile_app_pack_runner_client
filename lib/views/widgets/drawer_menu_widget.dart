import 'dart:convert';
import 'package:client/data/constants.dart';
import 'package:client/views/pages/onboarding_page.dart';
import 'package:client/views/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DrawerMenuWidget extends StatelessWidget {
  final String userName;

  const DrawerMenuWidget({Key? key, required this.userName}) : super(key: key);

  Future<void> logoutUser(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');

    if (refreshToken == null) {
      // Không có token -> quay về onboarding luôn
      Navigator.pushNamed(context, AppRoutes.onboarding);

      return;
    }

    final url = Uri.parse('${KConstants.baseUrl}/logout/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    // Xoá token local dù logout thành công hay không
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');

    // Chuyển về Onboarding
          Navigator.pushNamed(context, AppRoutes.onboarding);

  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            padding:
                const EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/logo_app.png',
                  height: 70,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor: KColors.primary,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hello,',
                            style:
                                TextStyle(color: Colors.black, fontSize: 14)),
                        Text(
                          userName,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.notifications,
            text: 'Notifications',
            routeName: AppRoutes.notifications,
            trailing: const CircleAvatar(
              radius: 8,
              backgroundColor: Colors.red,
              child: Text('1',
                  style: TextStyle(fontSize: 10, color: Colors.white)),
            ),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.widgets,
            text: 'Products',
            routeName: AppRoutes.products,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.qr_code_scanner,
            text: 'Scan Order Code',
            routeName: AppRoutes.scanOrder,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.store_mall_directory,
            text: 'Find Post Office',
            routeName: AppRoutes.findPostOffice,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.search,
            text: 'Check Fees',
            routeName: AppRoutes.checkFees,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.language,
            text: 'Social Media',
            routeName: AppRoutes.socialMedia,
            trailing: const Icon(Icons.keyboard_arrow_down),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.info_outline,
            text: 'About Us',
            routeName: AppRoutes.aboutUs,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await logoutUser(context);
            },
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Account Created:",
                    style: TextStyle(color: KColors.secondary, fontSize: 12)),
                Text("Version 1.4.9",
                    style: TextStyle(color: KColors.secondary, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required String routeName,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      trailing: trailing,
      onTap: () {
        Navigator.of(context).pushNamed(routeName);
      },
    );
  }
}
