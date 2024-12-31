import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'cart_item.dart';
import 'home_page.dart';

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

  String? _selectedCity;
  List<Map<String, String>> _cities = [];
  double _shippingCost = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchCities();
  }

  @override
  void dispose() {
    _paymentController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
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

  void _submitOrder() {
    final totalAmount = _calculateTotal();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nota Pembayaran'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rincian Pembelian:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...widget.cart.map((item) => ListTile(
                      title: Text('${item.nama} x${item.quantity}'),
                      subtitle: Text('Harga: Rp ${item.harga * item.quantity}'),
                    )),
                const Divider(),
                Text(
                  'Total: Rp ${(totalAmount + _shippingCost).toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Nama: ${_nameController.text}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Alamat: ${_addressController.text}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Kota: ${getCityName(_selectedCity) ?? "-"}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Biaya Ongkir: Rp ${_shippingCost.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false,
                );
              },
              child: const Text('Selesai'),
            ),
          ],
        );
      },
    );
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
                  onPressed: _submitOrder,
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
