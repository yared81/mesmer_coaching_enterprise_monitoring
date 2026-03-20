class PhoneFollowupEntity {
  const PhoneFollowupEntity({
    required this.id,
    required this.enterpriseId,
    required this.coachId,
    required this.date,
    required this.purpose,
    this.issueAddressed,
    this.adviceGiven,
    this.nextAction,
    this.enterpriseName,
    this.coachName,
  });

  final String id;
  final String enterpriseId;
  final String coachId;
  final DateTime date;
  final String purpose;
  final String? issueAddressed;
  final String? adviceGiven;
  final String? nextAction;
  final String? enterpriseName;
  final String? coachName;
}
