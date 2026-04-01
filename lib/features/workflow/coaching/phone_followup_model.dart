import 'package:mesmer_digital_coaching/core/utils/num_utils.dart';
import 'phone_followup_entity.dart';

class PhoneFollowupModel extends PhoneFollowupEntity {
  const PhoneFollowupModel({
    required super.id,
    required super.enterpriseId,
    required super.coachId,
    required super.date,
    required super.purpose,
    super.issueAddressed,
    super.adviceGiven,
    super.nextAction,
    super.enterpriseName,
    super.coachName,
  });

  factory PhoneFollowupModel.fromJson(Map<String, dynamic> json) {
    return PhoneFollowupModel(
      id: json['id']?.toString() ?? '',
      enterpriseId: json['enterprise_id']?.toString() ?? '',
      coachId: json['coach_id']?.toString() ?? '',
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      purpose: json['purpose']?.toString() ?? '',
      issueAddressed: json['issue_addressed']?.toString(),
      adviceGiven: json['advice_given']?.toString(),
      nextAction: json['next_action']?.toString(),
      enterpriseName: json['enterprise'] != null ? json['enterprise']['business_name']?.toString() : null,
      coachName: json['coach'] != null ? json['coach']['name']?.toString() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enterprise_id': enterpriseId,
      'purpose': purpose,
      'issue_addressed': issueAddressed,
      'advice_given': adviceGiven,
      'next_action': nextAction,
    };
  }
}
