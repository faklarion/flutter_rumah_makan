import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  // Fungsi untuk membuka aplikasi SMS dengan pesan otomatis
  void _launchSms() async {
    const String nomorTelepon = '6285701727889';
    final String pesan = Uri.encodeComponent("Halo, saya ingin bertanya tentang menu di Warung Ajib.");
    final String smsUrl = "sms:$nomorTelepon?body=$pesan";

    if (await canLaunch(smsUrl)) {
      await launch(smsUrl);
    } else {
      throw 'Tidak dapat mengirim SMS';
    }
  }

  // Fungsi untuk membuka aplikasi WhatsApp dengan pesan otomatis
  void _launchWhatsApp() async {
    final String waUrl = "https://wa.me/6285701727889?text=${Uri.encodeComponent("Halo, saya ingin bertanya tentang menu di Warung Ajib.")}";

    if (await canLaunch(waUrl)) {
      await launch(waUrl);
    } else {
      throw 'Tidak dapat membuka WhatsApp';
    }
  }

  // Fungsi untuk membuka Google Maps
  void _launchMaps() async {
    const mapsUrl = "https://maps.app.goo.gl/NN8o2iUkY1v2fLXA7";
    if (await canLaunch(mapsUrl)) {
      await launch(mapsUrl);
    } else {
      throw 'Tidak dapat membuka peta';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Tambahkan tombol menu untuk SMS, WhatsApp, dan Maps
            ElevatedButton.icon(
              onPressed: _launchSms,
              icon: const Icon(Icons.sms),
              label: const Text('SMS'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _launchWhatsApp,
              icon: const Icon(Icons.phone),
              label: const Text('WhatsApp'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _launchMaps,
              icon: const Icon(Icons.map),
              label: const Text('Maps'),
            ),
          ],
        ),
      ),
    );
  }
}
