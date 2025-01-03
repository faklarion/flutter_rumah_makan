import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'Produk.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;
  final VoidCallback onRefresh;

  const ProductFormPage({
    Key? key,
    this.product,
    required this.onRefresh,
  }) : super(key: key);

  @override
  _ProductFormPageState createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _keteranganController = TextEditingController();
  File? _image;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _namaController.text = widget.product!.nama;
      _hargaController.text = widget.product!.harga.toString();
      _keteranganController.text = widget.product!.keterangan;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProduct() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    final isEdit = widget.product != null;
    final apiUrl = isEdit
        ? 'https://reportglm.com/api/update_product.php'
        : 'https://reportglm.com/api/create_product.php';

    final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    if (isEdit) request.fields['id_produk'] = widget.product!.idProduk;
    request.fields['nama'] = _namaController.text;
    request.fields['harga'] = _hargaController.text;
    request.fields['keterangan'] = _keteranganController.text;

    if (_image != null) {
      final imageFile =
          await http.MultipartFile.fromPath('gambar', _image!.path);
      request.files.add(imageFile);
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      widget.onRefresh();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isEdit ? 'Produk diperbarui' : 'Produk ditambahkan')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan produk')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? 'Edit Produk' : 'Tambah Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (value) =>
                    value!.isEmpty ? 'Masukkan nama produk' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _hargaController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Masukkan harga produk' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _keteranganController,
                decoration: const InputDecoration(labelText: 'Keterangan'),
                validator: (value) =>
                    value!.isEmpty ? 'Masukkan keterangan produk' : null,
              ),
              const SizedBox(height: 16),
              if (_image != null)
                Image.file(_image!, height: 200, fit: BoxFit.cover),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pilih Gambar'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text(widget.product != null ? 'Perbarui' : 'Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
