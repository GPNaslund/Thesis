import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/experimentation_result.dart';

class ResultExporter {
  Future<void> createAndShareResults(ExperimentationResult results, BuildContext context) async {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creating PDF...')),
    );

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context pdfContext) {
            return pw.Center(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    "Experiment Results",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  _createResultsTable(results),
                ],
              ),
            );
          },
        ),
      );

      final Uint8List pdfBytes = await pdf.save();

      final DateTime now = DateTime.now();
      final String formattedDate = DateFormat("yy-MM-dd_HH-mm").format(now);
      final String fileName = "experimentation_results_$formattedDate.pdf";

      final Directory tempDir = await getTemporaryDirectory();
      final File tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(pdfBytes);

      final ShareResult shareResult = await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'Experiment Results PDF',
      );

      if (context.mounted) {
        String message;
        if (shareResult.status == ShareResultStatus.success) {
          message = 'PDF shared successfully!';
        } else if (shareResult.status == ShareResultStatus.dismissed) {
          message = 'Share dismissed.';
        } else if (shareResult.status == ShareResultStatus.unavailable) {
          message = 'Sharing is not available on this device.';
        } else {
          message = 'Sharing completed with status: ${shareResult.status}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }


    } catch (e) {
      print("Error during PDF creation or sharing: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Could not prepare or share PDF. $e')),
        );
      }
    }
  }

  pw.Widget _createResultsTable(ExperimentationResult results) {
    final hrSuccessRate = results.amountOfHRRecords > 0
        ? (results.amountOfValidatedHR / results.amountOfHRRecords * 100).toStringAsFixed(2)
        : '0.00';

    final hrvSuccessRate = results.amountOfHRVRecords > 0
        ? (results.amountOfValidatedHRV / results.amountOfHRVRecords * 100).toStringAsFixed(2)
        : '0.00';

    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey700,
        width: 1,
      ),
      children: [
        // Records Summary Section
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColors.blue700,
          ),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                'RECORDS SUMMARY',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Container(),
          ],
        ),
        _createDataRow('Total Records Fetched', '${results.amountOfRecords}'),
        _createDataRow('Heart Rate Records', '${results.amountOfHRRecords}'),
        _createDataRow('Heart Rate Variability Records', '${results.amountOfHRVRecords}'),

        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColors.green700,
          ),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                'CONVERSION SUCCESS',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Container(),
          ],
        ),
        _createDataRow('Successfully Converted HR Records', '${results.amountOfValidatedHR}'),
        _createDataRow('HR Conversion Success Rate', '$hrSuccessRate%'),
        _createDataRow('Successfully Converted HRV Records', '${results.amountOfValidatedHRV}'),
        _createDataRow('HRV Conversion Success Rate', '$hrvSuccessRate%'),

        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColors.orange700,
          ),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                'PERFORMANCE METRICS (ms)',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Container(),
          ],
        ),
        _createDataRow('Total Execution Time', '${results.totalFetchTimeMs} ms'),
        _createDataRow('Raw Data Fetch Time', '${results.rawDataFetchTimeMs} ms'),
        _createDataRow('Data Conversion Time', '${results.conversionFetchTimeMs} ms'),
      ],
    );
  }

  pw.TableRow _createDataRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }
}