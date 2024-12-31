import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'menu_detail_page.dart'; // Import halaman detail menu
import 'cart_item.dart';
import 'cart_page.dart';
import 'edit_profile_page.dart';
import 'blank_screen.dart';

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
        (item) => item.name == menuItem['name'],
        orElse: () => CartItem(name: '', image: '', price: 0),
      );

      if (existingItem.name.isEmpty) {
        _cart.add(CartItem(
          name: menuItem['name'],
          image: menuItem['image'],
          price: menuItem['price'].toDouble(),
          quantity: 1,
        ));
      } else {
        existingItem.quantity++;
      }
    });

    // Show a Snackbar message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${menuItem['name']} telah ditambahkan ke keranjang.'),
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
    final String response =
        await rootBundle.loadString('assets/menu_data.json');
    final data = await json.decode(response);
    setState(() {
      _menuList = data;
    });
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
                                    '${_menuList[index]['name']} telah ditambahkan ke keranjang.'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Image.asset(
                            _menuList[index]['image'],
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MenuDetailPage(
                                    name: _menuList[index]['name'],
                                    description: _menuList[index]
                                        ['description'],
                                    image: _menuList[index]['image'],
                                    price: _menuList[index]['price'].toDouble(),
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              _menuList[index]['name'],
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            'Rp ${_menuList[index]['price']}',
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
