import 'dart:typed_data';
import 'package:flutter/material.dart' show Color;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../enterprise_entity.dart';
import 'package:intl/intl.dart';

class GraduationCertificateGenerator {
  static Future<Uint8List> generate(EnterpriseEntity enterprise) async {
    final pdf = pw.Document();
    
    final verificationUrl = 'https://mesmermonitoring.com/verify/${enterprise.verificationCode ?? "N/A"}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(40),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: PdfColor.fromHex('#3D5AFE'),
                width: 5,
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'CERTIFICATE OF GRADUATION',
                  style: pw.TextStyle(
                    fontSize: 36,
                    color: PdfColor.fromHex('#3D5AFE'),
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'This is to certify that',
                  style: const pw.TextStyle(fontSize: 18),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  enterprise.businessName,
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'represented by ${enterprise.ownerName}',
                  style: const pw.TextStyle(fontSize: 18),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'has successfully completed the MESMER Digital Coaching Program.',
                  style: const pw.TextStyle(fontSize: 16),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 40),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Date of Graduation: ${enterprise.graduationDate != null ? DateFormat.yMMMMd().format(enterprise.graduationDate!) : "N/A"}', style: const pw.TextStyle(fontSize: 14)),
                        pw.Text('Verification Code: ${enterprise.verificationCode ?? "N/A"}', style: const pw.TextStyle(fontSize: 14)),
                        pw.Text('Sector: ${enterprise.sector.name.toUpperCase()}', style: const pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                    pw.Container(
                      height: 80,
                      width: 80,
                      child: pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: verificationUrl,
                        color: PdfColors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> printCertificate(EnterpriseEntity enterprise) async {
    final bytes = await generate(enterprise);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: '${enterprise.businessName} Certificate',
    );
  }
}
