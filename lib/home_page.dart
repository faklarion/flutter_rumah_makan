import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'menu_detail_page.dart'; // Import halaman detail menu
import 'cart_item.dart';
import 'cart_page.dart';
import 'edit_profile_page.dart';
import 'riwayat_order.dart';
import 'blank_screen.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _menuList = [];
  List<CartItem> _cart = []; // List for cart items
  String email = '';

  @override
  void initState() {
    super.initState();
    _loadMenuData();
    _loadEmail(); // Panggil fungsi untuk memuat email
  }

  // Add this function to add an item to the cart
  void _addToCart(Map<String, dynamic> menuItem) {
    setState(() {
      final existingItem = _cart.firstWhere(
        (item) => item.nama == menuItem['nama'],
        orElse: () => CartItem(nama: '', gambar: '', harga: 0),
      );

      if (existingItem.nama.isEmpty) {
        _cart.add(CartItem(
          nama: menuItem['nama'],
          gambar: menuItem['gambar'],
          harga: double.parse(menuItem['harga']), // Convert String to double
          quantity: 1,
        ));
      } else {
        existingItem.quantity++;
      }
    });

    // Show a Snackbar message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${menuItem['nama']} telah ditambahkan ke keranjang.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _loadEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('savedEmail') ?? 'Guest';
    });
  }

  Future<void> _loadMenuData() async {
    final response =
        await http.get(Uri.parse('https://reportglm.com/api/produk.php'));

    if (response.statusCode == 200) {
      // Jika server mengembalikan respons OK, parse data
      final jsonResponse = json.decode(response.body);

      // Access the list of products from the 'data' key
      setState(() {
        _menuList = jsonResponse['data']; // Access the list of products
      });
    } else {
      // Jika server tidak mengembalikan respons OK, lempar exception
      throw Exception('Failed to load menu data');
    }
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Atur kembali status isLoggedIn menjadi false
    await prefs.setBool('isLoggedIn', false);

    // Arahkan kembali ke halaman login setelah logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  final String imageUrl = 'assets/images/warung_ajib.jpg'; // Path ke gambar

  void _launchSms() async {
    const smsUrl = "sms:+628123456789";
    if (await canLaunch(smsUrl)) {
      await launch(smsUrl);
    } else {
      throw 'Could not send SMS';
    }
  }

  void _launchCall() async {
    const telUrl = "tel:+628123456789";
    if (await canLaunch(telUrl)) {
      await launch(telUrl);
    } else {
      throw 'Could not make a call';
    }
  }

  void _launchMaps() async {
    const mapsUrl = "https://maps.app.goo.gl/d4nF2gxJKBvhcJxe6";
    if (await canLaunch(mapsUrl)) {
      await launch(mapsUrl);
    } else {
      throw 'Could not open maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalCartItems = _cart.fold(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, $email'),
        automaticallyImplyLeading: false,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartPage(
                        cart: _cart,
                        onCartUpdated: (updatedCart) {
                          setState(() {
                            _cart = updatedCart;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              if (totalCartItems > 0)
                Positioned(
                  right: 0,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$totalCartItems',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'editProfile':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfilePage(),
                    ),
                  );
                  break;
                case 'sms':
                  _launchSms();
                  break;
                case 'riwayat':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OrderHistoryPage()),
                  );
                  break;
                case 'call':
                  _launchCall();
                  break;
                case 'maps':
                  _launchMaps();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'editProfile',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Edit Profile'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'sms',
                child: Row(
                  children: [
                    Icon(Icons.sms, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('SMS'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'riwayat',
                child: Row(
                  children: [
                    Icon(Icons.update, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Riwayat Order'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'call',
                child: Row(
                  children: [
                    Icon(Icons.phone, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Call'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'maps',
                child: Row(
                  children: [
                    Icon(Icons.map, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Maps'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gambar Warung Ajib
            Image.asset(
              imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 10),

            // Teks Nama Warung
            const Text(
              'Warung Ajib',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Deskripsi Warung
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Warung Ajib adalah tempat makan yang menyajikan berbagai masakan kuliner. '
                'Kami berkomitmen untuk memberikan pengalaman kuliner terbaik bagi semua pelanggan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),

            // Judul Daftar Menu
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Daftar Menu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Daftar Menu (GridView)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _menuList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 6.0,
                  mainAxisSpacing: 6.0,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.all(4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image click adds item to cart
                        GestureDetector(
                          onTap: () {
                            _addToCart(_menuList[index]);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${_menuList[index]['nama']} telah ditambahkan ke keranjang.'), // Ganti 'name' dengan 'nama'
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Image.network(
                            'https://reportglm.com/api/${_menuList[index]['gambar']}', // Ganti 'image' dengan 'gambar'
                            width: double.infinity,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          // Name click shows details page
                          child: GestureDetector(
                            onTap: () {
                              try {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      // Check if the data is valid before passing it
                                      final String nama =
                                          _menuList[index]['nama'] ?? 'Unknown';
                                      final String keterangan = _menuList[index]
                                              ['keterangan'] ??
                                          'No description';
                                      final String gambar =
                                          _menuList[index]['gambar'] ?? '';
                                      final double harga = double.parse(
                                          _menuList[index]['harga'] ?? '0');

                                      return MenuDetailPage(
                                        nama: nama,
                                        keterangan: keterangan,
                                        gambar: gambar,
                                        harga: harga,
                                      );
                                    },
                                  ),
                                );
                              } catch (e) {
                                // Handle the error, e.g., show a Snackbar or log the error
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              _menuList[index]
                                  ['nama'], // Ganti 'name' dengan 'nama'
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            'Rp ${_menuList[index]['harga']}', // Ganti 'price' dengan 'harga'
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
