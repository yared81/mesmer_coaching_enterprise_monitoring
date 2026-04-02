import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:mesmer_digital_coaching/core/constants/api_constants.dart';
import 'package:mesmer_digital_coaching/core/providers/core_providers.dart';
import 'package:mesmer_digital_coaching/features/workflow/enterprise/enterprise_provider.dart';
import 'package:mesmer_digital_coaching/features/workflow/coaching/coaching_provider.dart';
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
  final GraduationValidator _validator;

  CertificateNotifier(this._dio, this._validator) : super(const CertificateState());

  Future<void> validateGraduation(String enterpriseId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _validator.validateGraduation(enterpriseId);
      state = state.copyWith(isLoading: false, validationResult: result);
    } catch (e) {
      state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to validate graduation: $e');
    }
  }

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
      final validation = await _validator.validateGraduation(enterpriseId);
      if (!validation.isEligible) {
        state = state.copyWith(
            isLoading: false,
            errorMessage:
                validation.errorMessage ?? 'Enterprise not eligible');
        return;
      }

      final certificate = CertificateGenerator.createCertificateTemplate(
        enterpriseId: enterpriseId,
        enterpriseName: enterpriseName,
        ownerName: ownerName,
        coachName: coachName,
        regionalCoordinator: regionalCoordinator,
        achievements: achievements,
      );

      if (!CertificateGenerator.validateCertificateData(certificate)) {
        state = state.copyWith(
            isLoading: false, errorMessage: 'Invalid certificate data');
        return;
      }

      final pdfPath = await CertificateGenerator.generateCertificate(certificate);
      final updated = certificate.copyWith(
          pdfFileUrl: pdfPath, status: CertificateStatus.approved);

      await _saveCertificateToBackend(updated);

      state = state.copyWith(
        isLoading: false,
        currentCertificate: updated,
        certificates: [...state.certificates, updated],
      );
    } catch (e) {
      state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to generate certificate: $e');
    }
  }

  Future<void> loadCertificates() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response =
          await _dio.get('${ApiConstants.baseUrl}/certificates');
      final certificates = (response.data['data'] as List)
          .map((json) =>
              CertificateTemplate.fromJson(json as Map<String, dynamic>))
          .toList();
      state = state.copyWith(isLoading: false, certificates: certificates);
    } catch (e) {
      state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load certificates: $e');
    }
  }

  Future<CertificateTemplate?> verifyCertificate(
      String verificationCode) async {
    if (!CertificateVerificationService.isValidVerificationCode(
        verificationCode)) {
      throw Exception('Invalid verification code format');
    }
    final response = await _dio.get(
        '${ApiConstants.baseUrl}/certificates/verify/$verificationCode');
    if (response.data['success'] == true) {
      return CertificateTemplate.fromJson(
          response.data['data'] as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> approveCertificate(String certificateId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _dio.put(
          '${ApiConstants.baseUrl}/certificates/$certificateId/approve');
      _updateLocalStatus(certificateId, CertificateStatus.approved);
    } catch (e) {
      state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to approve certificate: $e');
    }
  }

  Future<void> issueCertificate(String certificateId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _dio
          .put('${ApiConstants.baseUrl}/certificates/$certificateId/issue');
      _updateLocalStatus(certificateId, CertificateStatus.issued);
    } catch (e) {
      state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to issue certificate: $e');
    }
  }

  Future<void> revokeCertificate(String certificateId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _dio.put(
          '${ApiConstants.baseUrl}/certificates/$certificateId/revoke');
      _updateLocalStatus(certificateId, CertificateStatus.revoked);
    } catch (e) {
      state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to revoke certificate: $e');
    }
  }

  void _updateLocalStatus(String id, CertificateStatus newStatus) {
    final updated = state.certificates
        .map((c) => c.id == id ? c.copyWith(status: newStatus) : c)
        .toList();
    state = state.copyWith(isLoading: false, certificates: updated);
  }

  void clearError() => state = state.copyWith(errorMessage: null);
  void clearCurrentCertificate() =>
      state = state.copyWith(currentCertificate: null);

  Future<void> _saveCertificateToBackend(CertificateTemplate cert) async {
    await _dio.post('${ApiConstants.baseUrl}/certificates', data: cert.toJson());
  }

  List<CertificateTemplate> getCertificatesByStatus(CertificateStatus status) =>
      state.certificates.where((c) => c.status == status).toList();

  CertificateTemplate? getCertificateByEnterprise(String enterpriseId) {
    try {
      return state.certificates
          .firstWhere((c) => c.enterpriseId == enterpriseId);
    } catch (_) {
      return null;
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final graduationValidatorProvider = Provider<GraduationValidator>((ref) {
  return GraduationValidator(
    ref.watch(enterpriseRepositoryProvider),
    ref.watch(coachingRepositoryProvider),
  );
});

final certificateProvider =
    StateNotifierProvider<CertificateNotifier, CertificateState>((ref) {
  return CertificateNotifier(
    ref.watch(dioProvider),
    ref.watch(graduationValidatorProvider),
  );
});

final graduationValidationProvider =
    FutureProvider.family<GraduationValidationResult, String>(
        (ref, enterpriseId) async {
  final validator = ref.watch(graduationValidatorProvider);
  return validator.validateGraduation(enterpriseId);
});

final certificateVerificationProvider =
    FutureProvider.family<CertificateTemplate?, String>(
        (ref, verificationCode) async {
  return ref.read(certificateProvider.notifier).verifyCertificate(verificationCode);
});
