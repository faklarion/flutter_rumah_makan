import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  Future<void> _loadCurrentData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      emailController.text = prefs.getString('savedEmail') ?? '';
    });
  }

  Future<void> _saveChanges() async {
    final String apiUrl =
        'https://reportglm.com/api/ganti-password.php'; // Ganti dengan URL API Anda

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': emailController.text,
        'new_password': newPasswordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perubahan berhasil disimpan!')),
        );
        Navigator.pop(
            context); // Kembali ke halaman sebelumnya setelah menyimpan
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Terjadi kesalahan saat menghubungi server.')),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(labelText: 'Password Baru'),
              obscureText: true,
            ),
            TextField(
              controller: confirmPasswordController,
              decoration:
                  const InputDecoration(labelText: 'Konfirmasi Password Baru'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }
}
