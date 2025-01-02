import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'cart_item.dart';
import 'home_page.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cart;

  const CheckoutPage({super.key, required this.cart});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _paymentController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();

  String? _selectedCity;
  List<Map<String, String>> _cities = [];
  double _shippingCost = 0.0;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadEmailFromPrefs();
    _fetchCities();
  }

  @override
  void dispose() {
    _paymentController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Fungsi untuk memilih gambar
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  Future<void> _loadEmailFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('savedEmail') ?? 'No email saved';
    setState(() {
      _emailController.text = savedEmail;
    });
  }

  Future<void> _fetchCities() async {
    const apiKey =
        '631ae8aa8298df8899e1dd35dec81bbf'; // Ganti dengan API Key Anda
    const url = 'https://api.rajaongkir.com/starter/city?key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cities = (data['rajaongkir']['results'] as List)
            .map((city) => {
                  'city_id': city['city_id'].toString(),
                  'city_name': city['city_name'].toString(),
                })
            .toList();
        setState(() {
          _cities = List<Map<String, String>>.from(cities);
        });
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (e) {
      print('Error fetching cities: $e');
    }
  }

  Future<void> _fetchShippingCost(String cityId) async {
    const apiKey =
        '631ae8aa8298df8899e1dd35dec81bbf'; // Ganti dengan API Key Anda
    const originCityId = '501'; // Ganti dengan city_id asal Anda
    const courier = 'jne'; // Pilih courier yang diinginkan
    final url = 'https://api.rajaongkir.com/starter/cost';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'key': apiKey,
        },
        body: {
          'origin': originCityId,
          'destination': cityId,
          'weight': '1000',
          'courier': courier,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cost =
            data['rajaongkir']['results'][0]['costs'][0]['cost'][0]['value'];
        setState(() {
          _shippingCost = double.parse(cost.toString());
        });
      } else {
        throw Exception('Failed to load shipping cost');
      }
    } catch (e) {
      print('Error fetching shipping cost: $e');
    }
  }

  double _calculateTotal() {
    return widget.cart
        .fold(0, (sum, item) => sum + (item.harga * item.quantity));
  }

  String? getCityName(String? cityId) {
    final city = _cities.firstWhere((c) => c['city_id'] == cityId,
        orElse: () => {} // Return an empty map instead of null
        );
    return city.isNotEmpty
        ? city['city_name']
        : null; // Check if map is not empty
  }

  Future<void> _submitOrder(File? image) async {
    if (image == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Bukti pembayaran belum dipilih!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://reportglm.com/api/orders.php'),
      );

      request.fields['nama'] = _nameController.text;
      request.fields['email'] = _emailController.text;
      request.fields['alamat'] = _addressController.text;
      request.fields['kota'] = _selectedCity ?? '';
      request.fields['total'] = (_calculateTotal() + _shippingCost).toString();

      request.files.add(
        await http.MultipartFile.fromPath('bukti_pembayaran', image.path),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Berhasil'),
            content: const Text('Pesanan berhasil disimpan!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Failed to save order');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Terjadi kesalahan: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _cancelOrder() {
    // Reset the form or navigate back to the previous screen
    setState(() {
      _nameController.clear();
      _addressController.clear();
      _selectedCity = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cart.length,
                itemBuilder: (context, index) {
                  final item = widget.cart[index];
                  return ListTile(
                    title: Text('${item.nama} x${item.quantity}'),
                    subtitle: Text('Harga: Rp ${item.harga * item.quantity}'),
                  );
                },
              ),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Alamat Pengiriman'),
            ),
            const SizedBox(height: 20),
            Expanded(
                child: DropdownButtonFormField<String>(
              value: _selectedCity,
              hint: const Text('Pilih Kota'),
              isExpanded: true, // Ensures the dropdown takes full width
              items: _cities.map((city) {
                return DropdownMenuItem<String>(
                  value: city['city_id'],
                  child: Text(city['city_name'] ?? ''),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCity = value;
                  _shippingCost = 0.0;
                });
                if (value != null) {
                  _fetchShippingCost(value);
                }
              },
            )),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pilih Bukti Pembayaran'),
            ),
            if (_selectedImage != null)
              Image.file(_selectedImage!, height: 100),
            Text(
              'Total: Rp ${(_calculateTotal() + _shippingCost).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // Align buttons horizontally
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_selectedImage != null) {
                      _submitOrder(
                          _selectedImage); // Panggil fungsi dengan parameter
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Error'),
                          content:
                              const Text('Bukti pembayaran belum dipilih!'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text('Cetak Pembayaran'),
                ),
                ElevatedButton(
                  onPressed: _cancelOrder, // Define your cancel action here
                  child: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .red, // Optional: Set the color for the cancel button
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
