import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Admin.dart';

class AdminService {
  static const String baseUrl =
      'https://reportglm.com/api'; // Ganti dengan URL API Anda

  Future<List<Admin>> getAdmins() async {
    final response = await http.get(Uri.parse('$baseUrl/read_admin.php'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Admin.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data admin');
    }
  }

  Future<void> createAdmin(Admin admin) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create_admin.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(admin.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menambahkan admin');
    }
  }

  Future<void> updateAdmin(Admin admin) async {
    final response = await http.put(
      Uri.parse('$baseUrl/update_admin.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(admin.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal memperbarui admin');
    }
  }

  Future<void> deleteAdmin(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delete_admin.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_login': id}),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus admin');
    }
  }
}
