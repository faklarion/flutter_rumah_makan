class CartItem {
  final String nama;
  final String gambar;
  final double harga;
  int quantity;

  CartItem({
    required this.nama,
    required this.gambar,
    required this.harga,
    this.quantity = 1,
  });
}
