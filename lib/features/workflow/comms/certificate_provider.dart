import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:mesmer_digital_coaching/core/constants/api_constants.dart';
import 'package:mesmer_digital_coaching/core/errors/failure.dart';
import 'certificate_template.dart';
import 'certificate_verification.dart';
import 'graduation_validator.dart';
import 'certificate_generator.dart';

class CertificateState {
  final bool isLoading;
  final String? errorMessage;
  final List<CertificateTemplate> certificates;
  final CertificateTemplate? currentCertificate;
  final GraduationValidationResult? validationResult;

  const CertificateState({
    this.isLoading = false,
    this.errorMessage,
    this.certificates = const [],
    this.currentCertificate,
    this.validationResult,
  });

  CertificateState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<CertificateTemplate>? certificates,
    CertificateTemplate? currentCertificate,
    GraduationValidationResult? validationResult,
  }) {
    return CertificateState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      certificates: certificates ?? this.certificates,
      currentCertificate: currentCertificate ?? this.currentCertificate,
      validationResult: validationResult ?? this.validationResult,
    );
  }
}

class CertificateNotifier extends StateNotifier<CertificateState> {
  final Dio _dio;

  CertificateNotifier(this._dio) : super(const CertificateState());

  /// Validate enterprise graduation readiness
  Future<void> validateGraduation(String enterpriseId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final result = await GraduationValidator.validateGraduation(enterpriseId);
      state = state.copyWith(
        isLoading: false,
        validationResult: result,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to validate graduation: $e',
      );
    }
  }

  /// Generate certificate for enterprise
  Future<void> generateCertificate({
    required String enterpriseId,
    required String enterpriseName,
    required String ownerName,
    required String coachName,
    required String regionalCoordinator,
    List<String>? achievements,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      // First validate graduation requirements
      final validation = await GraduationValidator.validateGraduation(enterpriseId);
      if (!validation.isEligible) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: validation.errorMessage ?? 'Enterprise not eligible for certificate',
        );
        return;
      }

      // Create certificate template
      final certificate = CertificateGenerator.createCertificateTemplate(
        enterpriseId: enterpriseId,
        enterpriseName: enterpriseName,
        ownerName: ownerName,
        coachName: coachName,
        regionalCoordinator: regionalCoordinator,
        achievements: achievements,
      );

      // Validate certificate data
      if (!CertificateGenerator.validateCertificateData(certificate)) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid certificate data',
        );
        return;
      }

      // Generate PDF
      final pdfPath = await CertificateGenerator.generateCertificate(certificate);
      
      // Update certificate with PDF path
      final updatedCertificate = certificate.copyWith(
        pdfFileUrl: pdfPath,
        status: CertificateStatus.approved,
      );

      // Save to backend
      await _saveCertificateToBackend(updatedCertificate);

      state = state.copyWith(
        isLoading: false,
        currentCertificate: updatedCertificate,
        certificates: [...state.certificates, updatedCertificate],
      );

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to generate certificate: $e',
      );
    }
  }

  /// Load all certificates
  Future<void> loadCertificates() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/certificates');
      
      final certificates = (response.data['data'] as List)
          .map((json) => CertificateTemplate.fromJson(json))
          .toList();

      state = state.copyWith(
        isLoading: false,
        certificates: certificates,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load certificates: $e',
      );
    }
  }

  /// Verify certificate by verification code
  Future<CertificateTemplate?> verifyCertificate(String verificationCode) async {
    try {
      // Validate verification code format
      if (!CertificateVerificationService.isValidVerificationCode(verificationCode)) {
        throw Exception('Invalid verification code format');
      }

      final response = await _dio.get(
        '${ApiConstants.baseUrl}/certificates/verify/$verificationCode'
      );

      if (response.data['success']) {
        return CertificateTemplate.fromJson(response.data['data']);
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to verify certificate: $e');
    }
  }

  /// Approve certificate
  Future<void> approveCertificate(String certificateId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _dio.put('${ApiConstants.baseUrl}/certificates/$certificateId/approve');
      
      // Update local state
      final updatedCertificates = state.certificates.map((cert) {
        if (cert.id == certificateId) {
          return cert.copyWith(status: CertificateStatus.approved);
        }
        return cert;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        certificates: updatedCertificates,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to approve certificate: $e',
      );
    }
  }

  /// Issue certificate
  Future<void> issueCertificate(String certificateId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _dio.put('${ApiConstants.baseUrl}/certificates/$certificateId/issue');
      
      // Update local state
      final updatedCertificates = state.certificates.map((cert) {
        if (cert.id == certificateId) {
          return cert.copyWith(status: CertificateStatus.issued);
        }
        return cert;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        certificates: updatedCertificates,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to issue certificate: $e',
      );
    }
  }

  /// Revoke certificate
  Future<void> revokeCertificate(String certificateId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _dio.put('${ApiConstants.baseUrl}/certificates/$certificateId/revoke');
      
      // Update local state
      final updatedCertificates = state.certificates.map((cert) {
        if (cert.id == certificateId) {
          return cert.copyWith(status: CertificateStatus.revoked);
        }
        return cert;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        certificates: updatedCertificates,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to revoke certificate: $e',
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Reset current certificate
  void clearCurrentCertificate() {
    state = state.copyWith(currentCertificate: null);
  }

  /// Save certificate to backend
  Future<void> _saveCertificateToBackend(CertificateTemplate certificate) async {
    try {
      await _dio.post(
        '${ApiConstants.baseUrl}/certificates',
        data: certificate.toJson(),
      );
    } catch (e) {
      throw Exception('Failed to save certificate to backend: $e');
    }
  }

  /// Get certificate statistics
  Future<Map<String, dynamic>> getCertificateStatistics() async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/certificates/statistics');
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to get certificate statistics: $e');
    }
  }

  /// Get certificates by status
  List<CertificateTemplate> getCertificatesByStatus(CertificateStatus status) {
    return state.certificates.where((cert) => cert.status == status).toList();
  }

  /// Get certificates by enterprise
  CertificateTemplate? getCertificateByEnterprise(String enterpriseId) {
    try {
      return state.certificates.firstWhere((cert) => cert.enterpriseId == enterpriseId);
    } catch (e) {
      return null;
    }
  }
}

// Providers
final certificateProvider = StateNotifierProvider<CertificateNotifier, CertificateState>((ref) {
  final dio = Dio(); // TODO: Use proper Dio instance from dependencies
  return CertificateNotifier(dio);
});

final graduationValidationProvider = FutureProvider.family<GraduationValidationResult, String>((ref, enterpriseId) async {
  final result = await GraduationValidator.validateGraduation(enterpriseId);
  return result;
});

final certificateVerificationProvider = FutureProvider.family<CertificateTemplate?, String>((ref, verificationCode) async {
  final notifier = ref.read(certificateProvider.notifier);
  return await notifier.verifyCertificate(verificationCode);
});
