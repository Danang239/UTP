class AdminOwnerItem {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;

  AdminOwnerItem({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  // Membuat instance AdminOwnerItem dari Firestore document
  factory AdminOwnerItem.fromFirestore(Map<String, dynamic> data, String id) {
    return AdminOwnerItem(
      id: id,
      name: data['name'] ?? 'Tidak ada nama', // Default jika null
      email: data['email'] ?? 'Tidak ada email', // Default jika null
      phone: data['phone'] ?? 'Tidak ada telepon', // Default jika null
      role: data['role'] ?? 'Tidak ada peran', // Default jika null
    );
  }
}
