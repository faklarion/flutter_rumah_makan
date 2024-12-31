import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_shared_preferences/blank_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  void toggleShowPassword() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  void toggleShowConfirmPassword() {
    setState(() {
      showConfirmPassword = !showConfirmPassword;
    });
  }

  void validateEmail() {
    setState(() {
      emailError =
          emailController.text.isEmpty ? "Email tidak boleh kosong" : null;
    });
  }

  void validatePassword() {
    if (passwordController.text.isEmpty) {
      setState(() {
        passwordError = "Password tidak boleh kosong";
      });
      return;
    }
    if (!RegExp(r"[A-Z]").hasMatch(passwordController.text)) {
      setState(() {
        passwordError = "Password harus mengandung huruf besar";
      });
      return;
    }
    if (!RegExp(r"[a-z]").hasMatch(passwordController.text)) {
      setState(() {
        passwordError = "Password harus mengandung huruf kecil";
      });
      return;
    }
    if (!RegExp(r"[0-9]").hasMatch(passwordController.text)) {
      setState(() {
        passwordError = "Password harus mengandung angka";
      });
      return;
    }
    setState(() {
      passwordError = null;
    });
  }

  void validateConfirmPassword() {
    setState(() {
      confirmPasswordError =
          confirmPasswordController.text != passwordController.text
              ? "Password tidak sama"
              : null;
    });
  }

  Future<void> _register() async {
    if (emailError == null &&
        passwordError == null &&
        confirmPasswordError == null) {
      // Ganti URL dengan endpoint API Anda
      final String apiUrl = 'https://reportglm.com/api/register.php';

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': emailController.text,
            'password': passwordController.text,
          }),
        );

        if (response.statusCode == 200) {
          // Jika registrasi berhasil, simpan data ke SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('savedEmail', emailController.text);
          await prefs.setString('savedPassword', passwordController.text);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else {
          // Jika ada kesalahan, tampilkan pesan
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.body}')),
          );
        }
      } catch (e) {
        // Tangani kesalahan jaringan atau kesalahan lainnya
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan, coba lagi')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Periksa kembali data yang dimasukkan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
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
                  onChanged: (_) => validateEmail(),
                  decoration: InputDecoration(
                    icon: const Icon(Icons.email),
                    labelText: 'Email',
                    errorText: emailError,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: passwordController,
                  onChanged: (_) {
                    validatePassword();
                    validateConfirmPassword();
                  },
                  obscureText: !showPassword,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.lock),
                    labelText: 'Password',
                    errorText: passwordError,
                    border: const OutlineInputBorder(),
                    suffixIcon: GestureDetector(
                      onTap: toggleShowPassword,
                      child: Icon(showPassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: confirmPasswordController,
                  onChanged: (_) => validateConfirmPassword(),
                  obscureText: !showConfirmPassword,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.check_circle),
                    labelText: 'Konfirmasi Password',
                    errorText: confirmPasswordError,
                    border: const OutlineInputBorder(),
                    suffixIcon: GestureDetector(
                      onTap: toggleShowConfirmPassword,
                      child: Icon(showConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _register,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Register'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
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
