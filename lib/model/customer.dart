class Customer {
  final String name;
  final String disease;
  final String status;
  final String note;
  final DateTime createdAt;

  Customer({
    required this.name,
    required this.disease,
    required this.status,
    required this.note,
    required this.createdAt,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      name: map['name'] ?? '',
      disease: map['disease'] ?? '',
      status: map['status'] ?? '',
      note: map['note'] ?? '',
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt']
          : (map['createdAt'] != null && map['createdAt'] is String)
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'disease': disease,
      'status': status,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
