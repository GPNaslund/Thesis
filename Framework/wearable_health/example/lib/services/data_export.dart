import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/experimentation_result.dart';

class ResultExporter {
  // Get the local app documents directory path
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Create a reference to the PDF file
  Future<File> _getPdfFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName.pdf');
  }

  // Write PDF bytes to the file
  Future<File> _writePdfBytes(String fileName, Uint8List pdfBytes) async {
    final file = await _getPdfFile(fileName);
    return file.writeAsBytes(pdfBytes);
  }

  Future<void> createAndSaveResults(ExperimentationResult results, BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Creating PDF...')),
      );

      // Create PDF document
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
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

      // Save the PDF to bytes
      final Uint8List pdfBytes = await pdf.save();

      // Format filename with date
      DateTime now = DateTime.now();
      String formattedDate = DateFormat("yy-MM-dd_HH-mm").format(now);
      String fileName = "experimentation_results_$formattedDate";

      try {
        // Save the PDF file to the app's document directory
        final File savedFile = await _writePdfBytes(fileName, pdfBytes);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF saved successfully to: ${savedFile.path}')),
          );
        }

        print("File saved to: ${savedFile.path}");

      } catch (e) {
        print("Error saving file: $e");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not save PDF: $e')),
          );
        }
      }
    } catch (e) {
      print("Error creating PDF: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating PDF: $e')),
        );
      }
    }
  }

  /// Creates the table with all the experiment results
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
              padding: pw.EdgeInsets.all(5),
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

        // Conversion Success Section
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColors.green700,
          ),
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(5),
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

        // Performance Metrics Section
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColors.orange700,
          ),
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(5),
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

  /// Creates a single data row for the table
  pw.TableRow _createDataRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }
}
