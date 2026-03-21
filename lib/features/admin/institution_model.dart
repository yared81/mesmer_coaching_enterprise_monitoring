class InstitutionModel {
  final String id;
  final String name;
  final String? region;
  final String? contactEmail;

  InstitutionModel({
    required this.id,
    required this.name,
    this.region,
    this.contactEmail,
  });

  factory InstitutionModel.fromJson(Map<String, dynamic> json) {
    return InstitutionModel(
      id: json['id'],
      name: json['name'],
      region: json['region'],
      contactEmail: json['contact_email'],
    );
  }
}
