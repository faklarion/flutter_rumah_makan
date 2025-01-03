import 'package:flutter/material.dart';
import 'Admin.dart';
import 'admin_service.dart';

class DataAdminPage extends StatefulWidget {
  const DataAdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<DataAdminPage> {
  final AdminService _adminService = AdminService();
  List<Admin> _admins = [];
  bool _isLoading = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
  }

  Future<void> _fetchAdmins() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final admins = await _adminService.getAdmins();
      setState(() {
        _admins = admins;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createOrUpdateAdmin({Admin? admin}) async {
    final isEditing = admin != null;

    if (isEditing) {
      _emailController.text = admin.email;
      _passwordController.text = '';
    } else {
      _emailController.clear();
      _passwordController.clear();
    }

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEditing ? 'Edit Admin' : 'Tambah Admin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                if (isEditing) {
                  await _adminService.updateAdmin(
                    Admin(
                      id: admin.id,
                      email: _emailController.text,
                      password: _passwordController.text,
                    ),
                  );
                } else {
                  await _adminService.createAdmin(
                    Admin(
                      id: 0, // ID akan di-generate oleh server
                      email: _emailController.text,
                      password: _passwordController.text,
                    ),
                  );
                }
                await _fetchAdmins();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Operasi gagal: $e')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAdmin(Admin admin) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi'),
        content:
            Text('Apakah Anda yakin ingin menghapus admin ${admin.email}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _adminService.deleteAdmin(admin.id);
        await _fetchAdmins();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus admin: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAdmins,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _admins.length,
              itemBuilder: (context, index) {
                final admin = _admins[index];
                return Card(
                  child: ListTile(
                    title: Text(admin.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _createOrUpdateAdmin(admin: admin),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteAdmin(admin),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdateAdmin(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
