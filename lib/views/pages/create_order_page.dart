import 'dart:convert';
import 'dart:io';
import 'package:client/data/constants.dart';
import 'package:client/views/pages/home_page.dart';
import 'package:client/views/pages/tracking_order_page.dart';
import 'package:client/views/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as http_io;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // Thêm import này vào đầu file

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  String paymentMethod = 'sender';
  File? imageFile;
  String? selectedTypeOfGoods;
  int usedVoucher = 0;
  double totalCost = 0.0;
  String? token;

  final TextEditingController senderPhoneController = TextEditingController();
  final TextEditingController senderNameController = TextEditingController();
  final TextEditingController senderAddressController = TextEditingController();
  final TextEditingController senderProvinceController =
      TextEditingController();
  final TextEditingController senderDistrictController =
      TextEditingController();
  final TextEditingController senderWardController = TextEditingController();
  final TextEditingController senderOrderCodeController =
      TextEditingController();
  final senderLatitudeController = TextEditingController();
  final senderLongitudeController = TextEditingController();

  final TextEditingController receiverPhoneController = TextEditingController();
  final TextEditingController receiverNameController = TextEditingController();
  final TextEditingController receiverAddressController =
      TextEditingController();
  final TextEditingController receiverDistrictController =
      TextEditingController();
  final TextEditingController receiverWardController = TextEditingController();
  final TextEditingController receiverProvinceController =
      TextEditingController();
  final receiverLatitudeController = TextEditingController();
  final receiverLongitudeController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  final TextEditingController codAmountController = TextEditingController();

  String? selectedSizeDisplay;
  String? selectedSize;
  String convertSize(String sizeDisplay) {
    switch (sizeDisplay) {
      case 'S':
        return 'Small';
      case 'M':
        return 'Medium';
      case 'L':
        return 'Large';
      case 'XL':
        return 'X-Large';
      default:
        return 'Small';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchSenderInfo();
    selectedSizeDisplay = 'S';
    selectedSize = convertSize(selectedSizeDisplay!);
    selectedTypeOfGoods = 'Food';
    weightController.addListener(() {
      print('Weight changed: ${weightController.text}'); // Debug để kiểm tra
      calculateCost();
    });
  }

  Future<void> _loadTokenAndFetchSenderInfo() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access_token');

    if (token == null || token!.isEmpty || token == 'null') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Chưa đăng nhập")),
        );
      }
      return;
    }

    await fetchSenderInfo();
  }

  Future<void> _pickImage() async {
    var status = await Permission.photos.request();
    if (status.isGranted || status.isLimited) {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          imageFile = File(pickedFile.path);
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không có ảnh được chọn")),
        );
      }
    }
    // } else if (status.isPermanentlyDenied) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //           content: Text("Vui lòng cấp quyền truy cập ảnh trong cài đặt")),
    //     );
    //   }
    //   await openAppSettings();
    // }
  }

  Future<void> fetchSenderInfo() async {
    try {
      final headers = {'Authorization': 'Bearer $token'};
      final profileRes = await http.get(
          Uri.parse('${KConstants.baseUrl}/users/profile/'),
          headers: headers);
      final addressRes = await http.get(
          Uri.parse('${KConstants.baseUrl}/user/address/'),
          headers: headers);

      if (profileRes.statusCode == 200) {
        final profileData = jsonDecode(profileRes.body)['data'];
        senderNameController.text = profileData['name'] ?? '';
        senderPhoneController.text = profileData['phone_number'] ?? '';
      } else {
        throw 'Lỗi lấy thông tin hồ sơ: ${profileRes.statusCode}';
      }

      if (addressRes.statusCode == 200) {
        final addressList = jsonDecode(addressRes.body)['data'] as List;
        if (addressList.isNotEmpty) {
          final defaultAddress = addressList.firstWhere(
            (addr) => addr['is_default'] == true,
            orElse: () => addressList[0],
          );
          senderAddressController.text = defaultAddress['address'] ?? '';
          senderProvinceController.text = defaultAddress['province'] ?? '';
          senderDistrictController.text = defaultAddress['district'] ?? '';
          senderWardController.text = defaultAddress['ward'] ?? '';
        }
      } else {
        throw 'Lỗi lấy thông tin địa chỉ: ${addressRes.statusCode}';
      }
    } catch (e) {
      print("Lỗi lấy thông tin sender: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không thể lấy thông tin người gửi")),
        );
      }
    }
  }

  Future<void> getCoordinatesFromAddress({
    required String address,
    required TextEditingController latitudeController,
    required TextEditingController longitudeController,
    required BuildContext context,
  }) async {
    final urlKey =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=${KConstants.googleMapsApiKey}';
    print('Geocoding URL: $urlKey');

    late http_io.IOClient client;
    try {
      client = http_io.IOClient(HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true);
      final response = await client.get(Uri.parse(urlKey)).timeout(const Duration(seconds: 15));
      print('Geocoding response status: ${response.statusCode}');
      print('Geocoding response body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print('Parsed JSON: $json');

        final status = json['status']?.toString() ?? '';
        if (status != 'OK') {
          throw "API error: $status - ${json['error_message'] ?? 'Unknown error'}";
        }

        final results = json['results'];
        if (results != null && results.isNotEmpty) {
          final location = results[0]['geometry']['location'];
          final lat = location['lat']?.toString() ?? '';
          final lng = location['lng']?.toString() ?? '';

          if (lat.isEmpty || lng.isEmpty) {
            throw "Tọa độ rỗng hoặc không hợp lệ";
          }

          if (context.mounted) {
            latitudeController.text = lat;
            longitudeController.text = lng;
            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(content: Text("Lấy tọa độ thành công")),
            // );
          }
        } else {
          throw "Không tìm thấy kết quả: $status - ${json['error_message'] ?? ''}";
        }
      } else {
        throw "Lỗi khi gọi API: ${response.statusCode} - ${response.body}";
      }
    } catch (e, stackTrace) {
      print('Lỗi khi lấy tọa độ: $e');
      print('Stack trace: $stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Không lấy được tọa độ: $e")),
        );
      }
    } finally {
      client.close();
    }
  }

  Future<void> calculateCost() async {
    if (token == null || token!.isEmpty) {
      print('Token is missing or empty');
      if (mounted) {
        setState(() {
          totalCost = 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng đăng nhập để tính chi phí")),
        );
      }
      return;
    }

    if (weightController.text.isEmpty ||
        senderAddressController.text.isEmpty ||
        senderDistrictController.text.isEmpty ||
        senderWardController.text.isEmpty ||
        senderProvinceController.text.isEmpty ||
        receiverAddressController.text.isEmpty ||
        receiverDistrictController.text.isEmpty ||
        receiverWardController.text.isEmpty ||
        receiverProvinceController.text.isEmpty) {
      print('Missing required fields for cost calculation');
      if (mounted) {
        setState(() {
          totalCost = 0.0;
        });
      }
      return;
    }

    final shipmentData = {
      "weight": int.tryParse(weightController.text) ?? 0,
      "size": convertSize(selectedSizeDisplay ?? 'S'),
      "receiver_address": receiverAddressController.text,
      "receiver_province": receiverProvinceController.text,
      "receiver_district": receiverDistrictController.text,
      "receiver_ward": receiverWardController.text,
      "sender_address": senderAddressController.text,
      "sender_province": senderProvinceController.text,
      "sender_district": senderDistrictController.text,
      "sender_ward": senderWardController.text,
    };

    print('Sending cost estimation request with data: $shipmentData');

    final url =
        Uri.parse('${KConstants.baseUrl}/orders/estimate-shipping-cost/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(shipmentData),
      );

      print('API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newCost = (data['data']['total_amount'] ?? 0.0).toDouble();
        if (mounted) {
          setState(() {
            totalCost = newCost;
            print('Total cost updated to: $totalCost');
          });
        }
      } else {
        print(
            '⚠️ Error calculating cost: ${response.statusCode} - ${response.body}');
        if (mounted) {
          setState(() {
            totalCost = 0.0;
          });
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text("Lỗi khi tính toán chi phí")),
          // );
        }
      }
    } catch (e) {
      print('❌ Exception calculating cost: $e');
      if (mounted) {
        setState(() {
          totalCost = 0.0;
        });
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text("Lỗi khi kết nối với server")),
        // );
      }
    }
  }

  bool isLoading = false;
  Future<Map<String, dynamic>> createOrder({
    required String token,
    required String paymentMethod,
    required Map<String, dynamic> shipmentData,
  }) async {
    final url = Uri.parse('${KConstants.baseUrl}/orders/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      "payments": [
        {"payment_method": paymentMethod}
      ],
      "shipments": [shipmentData]
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Order created successfully');
        print('Response: ${response.body}');
        return {
          'success': true,
          'response': response.body,
        };
      } else {
        print(
            "Failed to create order: ${response.statusCode} - ${response.body}");
        return {
          'success': false,
          'response': response.body,
        };
      }
    } catch (e) {
      print("Exception creating order: $e");
      return {
        'success': false,
        'response': null,
      };
    }
  }

  Future<void> handleCreateOrder() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final fullSenderAddress =
          '${senderAddressController.text}, ${senderWardController.text}, ${senderDistrictController.text}, ${senderProvinceController.text}';
      final fullReceiverAddress =
          '${receiverAddressController.text}, ${receiverWardController.text}, ${receiverDistrictController.text}, ${receiverProvinceController.text}';

      if (token == null || token!.isEmpty || token == 'null') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Bạn chưa đăng nhập")),
          );
        }
        return;
      }

      await getCoordinatesFromAddress(
        address: fullSenderAddress,
        latitudeController: senderLatitudeController,
        longitudeController: senderLongitudeController,
        context: context,
      );
      await getCoordinatesFromAddress(
        address: fullReceiverAddress,
        latitudeController: receiverLatitudeController,
        longitudeController: receiverLongitudeController,
        context: context,
      );

      if (!mounted) return;

      if (receiverNameController.text.isEmpty ||
          receiverPhoneController.text.isEmpty ||
          receiverAddressController.text.isEmpty) {
        return;
      }

      if (senderLatitudeController.text.isEmpty ||
          senderLongitudeController.text.isEmpty ||
          receiverLatitudeController.text.isEmpty ||
          receiverLongitudeController.text.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Không thể lấy tọa độ từ địa chỉ")),
          );
        }
        return;
      }

      final shipmentData = {
        "shipment_type": selectedTypeOfGoods ?? 'Food',
        "size": convertSize(selectedSizeDisplay ?? 'S'),
        "weight": int.tryParse(weightController.text) ?? 0,
        "note": noteController.text,
        "receiver_name": receiverNameController.text,
        "receiver_phone_number": receiverPhoneController.text,
        "receiver_address": receiverAddressController.text,
        "receiver_province": receiverProvinceController.text,
        "receiver_district": receiverDistrictController.text,
        "receiver_ward": receiverWardController.text,
        "receiver_longitude": receiverLongitudeController.text,
        "receiver_latitude": receiverLatitudeController.text,
        "sender_name": senderNameController.text,
        "sender_address": senderAddressController.text,
        "sender_province": senderProvinceController.text,
        "sender_district": senderDistrictController.text,
        "sender_ward": senderWardController.text,
        "sender_longitude": senderLongitudeController.text,
        "sender_latitude": senderLatitudeController.text,
        "cod_amount": int.tryParse(codAmountController.text) ?? 0,
      };

      await calculateCost();

      if (!mounted) return;

      final result = await createOrder(
        token: token!,
        paymentMethod: paymentMethod,
        shipmentData: shipmentData,
      );

      if (!mounted) return;

      if (result['success']) {
        if (result['response'] == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Lỗi: Không nhận được dữ liệu phản hồi")),
            );
          }
          return;
        }

        try {
          print('Raw response: ${result['response']}'); // Debug
          final responseData = jsonDecode(result['response']);
          final orderId = responseData['data']['id']?.toString() ?? '';
          print('Order ID: $orderId'); // Debug

          if (orderId.isEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Lỗi: Không tìm thấy ID đơn hàng")),
              );
            }
            return;
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Tạo đơn hàng thành công")),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TrackingOrderPage(
                  orderData: {
                    "order_id": orderId,
                    "sender_latitude": senderLatitudeController.text,
                    "sender_longitude": senderLongitudeController.text,
                    "receiver_latitude": receiverLatitudeController.text,
                    "receiver_longitude": receiverLongitudeController.text,
                    "sender_address": fullSenderAddress,
                    "receiver_address": fullReceiverAddress,
                    "status": responseData['order_status'] ?? "Ordered",
                  },
                ),
              ),
            );
          }
        } catch (e) {
          print('Error parsing response: $e');
          if (mounted) {
            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(content: Text("Lỗi xử lý dữ liệu đơn hàng")),
            // );
          }
        }
      } else {
        print('Create order failed: ${result['response']}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tạo đơn hàng thất bại")),
          );
        }
      }
    } catch (e, stackTrace) {
      print("Error creating order: $e");
      print("Stack trace: $stackTrace");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã có lỗi xảy ra, vui lòng thử lại")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
  // Future<bool> createOrder({
  //   required String token,
  //   required String paymentMethod,
  //   required Map<String, dynamic> shipmentData,
  // }) async {
  //   final url = Uri.parse('${KConstants.baseUrl}/orders/');
  //   final headers = {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $token',
  //   };

  //   final body = jsonEncode({
  //     "payments": [
  //       {"payment_method": paymentMethod}
  //     ],
  //     "shipments": [shipmentData]
  //   });

  //   try {
  //     final response = await http.post(url, headers: headers, body: body);

  //     if (response.statusCode == 201 || response.statusCode == 200) {
  //       print('Order created successfully');
  //       print('total cost: ${totalCost}');
  //       return true;
  //     } else {
  //       print(
  //           "Failed to create order: ${response.statusCode} - ${response.body}");
  //       return false;
  //     }
  //   } catch (e) {
  //     print("Exception creating order: $e");
  //     return false;
  //   }
  // }
  @override
  @override
  void dispose() {
    senderPhoneController.dispose();
    senderNameController.dispose();
    senderAddressController.dispose();
    senderProvinceController.dispose();
    senderDistrictController.dispose();
    senderWardController.dispose();
    senderOrderCodeController.dispose();
    senderLatitudeController.dispose();
    senderLongitudeController.dispose();
    receiverPhoneController.dispose();
    receiverNameController.dispose();
    receiverAddressController.dispose();
    receiverDistrictController.dispose();
    receiverWardController.dispose();
    receiverProvinceController.dispose();
    receiverLatitudeController.dispose();
    receiverLongitudeController.dispose();
    weightController.dispose();
    noteController.dispose();
    codAmountController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Order',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 0.5, color: Color(0xFFDCDCDC)),
        ),
        backgroundColor: Color(0xFFF2F2F3),
      ),
      body: Container(
        color: Color(0xFFF2F2F3),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionWithSpacing('Sender Information',
                  'assets/icons/create_order/blue_personal.svg', [
                _buildTextField('Phone number',
                    controller: senderPhoneController,
                    iconPath: 'assets/icons/create_order/phone.svg'),
                _buildTextField('Name',
                    controller: senderNameController,
                    iconPath: 'assets/icons/create_order/grey_user.svg'),
                _buildTextField('Address',
                    controller: senderAddressController,
                    iconPath: 'assets/icons/create_order/address.svg'),
                _buildTextField('District',
                    controller: senderDistrictController),
                _buildTextField('Ward/Commune',
                    controller: senderWardController),
                _buildTextField('Province/City',
                    controller: senderProvinceController),
                _buildTextField('Order Code (optional)',
                    controller: senderOrderCodeController),
              ]),
              _buildSectionWithSpacing('Recipient Information',
                  'assets/icons/create_order/blue_personal.svg', [
                _buildTextField('Phone number',
                    controller: receiverPhoneController,
                    iconPath: 'assets/icons/create_order/phone.svg'),
                _buildTextField('Name',
                    controller: receiverNameController,
                    iconPath: 'assets/icons/create_order/grey_user.svg'),
                _buildTextField('Address',
                    controller: receiverAddressController,
                    iconPath: 'assets/icons/create_order/address.svg'),
                _buildTextField('District',
                    controller: receiverDistrictController),
                _buildTextField('Ward/Commune',
                    controller: receiverWardController),
                _buildTextField('Province/City',
                    controller: receiverProvinceController),
              ]),
              _buildPackageInformationSection(),
              _buildPaymentSection('Choose Payment Method',
                  'assets/icons/create_order/payment_method.svg', [
                _buildPaymentMethodSelector(),
              ]),
              _buildVoucherSection(),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText,
      {TextEditingController? controller, String? iconPath}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: KColors.secondary, fontSize: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: const BorderSide(color: Color(0xFFECECEC)),
          ),
          prefixIcon: iconPath != null
              ? Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SvgPicture.asset(iconPath, width: 20, height: 20),
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14.0),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String iconPath) {
    return Row(
      children: [
        SvgPicture.asset(iconPath, width: 32, height: 32),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: KColors.primary)),
      ],
    );
  }

  Widget _buildSectionWithSpacing(
      String title, String iconPath, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 10, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(title, iconPath),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      children: ['cod', 'vietqr'].map((method) {
        return RadioListTile(
          title: Text(method),
          value: method,
          groupValue: paymentMethod,
          onChanged: (value) {
            setState(() {
              paymentMethod = value.toString();
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildPaymentSection(
      String title, String iconPath, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(title, iconPath),
          ...children,
        ],
      ),
    );
  }

  Widget _buildVoucherSection() {
    return Container(
      padding: const EdgeInsets.only(top: 16.0),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle(
                    'Voucher', 'assets/icons/create_order/voucher.svg'),
                Row(
                  children: [
                    Text('$usedVoucher',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(' Vouchers Used', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Total cost: ${totalCost.toStringAsFixed(2)} VND',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageInformationSection() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.only(bottom: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Package Information',
              'assets/icons/create_order/blue_package.svg'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFECECEC)),
              borderRadius: BorderRadius.circular(4.0),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text("Size:",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: KColors.secondary)),
                    const SizedBox(width: 16),
                    ...['S', 'M', 'L', 'XL'].map((sizeDisplay) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          label: Text(
                            sizeDisplay,
                            style: TextStyle(
                              color: selectedSizeDisplay == sizeDisplay
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          selected: selectedSizeDisplay == sizeDisplay,
                          backgroundColor: const Color(0xFFCFE1E8),
                          selectedColor: KColors.primary,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                selectedSizeDisplay = sizeDisplay;
                                selectedSize = convertSize(sizeDisplay);
                              } else {
                                selectedSizeDisplay = null;
                                selectedSize = null;
                              }
                              calculateCost(); // Trigger cost calculation on size change
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: imageFile == null
                            ? SvgPicture.asset(
                                'assets/icons/create_order/add_image.svg',
                                fit: BoxFit.cover)
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child:
                                    Image.file(imageFile!, fit: BoxFit.cover),
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                        'Weight (kg)',
                        controller: weightController,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // _buildTextField('Total COD Amount'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: selectedTypeOfGoods == null ? 'Type of Goods' : null,
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFECECEC)),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              labelStyle:
                  const TextStyle(color: KColors.secondary, fontSize: 14),
            ),
            value: selectedTypeOfGoods,
            items: ['Food', 'Cloth', 'Electronic'].map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedTypeOfGoods = newValue;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildTextField('Notes', controller: noteController),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.only(top: 30.0, bottom: 40.0),
      color: Colors.white,
      child: Center(
        child: ElevatedButton(
          onPressed: handleCreateOrder,
          // () =>
          //     Navigator.pushNamed(context, AppRoutes.trackingOrder),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(329, 50),
            backgroundColor: KColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Create Order'),
        ),
      ),
    );
  }
}
