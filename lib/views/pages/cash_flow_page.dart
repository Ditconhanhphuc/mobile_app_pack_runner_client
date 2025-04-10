import 'package:client/data/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CashFlowPage extends StatelessWidget {
  const CashFlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF2F2F3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCard(
              title: 'Signed COD Amount',
              iconPath: 'assets/icons/cash_flow_mana.svg',
              data: const [
                {'label': 'COD Collection', 'value': '500 000 VND'},
                {'label': 'Total Shipping Fee', 'value': '30 000 VND'},
                {'label': 'COD Collection Fee', 'value': '5 000 VND'},
                {'label': 'Return Shipping Fee', 'value': '25 000 VND'},
                {'label': 'Estimated Total', 'value': '35 000 VND'},
              ],
            ),
            const SizedBox(height: 20),
            _buildCard(
              title: 'Funds in Transit',
              iconPath: 'assets/icons/cash_flow_mana.svg',
              data: const [
                {'label': 'COD Collection', 'value': '500 000 VND'},
                {'label': 'Total Shipping Fee', 'value': '30 000 VND'},
                {'label': 'COD Collection Fee', 'value': '5 000 VND'},
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String iconPath,
    required List<Map<String, String>> data,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide.none),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // ignore: deprecated_member_use
                SvgPicture.asset(iconPath, width: 34, height: 34, color: KColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16.0, color: KColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: Color(0xFFECECEC),),
            const SizedBox(height: 8),
            ...data.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['label']!, style: TextStyle(fontSize: 15),),
                      Text(item['value']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
