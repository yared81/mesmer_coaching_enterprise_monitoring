import '../../domain/entities/diagnosis_template_entity.dart';

class DiagnosisTemplateModel extends DiagnosisTemplateEntity {
  const DiagnosisTemplateModel({
    required super.id,
    required super.title,
    required super.version,
    required super.categories,
  });

  factory DiagnosisTemplateModel.fromJson(Map<String, dynamic> json) {
    return DiagnosisTemplateModel(
      id: json['id'],
      title: json['title'],
      version: json['version'],
      categories: (json['categories'] as List)
          .map((c) => DiagnosisCategoryModel.fromJson(c))
          .toList(),
    );
  }
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
      id: json['id'],
      name: json['name'],
      sortOrder: json['sort_order'],
      questions: (json['questions'] as List)
          .map((q) => DiagnosisQuestionModel.fromJson(q))
          .toList(),
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
      id: json['id'],
      text: json['text'],
      sortOrder: json['sort_order'],
      choices: (json['choices'] as List)
          .map((c) => DiagnosisChoiceModel.fromJson(c))
          .toList(),
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
      id: json['id'],
      text: json['text'],
      points: json['points'],
      sortOrder: json['sort_order'],
    );
  }
}
