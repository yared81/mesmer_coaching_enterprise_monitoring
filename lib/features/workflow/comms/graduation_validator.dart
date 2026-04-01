import 'certificate_template.dart';

class GraduationValidator {
  /// Validate if an enterprise is ready for graduation
  static Future<GraduationValidationResult> validateGraduation(String enterpriseId) async {
    final result = GraduationValidationResult();
    
    try {
      // Check 1: Baseline assessment completed and approved
      final baselineResult = await _validateBaselineAssessment(enterpriseId);
      result.baselineStatus = baselineResult.status;
      if (!baselineResult.isValid) {
        result.overallStatus = GraduationStatus.baselinePending;
        result.errorMessage = baselineResult.message;
        return result;
      }

      // Check 2: Minimum 8 coaching sessions completed
      final coachingResult = await _validateCoachingSessions(enterpriseId);
      result.coachingStatus = coachingResult.status;
      if (!coachingResult.isValid) {
        result.overallStatus = GraduationStatus.insufficientCoaching;
        result.errorMessage = coachingResult.message;
        return result;
      }

      // Check 3: Midline assessment completed
      final midlineResult = await _validateMidlineAssessment(enterpriseId);
      result.midlineStatus = midlineResult.status;
      if (!midlineResult.isValid) {
        result.overallStatus = GraduationStatus.midlinePending;
        result.errorMessage = midlineResult.message;
        return result;
      }

      // Check 4: Coach sign-off on final IAP
      final iapResult = await _validateFinalIAP(enterpriseId);
      result.iapStatus = iapResult.status;
      if (!iapResult.isValid) {
        result.overallStatus = GraduationStatus.coachSignoffPending;
        result.errorMessage = iapResult.message;
        return result;
      }

      // Check 5: Minimum evidence uploaded
      final evidenceResult = await _validateEvidence(enterpriseId);
      result.evidenceStatus = evidenceResult.status;
      if (!evidenceResult.isValid) {
        result.overallStatus = GraduationStatus.insufficientEvidence;
        result.errorMessage = evidenceResult.message;
        return result;
      }

      // All checks passed
      result.overallStatus = GraduationStatus.readyForCertificate;
      result.isEligible = true;
      
    } catch (e) {
      result.overallStatus = GraduationStatus.notEligible;
      result.errorMessage = 'Validation error: $e';
      result.isEligible = false;
    }

    return result;
  }

  /// Validate baseline assessment
  static Future<ValidationCheck> _validateBaselineAssessment(String enterpriseId) async {
    try {
      // TODO: Implement actual baseline assessment check
      // This would typically query the database for baseline assessment status
      
      // Mock implementation for demonstration
      final baselineData = await _getBaselineAssessment(enterpriseId);
      
      if (baselineData == null) {
        return ValidationCheck(
          isValid: false,
          status: 'not_started',
          message: 'Baseline assessment has not been started',
        );
      }

      if (baselineData['status'] != 'approved') {
        return ValidationCheck(
          isValid: false,
          status: baselineData['status'],
          message: 'Baseline assessment is ${baselineData['status']} and needs approval',
        );
      }

      return ValidationCheck(
        isValid: true,
        status: 'approved',
        message: 'Baseline assessment completed and approved',
      );
      
    } catch (e) {
      return ValidationCheck(
        isValid: false,
        status: 'error',
        message: 'Error validating baseline assessment: $e',
      );
    }
  }

  /// Validate coaching sessions
  static Future<ValidationCheck> _validateCoachingSessions(String enterpriseId) async {
    try {
      // TODO: Implement actual coaching sessions check
      final sessions = await _getCoachingSessions(enterpriseId);
      
      if (sessions.isEmpty) {
        return ValidationCheck(
          isValid: false,
          status: 'none',
          message: 'No coaching sessions recorded',
        );
      }

      final completedSessions = sessions.where((s) => s['status'] == 'completed').length;
      
      if (completedSessions < 8) {
        return ValidationCheck(
          isValid: false,
          status: 'insufficient',
          message: 'Only $completedSessions of 8 required coaching sessions completed',
        );
      }

      return ValidationCheck(
        isValid: true,
        status: 'completed',
        message: '$completedSessions coaching sessions completed',
      );
      
    } catch (e) {
      return ValidationCheck(
        isValid: false,
        status: 'error',
        message: 'Error validating coaching sessions: $e',
      );
    }
  }

  /// Validate midline assessment
  static Future<ValidationCheck> _validateMidlineAssessment(String enterpriseId) async {
    try {
      // TODO: Implement actual midline assessment check
      final midlineData = await _getMidlineAssessment(enterpriseId);
      
      if (midlineData == null) {
        return ValidationCheck(
          isValid: false,
          status: 'not_started',
          message: 'Midline assessment has not been conducted',
        );
      }

      if (midlineData['status'] != 'completed') {
        return ValidationCheck(
          isValid: false,
          status: midlineData['status'],
          message: 'Midline assessment is ${midlineData['status']}',
        );
      }

      return ValidationCheck(
        isValid: true,
        status: 'completed',
        message: 'Midline assessment completed successfully',
      );
      
    } catch (e) {
      return ValidationCheck(
        isValid: false,
        status: 'error',
        message: 'Error validating midline assessment: $e',
      );
    }
  }

