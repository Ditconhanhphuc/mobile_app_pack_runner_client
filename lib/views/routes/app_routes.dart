import 'package:client/views/pages/about_us_page.dart';
import 'package:client/views/pages/account_information_page.dart';
import 'package:client/views/pages/cash_flow_page.dart';
import 'package:client/views/pages/create_order_page.dart';
import 'package:client/views/pages/history_order_page.dart';
import 'package:client/views/pages/home_page.dart';
import 'package:client/views/pages/notification_detail_page.dart';
import 'package:client/views/pages/notifications_page.dart';
import 'package:client/views/pages/onboarding_page.dart';
import 'package:client/views/pages/order_page.dart';
import 'package:client/views/pages/personal_page.dart';
import 'package:client/views/pages/scan_order_page.dart';
import 'package:client/views/pages/tracking_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String home = '/';
  static const String otp = '/otp';
  static const String cashFlow = '/cash-flow';
  static const String historyOrder = '/order/history';
  static const String order = '/order';
  static const String profile = '/profile';
  static const String onboarding = '/onboarding';
  static const String createOrder = '/order/create';
  static const String notifications = '/notifications';
  static const String products = '/products';
  static const String scanOrder = '/order/scan';
  static const String findPostOffice = '/find-post-office';
  static const String checkFees = '/check-fees';
  static const String socialMedia = '/social-media';
  static const String aboutUs = '/about-us';
  static const String notificationDetail = '/notifications/detail';
  static const String trackingOrder = '/order/tracking';
  static const String accountInformation = '/user/information';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case cashFlow:
        return MaterialPageRoute(builder: (_) => const CashFlowPage());
      case historyOrder:
        return MaterialPageRoute(builder: (_) => const HistoryOrderPage());
      case order:
        return MaterialPageRoute(builder: (_) => const OrderPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const PersonalPage());
      case createOrder:
        return MaterialPageRoute(builder: (_) => const CreateOrderPage());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsPage());
      case notificationDetail:
        return MaterialPageRoute(builder: (_) => const NotificationDetailPage());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case accountInformation:
        return MaterialPageRoute(builder: (_) => AccountInfoPage());
      // case products:
      //   return MaterialPageRoute(builder: (_) => const Product());
      // case scanOrder:
      //   return MaterialPageRoute(builder: (_) => const ScanOrder());
      // case findPostOffice:
      //   return MaterialPageRoute(builder: (_) => const FindPostOffice());
      // case checkFees:
      //   return MaterialPageRoute(builder: (_) => const CheckFees());
      // case socialMedia:
      //   return MaterialPageRoute(builder: (_) => const SocialMedia());
      case aboutUs:
        return MaterialPageRoute(builder: (_) => const AboutUsPage());
      case scanOrder:
        return MaterialPageRoute(builder: (_) => const ScanOrderPage());
      case trackingOrder:
        return MaterialPageRoute(builder: (_) => const TrackingPage(orderId: "123ABC"));
        
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page is developing!')),
          ),
        );
    }
  }
}

