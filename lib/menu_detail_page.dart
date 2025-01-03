import 'package:flutter/material.dart';

class MenuDetailPage extends StatelessWidget {
  final String nama;
  final String keterangan; // Description
  final String gambar; // Image URL
  final double harga;

  const MenuDetailPage({
    super.key,
    required this.nama,
    required this.keterangan,
    required this.gambar,
    required this.harga,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nama),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gambar Menu
            Image.network(
              'https://reportglm.com/api/$gambar',
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 10),

            // Nama Menu
            Text(
              nama,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Deskripsi Menu
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                keterangan, // Display the description instead of the image URL
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),

            // Harga Menu
            Text(
              'Harga: Rp ${harga.toString()}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
