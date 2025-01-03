class Product {
  final String idProduk;
  final String nama;
  final double harga;
  final String keterangan;
  final String gambar;

  Product({
    required this.idProduk,
    required this.nama,
    required this.harga,
    required this.keterangan,
    required this.gambar,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      idProduk: json['id_produk'],
      nama: json['nama'],
      harga: double.parse(json['harga']),
      keterangan: json['keterangan'],
      gambar: json['gambar'],
    );
  }
}
