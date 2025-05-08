import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingPage extends StatefulWidget {
  final String orderId;

  const TrackingPage({super.key, required this.orderId});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  late GoogleMapController mapController;

  LatLng currentPosition = LatLng(10.762622, 106.660172); // vị trí mặc định HCM
  String orderStatus = "Đang xử lý";

  @override
  void initState() {
    super.initState();
    // TODO: Thiết lập kết nối socket hoặc polling để cập nhật vị trí và trạng thái
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tracking Order")),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: currentPosition, zoom: 14.0),
              onMapCreated: (controller) {
                mapController = controller;
              },
              markers: {
                Marker(
                  markerId: MarkerId("order"),
                  position: currentPosition,
                  infoWindow: InfoWindow(title: "Đơn hàng của bạn"),
                )
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                "Trạng thái: $orderStatus",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}
