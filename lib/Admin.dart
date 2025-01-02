class Admin {
  final int id;
  final String email;
  final String password;

  Admin({
    required this.id,
    required this.email,
    required this.password,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
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
