import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class CertificateVerificationService {
  static const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static final Random _random = Random.secure();

  /// Generate a unique 12-character verification code
  static String generateVerificationCode() {
    // Generate 8 random characters + 4 character checksum
    final randomPart = String.fromCharCodes(Iterable.generate(
        8, (_) => _chars.codeUnitAt(_random.nextInt(_chars.length))));
    
    final checksum = _generateChecksum(randomPart);
    return '$randomPart$checksum';
  }

  /// Generate a checksum for the verification code
  static String _generateChecksum(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    // Take first 4 characters of hash and convert to alphanumeric
    final hash = digest.toString().substring(0, 8);
    return hash.split('').map((char) {
      final code = char.codeUnitAt(0);
      return _chars[code % _chars.length];
    }).join('');
  }

  /// Validate verification code format
  static bool isValidVerificationCode(String code) {
    if (code.length != 12) return false;
    if (!code.toUpperCase().split('').every((char) => _chars.contains(char))) {
      return false;
    }
    
    final randomPart = code.substring(0, 8);
    final checksum = code.substring(8);
    final expectedChecksum = _generateChecksum(randomPart);
    
    return checksum == expectedChecksum;
  }

  /// Generate certificate number
  static String generateCertificateNumber(int year, int sequence) {
    return 'MESMER-$year-${sequence.toString().padLeft(6, '0')}';
  }

  /// Generate unique certificate ID
  static String generateCertificateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _random.nextInt(9999);
    return 'CERT-$timestamp-$random';
  }

  /// Check if verification code has been used
  static Future<bool> isVerificationCodeUsed(String code) async {
    // This would typically check against a database
    // For now, return false (not used)
    // TODO: Implement database check
    return false;
  }

  /// Mark verification code as used
  static Future<void> markVerificationCodeUsed(String code, String certificateId) async {
    // This would typically update a database
    // TODO: Implement database update
  }

  /// Generate QR code data for certificate
  static String generateQRCodeData(String verificationCode, String baseUrl) {
    return '$baseUrl/verify/$verificationCode';
  }

  /// Validate certificate integrity
  static bool validateCertificateIntegrity(Map<String, dynamic> certificateData) {
    // Check required fields
    final requiredFields = [
      'id', 'enterpriseId', 'verificationCode', 'issueDate', 'status'
    ];
    
    for (final field in requiredFields) {
      if (!certificateData.containsKey(field) || certificateData[field] == null) {
        return false;
      }
    }

    // Validate verification code format
    final code = certificateData['verificationCode'] as String;
    if (!isValidVerificationCode(code)) {
      return false;
    }

    // Validate certificate ID format
    final id = certificateData['id'] as String;
    if (!id.startsWith('CERT-')) {
      return false;
    }

    return true;
  }

  /// Generate certificate hash for integrity checking
  static String generateCertificateHash(Map<String, dynamic> certificateData) {
    final sortedData = Map.fromEntries(
      certificateData.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
    final jsonString = jsonEncode(sortedData);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify certificate hash matches
  static bool verifyCertificateHash(Map<String, dynamic> certificateData, String expectedHash) {
    final actualHash = generateCertificateHash(certificateData);
    return actualHash == expectedHash;
  }
}
