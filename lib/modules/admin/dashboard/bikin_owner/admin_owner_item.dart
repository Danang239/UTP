class AdminOwnerItem {
  final String id;       // document ID Firestore
  final String ownerId;  // owner_id (🔥 KUNCI UTAMA)
  final String name;
  final String email;
  final String phone;
  final String role;

  AdminOwnerItem({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  // ===============================
  // FROM FIRESTORE
  // ===============================
  factory AdminOwnerItem.fromFirestore(
    Map<String, dynamic> data,
    String docId,
  ) {
    return AdminOwnerItem(
      id: docId,
      ownerId: data['owner_id'] ?? docId, // 🔥 fallback aman
      name: data['name'] ?? 'Tidak ada nama',
      email: data['email'] ?? 'Tidak ada email',
      phone: data['phone'] ?? 'Tidak ada telepon',
      role: data['role'] ?? 'owner',
    );
  }
}
