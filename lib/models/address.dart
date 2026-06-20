class Address {
  final int id;
  final int userId;
  final String label;
  final String detail;
  final bool isDefault;

  Address({
    required this.id,
    required this.userId,
    required this.label,
    required this.detail,
    required this.isDefault,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      label: (map['label'] as String?) ?? '',
      detail: (map['detail'] as String?) ?? '',
      isDefault: ((map['is_default'] as int?) ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'label': label,
      'detail': detail,
      'is_default': isDefault ? 1 : 0,
    };
  }
}
