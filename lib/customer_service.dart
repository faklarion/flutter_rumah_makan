import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Customer.dart';

class CustomerService {
  static const String baseUrl =
      'https://reportglm.com/api'; // Ganti dengan URL API Anda

  Future<List<Customer>> getCustomers() async {
    final response = await http.get(Uri.parse('$baseUrl/read_customer.php'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Customer.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data Customer');
    }
  }

  Future<void> createCustomer(Customer customer) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create_customer.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(customer.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menambahkan Customer');
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    final response = await http.put(
      Uri.parse('$baseUrl/update_customer.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(customer.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal memperbarui Customer');
    }
  }

  Future<void> deleteCustomer(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delete_customer.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_login': id}),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus Customer');
    }
  }
}