  /// Validate final IAP
  static Future<ValidationCheck> _validateFinalIAP(String enterpriseId) async {
    try {
      // TODO: Implement actual IAP validation
      final finalIAP = await _getFinalIAP(enterpriseId);
      
      if (finalIAP == null) {
        return ValidationCheck(
          isValid: false,
          status: 'not_created',
          message: 'Final Individual Action Plan has not been created',
        );
      }

      if (finalIAP['coach_signoff'] != true) {
        return ValidationCheck(
          isValid: false,
          status: 'pending_signoff',
          message: 'Final IAP requires coach sign-off',
        );
      }

      return ValidationCheck(
        isValid: true,
        status: 'approved',
        message: 'Final IAP completed and signed off by coach',
      );
      
    } catch (e) {
      return ValidationCheck(
        isValid: false,
        status: 'error',
        message: 'Error validating final IAP: $e',
      );
    }
  }

  /// Validate evidence requirements
  static Future<ValidationCheck> _validateEvidence(String enterpriseId) async {
    try {
      // TODO: Implement actual evidence validation
      final evidence = await _getEvidence(enterpriseId);
      
      if (evidence.isEmpty) {
        return ValidationCheck(
          isValid: false,
          status: 'none',
          message: 'No evidence documents uploaded',
        );
      }

      if (evidence.length < 5) {
        return ValidationCheck(
          isValid: false,
          status: 'insufficient',
          message: 'Only ${evidence.length} of 5 required evidence documents uploaded',
        );
      }

      return ValidationCheck(
        isValid: true,
        status: 'sufficient',
        message: '${evidence.length} evidence documents uploaded',
      );
      
    } catch (e) {
      return ValidationCheck(
        isValid: false,
        status: 'error',
        message: 'Error validating evidence: $e',
      );
    }
  }

  // Mock data methods - TODO: Replace with actual API calls
  static Future<Map<String, dynamic>?> _getBaselineAssessment(String enterpriseId) async {
    // Mock implementation
    await Future.delayed(Duration(milliseconds: 500));
    return {'status': 'approved', 'date': '2024-01-15'};
  }

  static Future<List<Map<String, dynamic>>> _getCoachingSessions(String enterpriseId) async {
    // Mock implementation
    await Future.delayed(Duration(milliseconds: 500));
    return List.generate(8, (index) => {
      'id': 'session_$index',
      'status': 'completed',
      'date': '2024-${(index + 1).toString().padLeft(2, '0')}-15'
    });
  }

  static Future<Map<String, dynamic>?> _getMidlineAssessment(String enterpriseId) async {
    // Mock implementation
    await Future.delayed(Duration(milliseconds: 500));
    return {'status': 'completed', 'date': '2024-06-15'};
  }

  static Future<Map<String, dynamic>?> _getFinalIAP(String enterpriseId) async {
    // Mock implementation
    await Future.delayed(Duration(milliseconds: 500));
    return {'coach_signoff': true, 'date': '2024-08-15'};
  }

  static Future<List<Map<String, dynamic>>> _getEvidence(String enterpriseId) async {
    // Mock implementation
    await Future.delayed(Duration(milliseconds: 500));
    return List.generate(5, (index) => {
      'id': 'evidence_$index',
      'type': 'photo',
      'filename': 'evidence_$index.jpg'
    });
  }
}

class GraduationValidationResult {
  GraduationStatus overallStatus = GraduationStatus.notEligible;
  bool isEligible = false;
  String? errorMessage;
  
  ValidationCheck baselineStatus = ValidationCheck();
  ValidationCheck coachingStatus = ValidationCheck();
  ValidationCheck midlineStatus = ValidationCheck();
  ValidationCheck iapStatus = ValidationCheck();
  ValidationCheck evidenceStatus = ValidationCheck();

  Map<String, dynamic> toJson() {
    return {
      'overallStatus': overallStatus.name,
      'isEligible': isEligible,
      'errorMessage': errorMessage,
      'baselineStatus': baselineStatus.toJson(),
      'coachingStatus': coachingStatus.toJson(),
      'midlineStatus': midlineStatus.toJson(),
      'iapStatus': iapStatus.toJson(),
      'evidenceStatus': evidenceStatus.toJson(),
    };
  }
}

class ValidationCheck {
  bool isValid = false;
  String status = '';
  String message = '';

  ValidationCheck({this.isValid = false, this.status = '', this.message = ''});

  Map<String, dynamic> toJson() {
    return {
      'isValid': isValid,
      'status': status,
      'message': message,
    };
  }
}
