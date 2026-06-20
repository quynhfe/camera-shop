class PaymentMethod {
  final int id;
  final int userId;
  final String label;
  final String detail;
  final String icon;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.userId,
    required this.label,
    required this.detail,
    required this.icon,
    required this.isDefault,
  });

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      label: (map['label'] as String?) ?? '',
      detail: (map['detail'] as String?) ?? '',
      icon: (map['icon'] as String?) ?? 'card',
      isDefault: ((map['is_default'] as int?) ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'label': label,
      'detail': detail,
      'icon': icon,
      'is_default': isDefault ? 1 : 0,
    };
  }
}
