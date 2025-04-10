import 'package:client/data/constants.dart';
import 'package:client/views/pages/create_order_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HistoryItem extends StatelessWidget {
  final String iconPath;
  final String from;
  final String to;
  final String price;
  final String dateTime;

  const HistoryItem({
    Key? key,
    required this.iconPath,
    required this.from,
    required this.to,
    required this.price,
    required this.dateTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 33,
              height: 33,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        const TextSpan(text: "From "),
                        TextSpan(
                          text: from,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: KColors.primary),
                        ),
                        const TextSpan(text: " to "),
                        TextSpan(
                          text: to,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: KColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(dateTime,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Row(
                    children: [
                      TextButton(
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
                        child: const Text("Book again",
                            style: TextStyle(
                                color: KColors.primary, fontSize: 14)),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: KColors.primary,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
