import 'package:equatable/equatable.dart';

class DiagnosisTemplateEntity extends Equatable {
  final String id;
  final String title;
  final int version;
  final bool isActive;
  final String? templateTypeCode; // baseline, midline, endline, etc
  final DateTime? updatedAt;
  final List<DiagnosisCategoryEntity> categories;

  const DiagnosisTemplateEntity({
    required this.id,
    required this.title,
    required this.version,
    required this.isActive,
    this.templateTypeCode,
    this.updatedAt,
    required this.categories,
  });

  @override
  List<Object?> get props => [id, title, version, isActive, templateTypeCode, updatedAt, categories];
}

class DiagnosisCategoryEntity extends Equatable {
  final String id;
  final String name;
  final int sortOrder;
  final List<DiagnosisQuestionEntity> questions;

  const DiagnosisCategoryEntity({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.questions,
  });

  @override
  List<Object?> get props => [id, name, sortOrder, questions];
}

class DiagnosisQuestionEntity extends Equatable {
  final String id;
  final String text;
  final int sortOrder;
  final List<DiagnosisChoiceEntity> choices;

  const DiagnosisQuestionEntity({
    required this.id,
    required this.text,
    required this.sortOrder,
    required this.choices,
  });

  @override
  List<Object?> get props => [id, text, sortOrder, choices];
}

class DiagnosisChoiceEntity extends Equatable {
  final String id;
  final String text;
  final int points;
  final int sortOrder;

  const DiagnosisChoiceEntity({
    required this.id,
    required this.text,
    required this.points,
    required this.sortOrder,
  });

  @override
  List<Object?> get props => [id, text, points, sortOrder];
}
