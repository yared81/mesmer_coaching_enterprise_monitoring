const { sequelize } = require('../config/database');
const Institution = require('./institution.model');
const User = require('./user.model');
const Enterprise = require('./enterprise.model');
const CoachingSession = require('./session.model');
const EnterpriseDocument = require('./enterprise_document.model');
const DiagnosisTemplate = require('./diagnosis_template.model');
const DiagnosisCategory = require('./diagnosis_category.model');
const DiagnosisQuestion = require('./diagnosis_question.model');
const DiagnosisChoice = require('./diagnosis_choice.model');
const DiagnosisReport = require('./diagnosis_report.model');
const DiagnosisResponse = require('./diagnosis_response.model');

// Institution <-> User (1:N)
Institution.hasMany(User, {
  foreignKey: 'institution_id',
  as: 'users'
});

User.belongsTo(Institution, {
  foreignKey: 'institution_id',
  as: 'institution'
});

// User (Coach) <-> Enterprise (1:N)
User.hasMany(Enterprise, {
  foreignKey: 'coach_id',
  as: 'enterprises'
});

Enterprise.belongsTo(User, {
  foreignKey: 'coach_id',
  as: 'coach'
});

// Institution <-> Enterprise (1:N)
Institution.hasMany(Enterprise, {
  foreignKey: 'institution_id',
  as: 'enterprises'
});

Enterprise.belongsTo(Institution, {
  foreignKey: 'institution_id',
  as: 'institution'
});

// Enterprise <-> User (Account Link)
User.hasOne(Enterprise, {
  foreignKey: 'user_id',
  as: 'enterpriseAccount'
});

Enterprise.belongsTo(User, {
  foreignKey: 'user_id',
  as: 'userAccount'
});

// CoachingSession Associations
Enterprise.hasMany(CoachingSession, {
  foreignKey: 'enterprise_id',
  as: 'sessions'
});

CoachingSession.belongsTo(Enterprise, {
  foreignKey: 'enterprise_id',
  as: 'enterprise'
});

User.hasMany(CoachingSession, {
  foreignKey: 'coach_id',
  as: 'sessions'
});

CoachingSession.belongsTo(User, {
  foreignKey: 'coach_id',
  as: 'coach'
});

// Document Associations
Enterprise.hasMany(EnterpriseDocument, { foreignKey: 'enterprise_id', as: 'documents' });
EnterpriseDocument.belongsTo(Enterprise, { foreignKey: 'enterprise_id' });

CoachingSession.hasMany(EnterpriseDocument, { foreignKey: 'session_id', as: 'attachments' });
EnterpriseDocument.belongsTo(CoachingSession, { foreignKey: 'session_id' });

User.hasMany(EnterpriseDocument, { foreignKey: 'uploader_id', as: 'uploadedFiles' });
EnterpriseDocument.belongsTo(User, { foreignKey: 'uploader_id' });

// Link Session to Diagnosis Template
CoachingSession.belongsTo(DiagnosisTemplate, {
  foreignKey: 'template_id',
  as: 'template'
});

DiagnosisTemplate.hasMany(CoachingSession, {
  foreignKey: 'template_id',
  as: 'sessions'
});

// Diagnosis Template Associations (1:N Hierarchy)
Institution.hasMany(DiagnosisTemplate, { foreignKey: 'institution_id', as: 'diagnosisTemplates' });
DiagnosisTemplate.belongsTo(Institution, { foreignKey: 'institution_id', as: 'institution' });

DiagnosisTemplate.hasMany(DiagnosisCategory, { foreignKey: 'template_id', as: 'categories', onDelete: 'CASCADE' });
DiagnosisCategory.belongsTo(DiagnosisTemplate, { foreignKey: 'template_id', as: 'template' });

DiagnosisCategory.hasMany(DiagnosisQuestion, { foreignKey: 'category_id', as: 'questions', onDelete: 'CASCADE' });
DiagnosisQuestion.belongsTo(DiagnosisCategory, { foreignKey: 'category_id', as: 'category' });

DiagnosisQuestion.hasMany(DiagnosisChoice, { foreignKey: 'question_id', as: 'choices', onDelete: 'CASCADE' });
DiagnosisChoice.belongsTo(DiagnosisQuestion, { foreignKey: 'question_id', as: 'question' });

// Diagnosis Report Associations
CoachingSession.hasOne(DiagnosisReport, { foreignKey: 'session_id', as: 'diagnosisReport' });
DiagnosisReport.belongsTo(CoachingSession, { foreignKey: 'session_id', as: 'session' });

DiagnosisTemplate.hasMany(DiagnosisReport, { foreignKey: 'template_id', as: 'reports', onDelete: 'CASCADE' });
DiagnosisReport.belongsTo(DiagnosisTemplate, { foreignKey: 'template_id', as: 'template' });

DiagnosisReport.hasMany(DiagnosisResponse, { foreignKey: 'report_id', as: 'responses', onDelete: 'CASCADE' });
DiagnosisResponse.belongsTo(DiagnosisReport, { foreignKey: 'report_id' });

DiagnosisQuestion.hasMany(DiagnosisResponse, { foreignKey: 'question_id', as: 'responses', onDelete: 'CASCADE' });
DiagnosisResponse.belongsTo(DiagnosisQuestion, { foreignKey: 'question_id' });

DiagnosisChoice.hasMany(DiagnosisResponse, { foreignKey: 'choice_id', as: 'responses', onDelete: 'CASCADE' });
DiagnosisResponse.belongsTo(DiagnosisChoice, { foreignKey: 'choice_id' });

const db = {
  Institution,
  User,
  Enterprise,
  CoachingSession,
  DiagnosisTemplate,
  DiagnosisCategory,
  DiagnosisQuestion,
  DiagnosisChoice,
  DiagnosisReport,
  DiagnosisResponse,
  EnterpriseDocument,
  sequelize
};

module.exports = db;
