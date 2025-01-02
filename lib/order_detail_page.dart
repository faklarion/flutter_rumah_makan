import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class OrderDetailPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailPage({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  String? cityName;

  @override
  void initState() {
    super.initState();
    _fetchCityName();
  }

  Future<void> _printReceipt(Map<String, dynamic> order) async {
    final pdf = pw.Document();
    final name = await getCityName(widget.order['kota']);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Nota Pembelian',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Order ID: ${order['id_order']}'),
              pw.Text('Tanggal Order: ${order['created_at']}'),
              pw.Text('Nama: ${order['nama']}'),
              pw.Text('Alamat: ${order['alamat']}'),
              pw.Text('Kota: ${order['kota']}'),
              pw.Text('Total: Rp ${order['total']}'),
              pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<String> getCityName(String cityId) async {
    const String apiKey =
        '631ae8aa8298df8899e1dd35dec81bbf'; // Ganti dengan API key Anda
    const String apiUrl = 'https://api.rajaongkir.com/starter/city';

    final response = await http.get(
      Uri.parse('$apiUrl?city_id=$cityId'),
      headers: {'key': apiKey},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['rajaongkir']['status']['code'] == 200) {
        return data['rajaongkir']['results'][0]
            ['city_name']; // Mendapatkan nama kota
      } else {
        throw Exception('Failed to load city name');
      }
    } else {
      throw Exception('Failed to connect to API');
    }
  }

  // Memanggil API RajaOngkir untuk mendapatkan nama kota
  Future<void> _fetchCityName() async {
    try {
      final name = await getCityName(widget.order['kota']);
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          cityName = name;
        });
      }
    } catch (e) {
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          cityName = 'Error'; // Handle the error appropriately
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Order')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${widget.order['id_order']}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Tanggal Order: ${widget.order['created_at']}',
                style: const TextStyle(fontSize: 16)),
            Text('Nama: ${widget.order['nama']}',
                style: const TextStyle(fontSize: 16)),
            Text('Alamat: ${widget.order['alamat']}',
                style: const TextStyle(fontSize: 16)),
            Text('Kota: ${widget.order['kota']}',
                style: const TextStyle(fontSize: 16)),
            Text('Total: Rp ${widget.order['total']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            if (widget.order['bukti_pembayaran'] != null &&
                widget.order['bukti_pembayaran'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bukti Pembayaran:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Image.network(
                    'https://reportglm.com/api/uploads/${widget.order['bukti_pembayaran']}',
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? (loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1))
                                : null,
                          ),
                        );
                      }
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons
                          .error); // Menampilkan error jika gambar gagal dimuat
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _printReceipt(widget.order);
                    },
                    child: const Text('Cetak Nota'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
