import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/zakat_calculation.dart';

class PdfGeneratorService {
  Future<String> generateZakatReport(ZakatCalculation calculation) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Zakat Calculation Report'),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Calculation Date: ${calculation.calculationDate}'),
              pw.Text('Currency: ${calculation.currency}'),
              pw.SizedBox(height: 20),
              pw.Text('Results:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text('Total Assets: ${calculation.result.totalAssets.toStringAsFixed(2)}'),
              pw.Text('Total Liabilities: ${calculation.result.totalLiabilities.toStringAsFixed(2)}'),
              pw.Text('Zakatable Wealth: ${calculation.result.zakatableWealth.toStringAsFixed(2)}'),
              pw.Text('Nisab Threshold: ${calculation.result.nisabThreshold.toStringAsFixed(2)}'),
              pw.Text('Zakat Due: ${calculation.result.zakatDue.toStringAsFixed(2)}'),
              pw.Text('Is Zakat Required: ${calculation.result.isZakatRequired ? "Yes" : "No"}'),
              pw.SizedBox(height: 20),
              pw.Text('Generated on: ${DateTime.now()}'),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'zakat_report_${calculation.id}.pdf';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    
    return file.path;
  }
}
