import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class ScanOrderPage extends StatefulWidget {
  const ScanOrderPage({Key? key}) : super(key: key);

  @override
  State<ScanOrderPage> createState() => _ScanOrderPageState();
}

class _ScanOrderPageState extends State<ScanOrderPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedData;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scannedData == null) {
        setState(() {
          scannedData = scanData.code;
        });

        controller.pauseCamera();

        // Giả sử mã QR chứa orderId, ta điều hướng sang trang chi tiết đơn hàng
        Navigator.pushNamed(context, '/order-detail', arguments: scannedData);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét Mã Đơn Hàng')),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          if (scannedData != null)
            Expanded(
              child: Center(child: Text('Đã quét: $scannedData')),
            )
        ],
      ),
    );
  }
}
