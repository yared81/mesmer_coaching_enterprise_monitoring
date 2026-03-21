class InstitutionModel {
  final String id;
  final String name;
  final String? region;
  final String? contactEmail;
  final String? parentId;

  InstitutionModel({
    required this.id,
    required this.name,
    this.region,
    this.contactEmail,
    this.parentId,
  });

  factory InstitutionModel.fromJson(Map<String, dynamic> json) {
    return InstitutionModel(
      id: json['id'],
      name: json['name'],
      region: json['region'],
      contactEmail: json['contact_email'],
      parentId: json['parent_id'],
    );
  }
}
