import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PdfGeneratorService {
  Future<File> generateZakatReport({
    required Map<String, dynamic> zakatData,
    required String fileName,
  }) async {
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
              pw.Text('Total Wealth: ${zakatData['totalWealth']}'),
              pw.Text('Zakat Due: ${zakatData['zakatDue']}'),
              pw.Text('Nisab Threshold: ${zakatData['nisab']}'),
              pw.SizedBox(height: 20),
              pw.Text('Generated on: ${DateTime.now().toString()}'),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  Future<File> generateIslamicWill({
    required Map<String, dynamic> willData,
    required String fileName,
  }) async {
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
                child: pw.Text('Islamic Will (Wasiyyah)'),
              ),
              pw.SizedBox(height: 20),
              pw.Text('In the name of Allah, the Most Gracious, the Most Merciful'),
              pw.SizedBox(height: 20),
              pw.Text('Testator: ${willData['testatorName']}'),
              pw.Text('Date: ${willData['date']}'),
              pw.SizedBox(height: 20),
              pw.Text('This is my last will and testament...'),
              // Add more will content based on willData
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }
}
