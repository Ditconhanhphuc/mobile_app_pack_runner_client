import 'dart:io';
import 'package:client/data/constants.dart';
import 'package:client/views/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  String selectedSize = 'S';
  String paymentMethod = 'Sender Pays';
  File? imageFile;
  String? selectedTypeOfGoods;
  int usedVoucher = 0;
  double totalCost = 0.0;

  Future<void> _pickImage() async {
    try {
      var status = await Permission.photos.request();

      if (status.isGranted || status.isLimited) {
        final pickedFile =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          print("Đường dẫn ảnh đã chọn: ${pickedFile.path}");
          setState(() {
            imageFile = File(pickedFile.path);
          });
        }
      } else if (status.isDenied) {
        // Hiển thị thông báo hoặc hướng dẫn người dùng cấp quyền trong cài đặt
      } else if (status.isPermanentlyDenied) {
        // Mở cài đặt ứng dụng để người dùng cấp quyền
        await openAppSettings();
      }
    } catch (e) {
      print("Lỗi khi chọn ảnh: $e");
    }
  }

  @override
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
                _buildTextField(
                    'Phone number', 'assets/icons/create_order/phone.svg'),
                _buildTextField(
                    'Name', 'assets/icons/create_order/grey_user.svg'),
                _buildTextField(
                    'Address', 'assets/icons/create_order/address.svg'),
                _buildTextField('Province/City'),
                _buildTextField('District'),
                _buildTextField('Ward/Commune'),
                _buildTextField('Order Code (optional)'),
              ]),
              _buildSectionWithSpacing('Recipient Information',
                  'assets/icons/create_order/blue_personal.svg', [
                _buildTextField(
                    'Phone number', 'assets/icons/create_order/phone.svg'),
                _buildTextField(
                    'Name', 'assets/icons/create_order/grey_user.svg'),
                _buildTextField(
                    'Address', 'assets/icons/create_order/address.svg'),
                _buildTextField('Province/City'),
                _buildTextField('District'),
                _buildTextField('Ward/Commune'),
              ]),
              _buildPackageInformationSection(),
              _buildPaymentSection('Choose Payment Method',
                  'assets/icons/create_order/payment_method.svg', [
                _buildPaymentMethodSelector(),
              ]),
              _buildVoucherSection(),
              Container(
                padding: const EdgeInsets.only(top: 30.0, bottom: 40.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.trackingOrder);
                              },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(329, 50),
                      backgroundColor: KColors.primary, 
                      foregroundColor: Colors.white, 
                    ),
                    child: const Text('Create Order'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionWithSpacing(
      String title, String iconPath, List<Widget> children) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.only(bottom: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(title, iconPath),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String iconPath) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SvgPicture.asset(iconPath, width: 32, height: 32),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: KColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hintText, [String? iconPath]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: KColors.secondary,
            fontSize: 14,
          ),
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

  Widget _buildPaymentMethodSelector() {
    return Column(
      children: ['Sender Pays', 'Recipient Pays'].map((method) {
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
      decoration: BoxDecoration(
        color: Colors.white,
      ),
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
            Text('Total cost: $totalCost VND',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

        // Khung chứa Size + Ảnh + Weight
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFECECEC), width: 1),
            borderRadius: BorderRadius.circular(4.0),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Size Selection
              Row(
                children: [
                  const Text(
                    "Size:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: KColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ...['S', 'M', 'L', 'XL'].map((size) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        label: Text(
                          size,
                          style: TextStyle(
                            color: selectedSize == size
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        selected: selectedSize == size,
                        backgroundColor: const Color(0xFFCFE1E8),
                        selectedColor: KColors.primary,
                        onSelected: (bool selected) {
                          setState(() {
                            selectedSize = size;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 16),

              // Ảnh + Weight
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      print("Bắt đầu chọn ảnh...");
                      await _pickImage();
                      print("Ảnh đã được chọn.");
                    },
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
                              fit: BoxFit.cover,
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(imageFile!, fit: BoxFit.cover),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField('Weight')),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        _buildTextField('Total COD Amount'),
        const SizedBox(height: 16),

        // Dropdown chọn loại hàng
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: selectedTypeOfGoods == null ? 'Type of Goods' : null,
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFECECEC)),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            labelStyle: const TextStyle(color: KColors.secondary, fontSize: 14),
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
        _buildTextField('Notes'),
      ],
    ),
  );
}

}
