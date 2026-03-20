enum EquipmentStatus { functional, broken, lost, returned }

class EquipmentEntity {
  final String id;
  final String name;
  final String? serialNumber;
  final String enterpriseId;
  final EquipmentStatus status;
  final DateTime receivedDate;
  final String? notes;

  const EquipmentEntity({
    required this.id,
    required this.name,
    this.serialNumber,
    required this.enterpriseId,
    this.status = EquipmentStatus.functional,
    required this.receivedDate,
    this.notes,
  });
}
