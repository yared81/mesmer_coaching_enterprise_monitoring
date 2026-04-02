import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'certificate_template.dart';
import 'certificate_verification.dart';

class CertificateGenerator {
  static const double _certificateWidth = 1122.52; // A4 landscape width in points
  static const double _certificateHeight = 793.7; // A4 landscape height in points
  static const double _margin = 50;

  /// Generate a professional certificate PDF
  static Future<String> generateCertificate(CertificateTemplate data) async {
    try {
      final pdf = pw.Document();
      
      // Add certificate page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(_certificateWidth, _certificateHeight),
          margin: pw.EdgeInsets.all(_margin),
          build: (pw.Context context) => _buildCertificateLayout(data),
        ),
      );

      // Save PDF to local storage
      final fileName = 'certificate_${data.id}.pdf';
      final filePath = await _saveCertificatePDF(pdf, fileName);
      
      return filePath;
    } catch (e) {
      throw Exception('Failed to generate certificate: $e');
    }
  }

  /// Build the certificate layout
  static pw.Widget _buildCertificateLayout(CertificateTemplate data) {
    return pw.Container(
      decoration: _buildCertificateBorder(),
      child: pw.Column(
        children: [
          _buildHeader(),
          pw.SizedBox(height: 30),
          _buildTitle(),
          pw.SizedBox(height: 20),
          _buildRecipientInfo(data),
          pw.SizedBox(height: 30),
          _buildCertificateText(),
          pw.SizedBox(height: 20),
          _buildAchievements(data),
          pw.SizedBox(height: 30),
          _buildSignatures(data),
          pw.SizedBox(height: 20),
          _buildFooter(data),
        ],
      ),
    );
  }

  /// Build certificate border decoration
  static pw.BoxDecoration _buildCertificateBorder() {
    return pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.amber, width: 3),
      borderRadius: pw.BorderRadius.circular(10),
    );
  }

  /// Build certificate header
  static pw.Widget _buildHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _buildLogo(),
        pw.Column(
          children: [
            pw.Text(
              'MESMER DIGITAL COACHING',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.Text(
              'Enterprise Transformation Program',
              style: pw.TextStyle(
                fontSize: 14,
                color: PdfColors.blue600,
              ),
            ),
          ],
        ),
        _buildSeal(),
      ],
    );
  }

  /// Build logo placeholder
  static pw.Widget _buildLogo() {
    return pw.Container(
      width: 80,
      height: 80,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Center(
        child: pw.Text(
          'LOGO',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
        ),
      ),
    );
  }

  /// Build official seal
  static pw.Widget _buildSeal() {
    return pw.Container(
      width: 70,
      height: 70,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.amber700, width: 2),
        shape: pw.BoxShape.circle,
        color: PdfColors.amber50,
      ),
      child: pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              'OFFICIAL',
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.amber900),
            ),
            pw.Text(
              'GRADUATE',
              style: pw.TextStyle(fontSize: 7, color: PdfColors.amber800),
            ),
            pw.Text(
              'MESMER',
              style: pw.TextStyle(fontSize: 6, color: PdfColors.amber800),
            ),
          ],
        ),
      ),
    );
  }

  /// Build certificate title
  static pw.Widget _buildTitle() {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(vertical: 15),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.amber, width: 2),
          bottom: pw.BorderSide(color: PdfColors.amber, width: 2),
        ),
      ),
      child: pw.Center(
        child: pw.Text(
          'CERTIFICATE OF COMPLETION',
          style: pw.TextStyle(
            fontSize: 36,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
      ),
    );
  }

  /// Build recipient information
  static pw.Widget _buildRecipientInfo(CertificateTemplate data) {
    return pw.Column(
      children: [
        pw.Text(
          'This is to certify that',
          style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          data.ownerName.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 28,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'Owner of ${data.enterpriseName}',
          style: pw.TextStyle(fontSize: 18, color: PdfColors.grey800),
        ),
      ],
    );
  }

  /// Build certificate main text
  static pw.Widget _buildCertificateText() {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(horizontal: 40),
      child: pw.Text(
        'has successfully completed the MESMER Digital Coaching Program and has demonstrated outstanding commitment to business growth and excellence.',
        style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// Build achievements section
  static pw.Widget _buildAchievements(CertificateTemplate data) {
    if (data.achievements.isEmpty) return pw.SizedBox();
    
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(horizontal: 40),
      child: pw.Column(
        children: [
          pw.Text(
            'Key Achievements:',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 10),
          ...data.achievements.map((achievement) => pw.Padding(
            padding: pw.EdgeInsets.symmetric(vertical: 2),
            child: pw.Text(
              '• $achievement',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
          )),
        ],
      ),
    );
  }

  /// Build signature section
  static pw.Widget _buildSignatures(CertificateTemplate data) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        _buildSignatureBlock('Coach', data.coachName),
        _buildSignatureBlock('M&E Officer', 'M&E Representative'),
        _buildSignatureBlock('Regional Coordinator', data.regionalCoordinator),
      ],
    );
  }

  /// Build individual signature block
  static pw.Widget _buildSignatureBlock(String title, String name) {
    return pw.Column(
      children: [
        pw.Container(
          width: 150,
          height: 40,
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400)),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          name,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
  }

  /// Build certificate footer
  static pw.Widget _buildFooter(CertificateTemplate data) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Certificate Number: ${data.certificateNumber ?? 'TBD'}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
            pw.Text(
              'Issue Date: ${_formatDate(data.issueDate)}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
            pw.Text(
              'Completion Date: ${_formatDate(data.completionDate)}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'Verification Code:',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              data.verificationCode,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 5),
            _buildQRCode(data.verificationCode),
          ],
        ),
      ],
    );
  }

  /// Build QR code
  static pw.Widget _buildQRCode(String verificationCode) {
    return pw.Container(
      width: 70,
      height: 70,
      padding: const pw.EdgeInsets.all(5),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        color: PdfColors.white,
      ),
      child: pw.BarcodeWidget(
        barcode: pw.Barcode.qrCode(),
        data: 'https://mesmer-verify.com/verify/$verificationCode',
        drawText: false,
      ),
    );
  }

  /// Format date for display
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Save PDF to local storage
  static Future<String> _saveCertificatePDF(pw.Document pdf, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final certificatesDir = Directory('${directory.path}/certificates');
      
      if (!await certificatesDir.exists()) {
        await certificatesDir.create(recursive: true);
      }

      final file = File('${certificatesDir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      
      return file.path;
    } catch (e) {
      throw Exception('Failed to save certificate PDF: $e');
    }
  }

  /// Generate certificate preview as image (for UI preview)
  static Future<Uint8List> generateCertificatePreview(CertificateTemplate data) async {
    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: pw.EdgeInsets.all(_margin),
          build: (pw.Context context) => _buildCertificateLayout(data),
        ),
      );

      return await pdf.save();
    } catch (e) {
      throw Exception('Failed to generate certificate preview: $e');
    }
  }

  /// Validate certificate data before generation
  static bool validateCertificateData(CertificateTemplate data) {
    if (data.enterpriseName.isEmpty || data.ownerName.isEmpty) {
      return false;
    }
    
    if (data.verificationCode.isEmpty || 
        !CertificateVerificationService.isValidVerificationCode(data.verificationCode)) {
      return false;
    }
    
    if (data.issueDate.isAfter(DateTime.now())) {
      return false;
    }
    
    return true;
  }

  /// Create a new certificate template with auto-generated data
  static CertificateTemplate createCertificateTemplate({
    required String enterpriseId,
    required String enterpriseName,
    required String ownerName,
    required String coachName,
    required String regionalCoordinator,
    List<String>? achievements,
  }) {
    final now = DateTime.now();
    final certificateId = CertificateVerificationService.generateCertificateId();
    final verificationCode = CertificateVerificationService.generateVerificationCode();
    final certificateNumber = CertificateVerificationService.generateCertificateNumber(
      now.year, 
      1, // TODO: Get actual sequence number
    );

    return CertificateTemplate(
      id: certificateId,
      enterpriseId: enterpriseId,
      enterpriseName: enterpriseName,
      ownerName: ownerName,
      programName: 'MESMER Digital Coaching Program',
      issueDate: now,
      completionDate: now,
      verificationCode: verificationCode,
      coachName: coachName,
      regionalCoordinator: regionalCoordinator,
      achievements: achievements ?? [],
      status: CertificateStatus.pending,
      certificateNumber: certificateNumber,
    );
  }
}
