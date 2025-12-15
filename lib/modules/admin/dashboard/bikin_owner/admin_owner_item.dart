class AdminOwnerItem {
  /// UID Firebase Auth
  /// = Document ID Firestore
  final String id;

  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isActive;

  AdminOwnerItem({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
  });

  // =====================================================
  // FROM FIRESTORE
  // =====================================================
  factory AdminOwnerItem.fromFirestore(
    Map<String, dynamic> data,
    String docId,
  ) {
    return AdminOwnerItem(
      id: docId, // 🔥 UID Auth = docId Firestore
      name: data['name'] ?? 'Tidak ada nama',
      email: data['email'] ?? 'Tidak ada email',
      phone: data['phone'] ?? 'Tidak ada telepon',
      role: data['role'] ?? 'owner',
      isActive: data['is_active'] ?? true,
    );
  }

  // =====================================================
  // TO MAP (OPSIONAL – untuk update Firestore)
  // =====================================================
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'is_active': isActive,
    };
  }
}
