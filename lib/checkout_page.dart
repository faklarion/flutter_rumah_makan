import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'cart_item.dart';
import 'home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cart;

  const CheckoutPage({super.key, required this.cart});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedCity;
  String? _selectedCourier;
  List<Map<String, String>> _cities = [];
  List<String> _couriers = ['jne', 'pos', 'tiki'];
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
    _nameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadEmailFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('savedEmail') ?? 'No email saved';
    setState(() {
      _emailController.text = savedEmail;
    });
  }

  Future<void> _fetchCities() async {
    const apiKey = '631ae8aa8298df8899e1dd35dec81bbf';
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

  Future<void> _fetchShippingCost(String cityId, String courier) async {
    const apiKey = '631ae8aa8298df8899e1dd35dec81bbf';
    const originCityId = '501';
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

  double _calculateTotalBelanja() {
    return widget.cart
        .fold(0, (sum, item) => sum + (item.harga * item.quantity));
  }

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

  String _getCityName(String cityId) {
    final city = _cities.firstWhere(
      (city) => city['city_id'] == cityId,
      orElse: () => {'city_name': ''},
    );
    return city['city_name'] ?? '';
  }

  Future<void> _submitOrder() async {
    if (_selectedImage == null) {
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

      // Hitung total belanja dan total akhir
      final totalBelanja = _calculateTotalBelanja();
      final total = totalBelanja + _shippingCost;

      request.fields['nama'] = _nameController.text;
      request.fields['email'] = _emailController.text;
      request.fields['alamat'] = _addressController.text;
      request.fields['kota'] = _getCityName(_selectedCity ?? '');
      request.fields['kurir'] = _selectedCourier ?? '';
      request.fields['total_belanja'] = totalBelanja.toString();
      request.fields['ongkir'] = _shippingCost.toString();
      request.fields['total'] = total.toString(); // Total belanja + ongkir
      request.fields['jumlah_uang'] = _amountController.text;
      request.files.add(
        await http.MultipartFile.fromPath(
            'bukti_pembayaran', _selectedImage!.path),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10), // Jarak kecil
              SizedBox(
                height: 200, // Tinggi ListView dibatasi
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
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCity,
                hint: const Text('Pilih Kota'),
                isExpanded: true, // Tambahkan properti ini
                items: _cities.map((city) {
                  return DropdownMenuItem<String>(
                    value: city['city_id'], // Gunakan ID kota sebagai value
                    child: Text(
                      city['city_name']!,
                      overflow: TextOverflow
                          .ellipsis, // Potong teks jika terlalu panjang
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value;
                  });
                },
              ),

              DropdownButtonFormField<String>(
                value: _selectedCourier,
                hint: const Text('Pilih Kurir'),
                items: _couriers.map((courier) {
                  return DropdownMenuItem<String>(
                    value: courier,
                    child: Text(courier.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCourier = value;
                  });
                  // Panggil _fetchShippingCost jika kota juga sudah dipilih
                  if (_selectedCourier != null && _selectedCity != null) {
                    _fetchShippingCost(_selectedCity!, _selectedCourier!);
                  }
                },
              ),

              TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Jumlah Uang'),
                keyboardType: TextInputType.number,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Belanja: Rp ${_calculateTotalBelanja().toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Ongkir: Rp ${_shippingCost.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Total (Belanja + Ongkir): Rp ${(_calculateTotalBelanja() + _shippingCost).toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Unggah Bukti Pembayaran'),
              ),
              _selectedImage == null
                  ? const Text('Belum ada gambar')
                  : Image.file(_selectedImage!),
              ElevatedButton(
                onPressed: _submitOrder,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
