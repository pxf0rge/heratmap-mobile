import 'package:flutter/material.dart';

class EmergencyContactModel {
  final String id;
  final String name;
  final String phone;
  final String icon;
  final int sortOrder;
  final bool isActive;

  const EmergencyContactModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.icon,
    required this.sortOrder,
    this.isActive = true,
  });

  factory EmergencyContactModel.fromMap(Map<String, dynamic> data) {
    return EmergencyContactModel(
      id: _asText(data['id']),
      name: _asText(data['name']),
      phone: _asText(data['phone']),
      icon: _asText(data['icon']),
      sortOrder: _asInt(data['sort_order']),
      isActive: _asBool(data['is_active']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'icon': icon,
        'sort_order': sortOrder,
        'is_active': isActive,
      };

  IconData get iconData => _iconFromString(icon);

  static String _asText(Object? value) => value?.toString().trim() ?? '';
  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }
  static bool _asBool(Object? value) => value == true || value == 'true';

  static IconData _iconFromString(String iconName) => Icons.help_outline_rounded;
}
