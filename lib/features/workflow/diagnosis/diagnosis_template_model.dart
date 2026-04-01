import 'package:mesmer_digital_coaching/core/utils/num_utils.dart';
import 'diagnosis_template_entity.dart';

class DiagnosisTemplateModel extends DiagnosisTemplateEntity {
  const DiagnosisTemplateModel({
    required super.id,
    required super.title,
    required super.version,
    required super.isActive,
    super.templateTypeCode,
    super.updatedAt,
    required super.categories,
  });

  factory DiagnosisTemplateModel.fromJson(Map<String, dynamic> json) {
    return DiagnosisTemplateModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      version: NumUtils.toInt(json['version']) != 0 ? NumUtils.toInt(json['version']) : 1,
      isActive: json['is_active'] is bool ? json['is_active'] as bool : (json['is_active'] == true || json['is_active'] == 1),
      templateTypeCode: json['template_type']?.toString(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      categories: json['categories'] != null 
          ? (json['categories'] as List).map((c) => DiagnosisCategoryModel.fromJson(c)).toList()
          : [],
    );
  }

  DiagnosisTemplateEntity toEntity() => this;
}

class DiagnosisCategoryModel extends DiagnosisCategoryEntity {
  const DiagnosisCategoryModel({
    required super.id,
    required super.name,
    required super.sortOrder,
    required super.questions,
  });

  factory DiagnosisCategoryModel.fromJson(Map<String, dynamic> json) {
    return DiagnosisCategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sortOrder: NumUtils.toInt(json['sort_order']),
      questions: json['questions'] != null
          ? (json['questions'] as List).map((q) => DiagnosisQuestionModel.fromJson(q)).toList()
          : [],
    );
  }
}

class DiagnosisQuestionModel extends DiagnosisQuestionEntity {
  const DiagnosisQuestionModel({
    required super.id,
    required super.text,
    required super.sortOrder,
    required super.choices,
  });

  factory DiagnosisQuestionModel.fromJson(Map<String, dynamic> json) {
    return DiagnosisQuestionModel(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      sortOrder: NumUtils.toInt(json['sort_order']),
      choices: json['choices'] != null
          ? (json['choices'] as List).map((c) => DiagnosisChoiceModel.fromJson(c)).toList()
          : [],
    );
  }
}

class DiagnosisChoiceModel extends DiagnosisChoiceEntity {
  const DiagnosisChoiceModel({
    required super.id,
    required super.text,
    required super.points,
    required super.sortOrder,
  });

  factory DiagnosisChoiceModel.fromJson(Map<String, dynamic> json) {
    return DiagnosisChoiceModel(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      points: NumUtils.toInt(json['points']),
      sortOrder: NumUtils.toInt(json['sort_order']),
    );
  }
}
