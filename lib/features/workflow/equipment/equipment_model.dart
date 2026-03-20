import 'equipment_entity.dart';

class EquipmentModel extends EquipmentEntity {
  EquipmentModel({
    required super.id,
    required super.name,
    super.serialNumber,
    required super.enterpriseId,
    super.status = EquipmentStatus.functional,
    required super.receivedDate,
    super.notes,
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
      id: json['id'],
      name: json['name'],
      serialNumber: json['serial_number'],
      enterpriseId: json['enterprise_id'],
      status: _parseStatus(json['status']),
      receivedDate: DateTime.parse(json['received_date']),
      notes: json['notes'],
    );
  }

  static EquipmentStatus _parseStatus(String? status) {
    switch (status) {
      case 'broken': return EquipmentStatus.broken;
      case 'lost': return EquipmentStatus.lost;
      case 'returned': return EquipmentStatus.returned;
      default: return EquipmentStatus.functional;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'serial_number': serialNumber,
      'enterprise_id': enterpriseId,
      'status': status.name,
      'received_date': receivedDate.toIso8601String(),
      'notes': notes,
    };
  }
}
