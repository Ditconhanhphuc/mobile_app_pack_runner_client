import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/data/constants.dart';

class TrackingOrderPage extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const TrackingOrderPage({super.key, required this.orderData});

  @override
  State<TrackingOrderPage> createState() => _TrackingOrderPageState();
}

class _TrackingOrderPageState extends State<TrackingOrderPage> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? _mapController;

  String orderStatus = "Ordered";
  String? shipmentCode;
  Timer? _statusPollingTimer;
  bool _mapLoadError = false;
  List<LatLng> _routePoints = [];
  String? _routeError;

  late LatLng senderLatLng;
  late LatLng receiverLatLng;

  final List<String> statusList = ["Ordered", "In Transit", "Delivered"];

  // Thay bằng khóa API Google Maps thực tế
  static const String _googleApiKey = 'AIzaSyAJFdHGhN7WNSAx8fOcLWEoI7WM6XVVZlE';

  @override
  void initState() {
    super.initState();

    orderStatus = widget.orderData['status']?.toString() ?? "Ordered";
    shipmentCode =
        widget.orderData['shipments']?[0]?['shipment_code']?.toString();

    final senderLat =
        double.tryParse(widget.orderData['sender_latitude'].toString()) ?? 0.0;
    final senderLng =
        double.tryParse(widget.orderData['sender_longitude'].toString()) ?? 0.0;
    final receiverLat =
        double.tryParse(widget.orderData['receiver_latitude'].toString()) ??
            0.0;
    final receiverLng =
        double.tryParse(widget.orderData['receiver_longitude'].toString()) ??
            0.0;

    senderLatLng = LatLng(senderLat, senderLng);
    receiverLatLng = LatLng(receiverLat, receiverLng);

    print('orderData: ${widget.orderData}');
    print(
        'Tọa độ: người gửi($senderLat, $senderLng), người nhận($receiverLat, $receiverLng)');
    print('Trạng thái ban đầu: $orderStatus');
    print('Mã vận đơn ban đầu: $shipmentCode');

    _checkLocationPermission();
    _fetchOrderDetails();
    _fetchRoute();
    _startStatusPolling();
  }

  @override
  void didUpdateWidget(TrackingOrderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_controller.isCompleted) {
      _controller = Completer<GoogleMapController>();
    }
  }

  Future<void> _checkLocationPermission() async {
    var status = await Permission.location.request();
    if (!status.isGranted && mounted) {
      setState(() {
        _mapLoadError = true;
      });
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //       content: Text("Cần cấp quyền vị trí để hiển thị bản đồ")),
      // );
    } else {
      setState(() {
        _mapLoadError = false;
      });
    }
  }

  Future<void> _fetchOrderDetails() async {
    final orderId = widget.orderData['order_id']?.toString();
    if (orderId == null || orderId.isEmpty) {
      print('Lỗi: orderId rỗng hoặc null');
      return;
    }

    final url = Uri.parse('${KConstants.baseUrl}/orders/$orderId/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${await _getToken()}',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Phản hồi chi tiết đơn hàng: $data');
        if (mounted) {
          setState(() {
            shipmentCode =
                data['data']?['shipments']?[0]?['shipment_code']?.toString() ??
                    shipmentCode;
            orderStatus =
                data['data']?['order_status']?.toString() ?? orderStatus;
            // Cập nhật tọa độ nếu có trong phản hồi API
            final newSenderLat = double.tryParse(
                    data['data']?['sender_latitude']?.toString() ?? '0.0') ??
                0.0;
            final newSenderLng = double.tryParse(
                    data['data']?['sender_longitude']?.toString() ?? '0.0') ??
                0.0;
            final newReceiverLat = double.tryParse(
                    data['data']?['receiver_latitude']?.toString() ?? '0.0') ??
                0.0;
            final newReceiverLng = double.tryParse(
                    data['data']?['receiver_longitude']?.toString() ?? '0.0') ??
                0.0;
            if (newSenderLat != 0.0 &&
                newSenderLng != 0.0 &&
                newReceiverLat != 0.0 &&
                newReceiverLng != 0.0) {
              senderLatLng = LatLng(newSenderLat, newSenderLng);
              receiverLatLng = LatLng(newReceiverLat, newReceiverLng);
              print(
                  'Cập nhật tọa độ từ API: người gửi($newSenderLat, $newSenderLng), người nhận($newReceiverLat, $newReceiverLng)');
            }
          });
          // Thử lấy lại lộ trình nếu tọa độ được cập nhật
          if (_routeError != null) {
            _fetchRoute();
          }
        }
        print("Mã vận đơn lấy được: $shipmentCode");
        print("Trạng thái đơn hàng lấy được: $orderStatus");
      } else {
        print(
            'Lỗi lấy chi tiết đơn hàng: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Ngoại lệ khi lấy chi tiết đơn hàng: $e');
    }
  }

  Future<void> _fetchRoute() async {
    // Kiểm tra tọa độ hợp lệ
    if (senderLatLng.latitude == 0.0 ||
        senderLatLng.longitude == 0.0 ||
        receiverLatLng.latitude == 0.0 ||
        receiverLatLng.longitude == 0.0 ||
        senderLatLng.latitude < -90 ||
        senderLatLng.latitude > 90 ||
        senderLatLng.longitude < -180 ||
        senderLatLng.longitude > 180 ||
        receiverLatLng.latitude < -90 ||
        receiverLatLng.latitude > 90 ||
        receiverLatLng.longitude < -180 ||
        receiverLatLng.longitude > 180) {
      print('Lỗi: Tọa độ không hợp lệ để lấy lộ trình');
      setState(() {
        _routeError = 'Tọa độ không hợp lệ: Kiểm tra vĩ độ/kinh độ';
        _routePoints = [senderLatLng, receiverLatLng];
      });
      return;
    }

    if (_googleApiKey == 'YOUR_GOOGLE_MAPS_API_KEY') {
      print('Lỗi: Khóa API Google Maps chưa được cấu hình');
      setState(() {
        _routeError = 'Chưa cấu hình khóa API Google Maps';
        _routePoints = [senderLatLng, receiverLatLng];
      });
      return;
    }

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${senderLatLng.latitude},${senderLatLng.longitude}'
      '&destination=${receiverLatLng.latitude},${receiverLatLng.longitude}'
      '&mode=driving'
      '&key=$_googleApiKey',
    );

    try {
      print('Gửi yêu cầu Directions API: $url');
      final response = await http.get(url);
      print('Mã trạng thái HTTP: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Phản hồi Directions API: $data');
        if (data['status'] == 'OK') {
          final points = data['routes']?[0]?['overview_polyline']?['points'];
          if (points != null && points.isNotEmpty) {
            final decodedPoints = _decodePolyline(points);
            if (mounted) {
              setState(() {
                _routePoints = decodedPoints;
                _routeError = null;
              });
              print('Lộ trình được giải mã: ${decodedPoints.length} điểm');
            }
            // Điều chỉnh góc nhìn bản đồ
            if (_mapController != null) {
              final bounds = _getBounds(decodedPoints);
              _mapController!.animateCamera(
                CameraUpdate.newLatLngBounds(bounds, 50),
              );
            }
          } else {
            print('Lỗi: Không tìm thấy polyline trong phản hồi');
            setState(() {
              _routeError = 'Không tìm thấy lộ trình trong dữ liệu API';
              _routePoints = [senderLatLng, receiverLatLng];
            });
          }
        } else {
          final errorMessage = data['error_message'] ?? 'Không rõ';
          print('Lỗi Directions API: ${data['status']} - $errorMessage');
          setState(() {
            _routeError = 'Lỗi API: ${data['status']} ($errorMessage)';
            _routePoints = [senderLatLng, receiverLatLng];
          });
        }
      } else {
        print('Lỗi HTTP: ${response.statusCode} - ${response.body}');
        setState(() {
          _routeError = 'Lỗi HTTP: ${response.statusCode}';
          _routePoints = [senderLatLng, receiverLatLng];
        });
      }
    } catch (e) {
      print('Ngoại lệ khi lấy lộ trình: $e');
      setState(() {
        _routeError = 'Lỗi kết nối: $e';
        _routePoints = [senderLatLng, receiverLatLng];
      });
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    double south = points[0].latitude;
    double north = points[0].latitude;
    double west = points[0].longitude;
    double east = points[0].longitude;

    for (var point in points) {
      if (point.latitude < south) south = point.latitude;
      if (point.latitude > north) north = point.latitude;
      if (point.longitude < west) west = point.longitude;
      if (point.longitude > east) east = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    final orderId = widget.orderData['order_id']?.toString();
    if (orderId == null || orderId.isEmpty) {
      print('Lỗi: orderId rỗng hoặc null');
      return;
    }

    final url = Uri.parse('${KConstants.baseUrl}/orders/$orderId/status/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${await _getToken()}',
    };
    final body = jsonEncode({'order_status': newStatus});

    try {
      print('Cập nhật trạng thái thành: $newStatus');
      final response = await http.patch(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            orderStatus = newStatus;
          });
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //       content: Text("Cập nhật trạng thái thành công: $newStatus")),
          // );
          print("Cập nhật trạng thái thành công: $newStatus");
        }
      } else {
        print(
            'Lỗi cập nhật trạng thái: ${response.statusCode} - ${response.body}');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //       content:
        //           Text("Lỗi khi cập nhật trạng thái: ${response.statusCode}")),
        // );
      }
    } catch (e) {
      print('Ngoại lệ khi cập nhật trạng thái: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("Lỗi khi cập nhật trạng thái")),
      // );
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    print('Access token: $token');
    return token;
  }

  void _startStatusPolling() {
    print('Bắt đầu cập nhật trạng thái định kỳ...');
    _statusPollingTimer?.cancel();
    _statusPollingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _fetchOrderDetails(),
    );
  }

  Set<Marker> _buildMarkers() {
    return {
      Marker(
        markerId: const MarkerId("sender"),
        position: senderLatLng,
        infoWindow: const InfoWindow(title: "Người gửi"),
      ),
      Marker(
        markerId: const MarkerId("receiver"),
        position: receiverLatLng,
        infoWindow: const InfoWindow(title: "Người nhận"),
      ),
    };
  }

  Set<Polyline> _buildPolyline() {
    return {
      Polyline(
        polylineId: const PolylineId("route"),
        points: _routePoints.isNotEmpty
            ? _routePoints
            : [senderLatLng, receiverLatLng],
        color: Colors.blue,
        width: 5,
      )
    };
  }

  void _showStatusUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update your order status"),
          content: DropdownButton<String>(
            value: orderStatus,
            isExpanded: true,
            items: statusList.map((String status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(
                  status == 'Ordered'
                      ? 'Ordered'
                      : status == 'In Transit'
                          ? 'In Transit'
                          : 'Delivered',
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null && newValue != orderStatus) {
                _updateOrderStatus(newValue);
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimeline() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTimelineItem(
            icon: Icons.inventory,
            label: 'Ordered',
            isActive: orderStatus == 'Ordered' ||
                orderStatus == 'In Transit' ||
                orderStatus == 'Delivered',
            isCompleted:
                orderStatus == 'In Transit' || orderStatus == 'Delivered',
          ),
          _buildTimelineItem(
            icon: Icons.local_shipping,
            label: 'In Transit',
            isActive: orderStatus == 'In Transit' || orderStatus == 'Delivered',
            isCompleted: orderStatus == 'Delivered',
          ),
          _buildTimelineItem(
            icon: Icons.check_circle,
            label: 'Delivered',
            isActive: orderStatus == 'Delivered',
            isCompleted: orderStatus == 'Delivered',
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Expanded(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 4,
                color: isActive ? KColors.primary : Colors.grey[200],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? KColors.primary : Colors.grey[200],
                ),
                child: Icon(
                  icon,
                  color: isActive ? Colors.white : Colors.grey[400],
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? KColors.primary : Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _statusPollingTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String displayStatus;

    switch (orderStatus) {
      case 'Ordered':
        statusColor = Colors.blue;
        displayStatus = "Ordered";
        break;
      case 'In Transit':
        statusColor = Colors.orange;
        displayStatus = "In Transit";
        break;
      case 'Delivered':
        statusColor = Colors.green;
        displayStatus = "Delivered";
        break;
      default:
        statusColor = Colors.grey;
        displayStatus = "Unknown";
        print('The status of order is unknown: $orderStatus');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tracking your order",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: KColors.primary,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 460, 
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: senderLatLng,
                    zoom: 14,
                  ),
                  onMapCreated: (controller) {
                    if (!_controller.isCompleted) {
                      try {
                        _controller.complete(controller);
                        _mapController = controller;
                        print("✅ Bản đồ được tạo thành công");
                      } catch (e) {
                        print("❌ Lỗi tạo bản đồ: $e");
                      }
                    } else {
                      _mapController = controller;
                      print("Bản đồ đã được tái sử dụng");
                    }
                  },
                  markers: _buildMarkers(),
                  polylines: _buildPolyline(),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                if (_routeError != null)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                      color: Colors.red.withOpacity(0.8),
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'Lỗi lộ trình: $_routeError',
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Shipment code:",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  shipmentCode ?? "N/A",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Order status:",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                GestureDetector(
                  onTap: _showStatusUpdateDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      border: Border.all(color: statusColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      displayStatus,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildTimeline(), 
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
