import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_shared_preferences/home_page.dart';
import 'package:flutter_shared_preferences/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Tambahkan import ini

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoggedIn = false;
  bool showPassword = false;

  @override
  void initState() {
    super.initState();
    // Cek status login jika diperlukan
  }

  Future<void> _login() async {
    final email = emailController.text;
    final password = passwordController.text;

    final response = await http.post(
      Uri.parse(
          'https://reportglm.com/api/login.php'), // Ganti dengan URL API Anda
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Jika server mengembalikan respons OK, simpan token atau informasi pengguna
      final data = jsonDecode(response.body);

      // Simpan email ke SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('savedEmail', email); // Simpan email

      // Misalnya, simpan token ke SharedPreferences jika diperlukan
      // await prefs.setString('token', data['token']);
      _navigateToHomePage();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email atau password salah')),
      );
    }
  }

  void _navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  void _navigateToRegisterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  void toggleShowPassword() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.email),
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: !showPassword,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.lock),
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: toggleShowPassword,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _login,
                    icon: const Icon(Icons.login),
                    label: const Text('Login'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: _navigateToRegisterPage,
                    child: const Text('Register'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
