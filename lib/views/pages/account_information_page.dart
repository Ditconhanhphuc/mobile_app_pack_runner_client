import 'package:client/data/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({Key? key}) : super(key: key);

  @override
  State<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for profile
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();

  // Controllers for address
  final addressController = TextEditingController();
  final provinceController = TextEditingController();
  final districtController = TextEditingController();
  final wardController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  bool isDefault = true;
  bool isLoading = true;
  bool addressExists = false;
  String? token;
  String? addressId;

  @override
  void initState() {
    super.initState();
    loadTokenAndFetchData();
  }

  Future<void> loadTokenAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access_token');

    // print("\u{1F9EA} Token from SharedPreferences: $token");
    prefs.getKeys().forEach((key) {
      // print('\u{1F511} $key: ${prefs.getString(key)}');
    });

    if (token == null || token == 'null' || token!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Not logged in")),
      );
      return;
    }

    await fetchProfileAndAddress();
  }

  Future<void> fetchProfileAndAddress() async {
    try {
      final headers = {'Authorization': 'Bearer $token'};

      final profileRes = await http.get(
        Uri.parse('${KConstants.baseUrl}/users/profile/'),
        headers: headers,
      );

      final addressRes = await http.get(
        Uri.parse('${KConstants.baseUrl}/user/address/'),
        headers: headers,
      );

      if (profileRes.statusCode == 200) {
        final profileData = jsonDecode(profileRes.body)['data'];
        nameController.text = profileData['name'] ?? '';
        emailController.text = profileData['email'] ?? '';
        phoneController.text = profileData['phone_number'] ?? '';
        dobController.text = profileData['date_of_birth'] ?? '';
      }

      if (addressRes.statusCode == 200) {
        final addressList = jsonDecode(addressRes.body)['data'] as List;

        if (addressList.isNotEmpty) {
          final defaultAddress = addressList.firstWhere(
            (addr) => addr['is_default'] == true,
            orElse: () => addressList[0],
          );

          addressId = defaultAddress['id'].toString();
          addressController.text = defaultAddress['address'] ?? '';
          wardController.text = defaultAddress['ward'] ?? '';
          districtController.text = defaultAddress['district'] ?? '';
          provinceController.text = defaultAddress['province'] ?? '';
          latitudeController.text = defaultAddress['latitude'] ?? '';
          longitudeController.text = defaultAddress['longitude'] ?? '';
          isDefault = defaultAddress['is_default'] ?? true;
          addressExists = true;
        }
      }
    } catch (e) {
      print("Error loading data: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> getCoordinatesFromAddress(String address) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=${KConstants.googleMapsApiKey}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final results = json['results'];

        if (results != null && results.isNotEmpty) {
          final location = results[0]['geometry']['location'];
          final lat = location['lat'].toString();
          final lng = location['lng'].toString();

          setState(() {
            latitudeController.text = lat;
            longitudeController.text = lng;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Coordinates retrieved successfully")),
          );
        } else {
          throw "No results found";
        }
      } else {
        throw "Error calling API";
      }
    } catch (e) {
      print("Error retrieving coordinates: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to retrieve coordinates")),
      );
    }
  }

  Future<void> saveInfo() async {
    if (!_formKey.currentState!.validate()) return;

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final profileBody = jsonEncode({
      "name": nameController.text,
      "email": emailController.text,
      "phone_number": phoneController.text,
      "date_of_birth": dobController.text,
    });

    final addressBody = jsonEncode({
      "address": addressController.text,
      "ward": wardController.text,
      "district": districtController.text,
      "province": provinceController.text,
      "latitude": latitudeController.text,
      "longitude": longitudeController.text,
      "is_default": isDefault,
    });

    final profileRes = await http.put(
      Uri.parse('${KConstants.baseUrl}/users/profile/'),
      headers: headers,
      body: profileBody,
    );

    final addressRes = addressExists && addressId != null
        ? await http.patch(
            Uri.parse('${KConstants.baseUrl}/user/address/$addressId/'),
            headers: headers,
            body: addressBody,
          )
        : await http.post(
            Uri.parse('${KConstants.baseUrl}/user/address/'),
            headers: headers,
            body: addressBody,
          );

    if (profileRes.statusCode == 200 &&
        (addressRes.statusCode == 200 || addressRes.statusCode == 201)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Information updated successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred while updating")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Account Information")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    sectionTitle("Personal Information"),
                    buildTextField(nameController, "Full Name"),
                    buildTextField(emailController, "Email"),
                    buildTextField(phoneController, "Phone Number"),
                    buildTextField(dobController, "Date of Birth (YYYY-MM-DD)"),
                    const SizedBox(height: 24),
                    sectionTitle("Address"),
                    buildTextField(addressController, "Detailed Address"),
                    buildTextField(wardController, "Ward"),
                    buildTextField(districtController, "District"),
                    buildTextField(provinceController, "City/Province"),
                    ElevatedButton(
                      onPressed: () async {
                        final fullAddress =
                            '${addressController.text}, ${wardController.text}, ${districtController.text}, ${provinceController.text}';
                        await getCoordinatesFromAddress(fullAddress);
                      },
                      child: const Text("Get Coordinates from Address"),
                    ),
                    buildTextField(latitudeController, "Latitude"),
                    buildTextField(longitudeController, "Longitude"),
                    CheckboxListTile(
                      title: const Text("Set as Default Address", style: TextStyle(fontSize: 14),),
                      value: isDefault,
                      onChanged: (val) {
                        setState(() {
                          isDefault = val ?? true;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: saveInfo,
                      child: const Text("Save Information"),
                    ),
                    const SizedBox(height: 26),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? "This field cannot be empty" : null,
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}