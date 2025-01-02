class Customer {
  final int id;
  final String email;
  final String password;

  Customer({
    required this.id,
    required this.email,
    required this.password,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: int.tryParse(json['id_login'].toString()) ??
          0, // Konversi string ke int
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_login':
          id.toString(), // Pastikan id dikirim sebagai string jika diperlukan
      'email': email,
      'password': password,
    };
  }
}
