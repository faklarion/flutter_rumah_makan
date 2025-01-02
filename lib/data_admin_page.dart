import 'package:flutter/material.dart';

class DataAdminPage extends StatelessWidget {
  const DataAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Admin'),
      ),
      body: const Center(
        child: Text('Halaman Data Admin'),
      ),
    );
  }
}
