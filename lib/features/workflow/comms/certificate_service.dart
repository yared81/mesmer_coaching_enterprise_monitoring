import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:mesmer_coaching_enterprise_monitoring/features/workflow/enterprise/enterprise_entity.dart';

class CertificateService {
  static Future<Uint8List> generateGraduationCertificate({
    required EnterpriseEntity enterprise,
    required String verificationCode,
    required String coachName,
  }) async {
    final pdf = pw.Document();

    // Load logo if available (fallback to placeholder)
    // final logo = pw.MemoryImage((await rootBundle.load('assets/images/logo.png')).buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(30),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blueGrey900, width: 5),
            ),
            child: pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blueGrey700, width: 2),
              ),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'MESMER PROGRAM',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Micro-enterprise Support for Modernization & Economic Recovery',
                    style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Text(
                    'CERTIFICATE OF GRADUATION',
                    style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text('This is to certify that', style: const pw.TextStyle(fontSize: 16)),
                  pw.SizedBox(height: 15),
                  pw.Text(
                    enterprise.businessName.toUpperCase(),
                    style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text('Owned by ${enterprise.ownerName}', style: const pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 25),
                  pw.Container(
                    width: 400,
                    child: pw.Text(
                      'Has successfully completed the MESMER Coaching and Business Development program. Through rigorous training and individualized coaching, the enterprise has demonstrated significant growth and resilience.',
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
                    ),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      pw.Column(
                        children: [
                          pw.Text(coachName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Container(width: 150, height: 1, color: PdfColors.black),
                          pw.Text('Program Coach', style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.Text(DateFormat('MMMM dd, yyyy').format(DateTime.now()), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Container(width: 150, height: 1, color: PdfColors.black),
                          pw.Text('Date Issued', style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Verification Code: $verificationCode', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                      pw.Text('Graduated from: ${enterprise.location}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
