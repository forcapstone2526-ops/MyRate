// evaluation_qr_screen.dart

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'main.dart';

class EvaluationQrScreen extends StatefulWidget {
  final String storeId;
  final String storeName;

  const EvaluationQrScreen({
    super.key,
    required this.storeId,
    required this.storeName,
  });

  @override
  State<EvaluationQrScreen> createState() => _EvaluationQrScreenState();
}

class _EvaluationQrScreenState extends State<EvaluationQrScreen> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isDownloading = false;

  Future<Uint8List?> _captureQr() async {
    try {
      final boundary =
          _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<pw.Font> _loadTtfFont({bool bold = false}) async {
    final assetPath = bold
        ? 'assets/fonts/Poppins-Bold.ttf'
        : 'assets/fonts/Poppins-Regular.ttf';
    try {
      final data = await rootBundle.load(assetPath);
      return pw.Font.ttf(data);
    } catch (_) {}

    final ttfUrl = bold
        ? 'https://github.com/google/fonts/raw/refs/heads/main/ofl/poppins/Poppins-Bold.ttf'
        : 'https://github.com/google/fonts/raw/refs/heads/main/ofl/poppins/Poppins-Regular.ttf';
    try {
      final response =
          await http.get(Uri.parse(ttfUrl)).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        return pw.Font.ttf(response.bodyBytes.buffer.asByteData());
      }
    } catch (_) {}

    return bold ? pw.Font.helveticaBold() : pw.Font.helvetica();
  }

  Future<void> _downloadAsPdf() async {
    setState(() => _isDownloading = true);

    try {
      final results = await Future.wait([
        _captureQr(),
        _loadTtfFont(bold: false),
        _loadTtfFont(bold: true),
      ]);

      final Uint8List? qrPng = results[0] as Uint8List?;
      final pw.Font fontRegular = results[1] as pw.Font;
      final pw.Font fontBold = results[2] as pw.Font;

      if (qrPng == null) throw Exception('Could not capture QR image.');

      pw.TextStyle ts({
        required pw.Font font,
        double size = 12,
        PdfColor? color,
        double? letterSpacing,
      }) =>
          pw.TextStyle(
            font: font,
            fontSize: size,
            color: color ?? PdfColors.black,
            letterSpacing: letterSpacing,
          );

      final pdf = pw.Document();
      final qrImage = pw.MemoryImage(qrPng);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context ctx) => pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(
                    vertical: 14, horizontal: 20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#6A1B9A'),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Center(
                  child: pw.Text(
                    'EVALUATION QR CODE',
                    style: ts(
                        font: fontBold,
                        size: 14,
                        color: PdfColors.white,
                        letterSpacing: 2),
                  ),
                ),
              ),
              pw.SizedBox(height: 32),
              pw.Text(widget.storeName,
                  style: ts(font: fontBold, size: 26),
                  textAlign: pw.TextAlign.center),
              pw.SizedBox(height: 8),
              pw.Text(
                'Show this QR code to customers to collect their evaluation.',
                style: ts(font: fontRegular, size: 13, color: PdfColors.grey700),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 36),
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                      color: PdfColor.fromHex('#E4DCF5'), width: 2),
                  borderRadius: pw.BorderRadius.circular(16),
                ),
                child: pw.Image(qrImage, width: 240, height: 240),
              ),
              pw.SizedBox(height: 24),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F3EEFF'),
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(
                      color: PdfColor.fromHex('#D4C5F0'), width: 1),
                ),
                child: pw.Text('QR ID: ${widget.storeId}',
                    style: ts(
                        font: fontBold,
                        size: 11,
                        color: PdfColor.fromHex('#6A1B9A'))),
              ),
              pw.SizedBox(height: 40),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F9F5FF'),
                  borderRadius: pw.BorderRadius.circular(12),
                  border: pw.Border.all(
                      color: PdfColor.fromHex('#E4DCF5'), width: 1),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('HOW TO USE',
                        style: ts(
                            font: fontBold,
                            size: 11,
                            color: PdfColor.fromHex('#6A1B9A'),
                            letterSpacing: 1.5)),
                    pw.SizedBox(height: 8),
                    pw.Text(
                        '1. Print this page and display it at your stall or canteen.',
                        style: ts(
                            font: fontRegular,
                            size: 12,
                            color: PdfColors.grey800)),
                    pw.SizedBox(height: 4),
                    pw.Text(
                        '2. Ask customers to scan the QR code using the MyRate app.',
                        style: ts(
                            font: fontRegular,
                            size: 12,
                            color: PdfColors.grey800)),
                    pw.SizedBox(height: 4),
                    pw.Text(
                        '3. Customers will be directed to the evaluation form for your store.',
                        style: ts(
                            font: fontRegular,
                            size: 12,
                            color: PdfColors.grey800)),
                  ],
                ),
              ),
              pw.Spacer(),
              pw.Divider(color: PdfColor.fromHex('#E4DCF5')),
              pw.SizedBox(height: 8),
              pw.Text(
                'Generated by MyRate  |  University of La Salette',
                style:
                    ts(font: fontRegular, size: 10, color: PdfColors.grey500),
                textAlign: pw.TextAlign.center,
              ),
            ],
          ),
        ),
      );

      final dir = await getTemporaryDirectory();
      final safeName =
          widget.storeName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final file = File('${dir.path}/${safeName}_EvaluationQR.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        subject: '${widget.storeName} - Evaluation QR Code',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String qrData = 'EVALUATION:${widget.storeId}';

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        final bool isDark = mode == ThemeMode.dark;

        final Color bgDeep =
            isDark ? const Color(0xFF0D0D0D) : const Color(0xFFFAF7F2);
        final Color bgCard =
            isDark ? const Color(0xFF1A1A1A) : Colors.white;
        final Color textPrimary =
            isDark ? Colors.white : const Color(0xFF1C1033);
        final Color textSecondary =
            isDark ? Colors.white38 : const Color(0xFF7C6F9B);
        final Color borderColor = isDark
            ? Colors.white.withOpacity(0.06)
            : const Color(0xFFE4DCF5);
        final Color qrForeground =
            isDark ? Colors.white : const Color(0xFF1C1033);
        final Color qrBackground =
            isDark ? const Color(0xFF1A1A1A) : Colors.white;

        return Scaffold(
          backgroundColor: bgDeep,
          appBar: AppBar(
            title: Text('Evaluation QR Code',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            centerTitle: true,
            backgroundColor: const Color(0xFF6A1B9A),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ── Section label ──────────────────────────────────────
                if (!isDark)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14, left: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6A1B9A),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'QR CODE',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF6A1B9A),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Store name card ────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: const Color(0xFF6A1B9A).withOpacity(0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.storeName,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Show this QR code to customers to collect their evaluation.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── QR code card ───────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 28, horizontal: 20),
                  decoration: BoxDecoration(
                    color: bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: const Color(0xFF6A1B9A).withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                  ),
                  child: Column(
                    children: [
                      // QR code wrapped in RepaintBoundary
                      RepaintBoundary(
                        key: _qrKey,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: qrBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: 1.5),
                          ),
                          child: QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 220,
                            backgroundColor: qrBackground,
                            eyeStyle: QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: qrForeground,
                            ),
                            dataModuleStyle: QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: qrForeground,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // QR ID badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A1B9A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFF6A1B9A).withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.qr_code,
                                size: 14,
                                color: const Color(0xFF6A1B9A)),
                            const SizedBox(width: 6),
                            Text(
                              'ID: ${widget.storeId}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF6A1B9A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── How to use card ────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: const Color(0xFF6A1B9A).withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isDark
                          ? Text(
                              'HOW TO USE',
                              style: GoogleFonts.poppins(
                                color: textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6A1B9A).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'HOW TO USE',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF6A1B9A),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                      const SizedBox(height: 12),
                      _buildStep(
                          '1',
                          'Print this page and display it at your stall or canteen.',
                          textPrimary,
                          textSecondary),
                      const SizedBox(height: 10),
                      _buildStep(
                          '2',
                          'Ask customers to scan the QR code using the MyRate app.',
                          textPrimary,
                          textSecondary),
                      const SizedBox(height: 10),
                      _buildStep(
                          '3',
                          'Customers will be directed to the evaluation form for your store.',
                          textPrimary,
                          textSecondary),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Download PDF button ────────────────────────────────
                GestureDetector(
                  onTap: _isDownloading ? null : _downloadAsPdf,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: _isDownloading
                          ? null
                          : const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF7B2FBE),
                                Color(0xFF4A148C),
                              ],
                            ),
                      color: _isDownloading
                          ? (isDark
                              ? const Color(0xFF2A2A2A)
                              : Colors.grey.shade200)
                          : null,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _isDownloading
                          ? null
                          : [
                              BoxShadow(
                                color: const Color(0xFF6A1B9A).withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                    ),
                    child: Center(
                      child: _isDownloading
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: isDark
                                        ? Colors.white54
                                        : const Color(0xFF6A1B9A),
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Generating PDF...',
                                  style: GoogleFonts.poppins(
                                    color: isDark
                                        ? Colors.white54
                                        : const Color(0xFF6A1B9A),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.download_rounded,
                                    color: Colors.white, size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  'Download as PDF',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Center(
                  child: Text(
                    'Save or print the PDF to display at your stall.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep(
      String number, String text, Color textPrimary, Color textSecondary) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF6A1B9A).withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6A1B9A),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}