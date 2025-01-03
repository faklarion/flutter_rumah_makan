import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'order_detail_page.dart'; // Pastikan Anda mengimpor halaman detail
import 'package:intl/intl.dart';

class DataOrderPage extends StatefulWidget {
  const DataOrderPage({Key? key}) : super(key: key);

  @override
  _DataOrderPageState createState() => _DataOrderPageState();
}

class _DataOrderPageState extends State<DataOrderPage> {
  List<dynamic> _orders = [];
  List<dynamic> _filteredOrders = [];
  bool _isLoading = true;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchOrderHistory();
  }

  Future<void> _fetchOrderHistory() async {
    const apiUrl =
        'https://reportglm.com/api/riwayat_all.php'; // Ganti dengan URL API Anda
    final response = await http.get(Uri.parse('$apiUrl'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        setState(() {
          _orders = data['orders'];
          _filteredOrders = List.from(_orders); // Awalnya tampilkan semua data
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to fetch orders')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to connect to server')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _filterOrdersByDate() {
    if (_startDate == null || _endDate == null) {
      setState(() {
        _filteredOrders = List.from(_orders);
      });
      return;
    }

    setState(() {
      _filteredOrders = _orders.where((order) {
        final orderDate = DateTime.parse(order['created_at']).toLocal();
        final startDateUTC8 = _startDate!.toUtc().add(const Duration(hours: 7));
        final endDateUTC8 = _endDate!.toUtc().add(const Duration(hours: 7));
        return orderDate
                .isAfter(startDateUTC8.subtract(const Duration(days: 1))) &&
            orderDate.isBefore(endDateUTC8.add(const Duration(days: 1)));
      }).toList();
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        // Konversi waktu lokal ke UTC+8
        _startDate = picked.start.add(const Duration(hours: 8));
        _endDate = picked.end.add(const Duration(hours: 8));
        _filterOrdersByDate();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final filterText = (_startDate != null && _endDate != null)
        ? 'Menampilkan data dari ${dateFormat.format(_startDate!)} hingga ${dateFormat.format(_endDate!)}'
        : 'Menampilkan semua data';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Order'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _selectDateRange(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    filterText,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: _filteredOrders.isEmpty
                      ? const Center(child: Text('Tidak ada riwayat order'))
                      : ListView.builder(
                          itemCount: _filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = _filteredOrders[index];
                            return Card(
                              margin: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text('Order ID: ${order['id_order']}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total: Rp ${order['total']}'),
                                    Text(
                                        'Tanggal Order: ${order['created_at']}'),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Arahkan ke halaman detail order
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          OrderDetailPage(order: order),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
