import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/inheritance_result.dart';
import '../../domain/entities/heir_share.dart';
import '../../domain/entities/heir.dart';

/// Screen for displaying inheritance calculation results
class ResultDisplayScreen extends StatefulWidget {
  final InheritanceResult result;

  const ResultDisplayScreen({
    super.key,
    required this.result,
  });

  @override
  State<ResultDisplayScreen> createState() => _ResultDisplayScreenState();
}

class _ResultDisplayScreenState extends State<ResultDisplayScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Inheritance Results',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareResults,
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printResults,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            _buildSummaryCard(),
            const SizedBox(height: 16),

            // Heir shares
            _buildHeirSharesSection(),
            const SizedBox(height: 16),

            // Calculation steps
            _buildCalculationStepsSection(),
            const SizedBox(height: 16),

            // References
            _buildReferencesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final totalAmount = widget.result.heirShares.fold<double>(
      0,
      (sum, share) => sum + share.shareAmount,
    );

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: Colors.green[700], size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Calculation Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Deceased', widget.result.estate.deceasedName),
            _buildSummaryRow('Total Estate',
                '৳${widget.result.estate.totalValue.toStringAsFixed(2)}'),
            _buildSummaryRow(
                'Net Estate', '৳${totalAmount.toStringAsFixed(2)}'),
            _buildSummaryRow(
                'Total Heirs', '${widget.result.heirShares.length}'),
            _buildSummaryRow(
                'Calculation Method', widget.result.scholarReference),
            _buildSummaryRow(
                'Date', _formatDate(widget.result.calculationDate)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeirSharesSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: Colors.green[700], size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Heir Shares',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...widget.result.heirShares
                .map((share) => _buildHeirShareCard(share)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeirShareCard(HeirShare share) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      share.heir.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      share.heir.arabicName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontFamily: 'Amiri',
                      ),
                    ),
                    Text(
                      share.heir.bengaliName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontFamily: 'NotoSansBengali',
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '৳${share.shareAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  Text(
                    share.sharePercentage,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getShareTypeColor(share.shareType),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getShareTypeText(share.shareType),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (share.calculationNotes.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(),
            ...share.calculationNotes.map((note) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $note',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildCalculationStepsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list_alt, color: Colors.green[700], size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Calculation Steps',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...widget.result.calculationSteps
                .map((step) => _buildStepCard(step)),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(CalculationStep step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${step.stepNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.stepTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            step.stepDescription,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          if (step.appliedRules.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Applied Rules:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            ...step.appliedRules.map((rule) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Text(
                    '• $rule',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildReferencesSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.book, color: Colors.green[700], size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Islamic References',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.result.quranicReferences.isNotEmpty) ...[
              const Text(
                'Quranic Verses:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              ...widget.result.quranicReferences
                  .take(3)
                  .map((ref) => _buildReferenceCard(ref)),
              const SizedBox(height: 16),
            ],
            if (widget.result.hadithReferences.isNotEmpty) ...[
              const Text(
                'Hadith References:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              ...widget.result.hadithReferences
                  .take(3)
                  .map((ref) => _buildReferenceCard(ref)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceCard(dynamic reference) {
    final isQuranic = reference is QuranicReference;
    final title = isQuranic
        ? '${reference.surah} ${reference.ayah}'
        : reference.hadithNumber;
    final source = isQuranic ? 'Quran' : reference.source;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isQuranic ? Icons.menu_book : Icons.format_quote,
                color: Colors.orange[700],
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  source,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            reference.translation,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getShareTypeColor(ShareType shareType) {
    switch (shareType) {
      case ShareType.fixedShare:
        return Colors.green[600]!;
      case ShareType.residueShare:
        return Colors.blue[600]!;
      case ShareType.blockedShare:
        return Colors.red[600]!;
    }
  }

  String _getShareTypeText(ShareType shareType) {
    switch (shareType) {
      case ShareType.fixedShare:
        return 'FIXED';
      case ShareType.residueShare:
        return 'RESIDUE';
      case ShareType.blockedShare:
        return 'BLOCKED';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _shareResults() {
    final resultText = _generateShareText();
    Clipboard.setData(ClipboardData(text: resultText));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Results copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _printResults() {
    // TODO: Implement print functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Print functionality coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  String _generateShareText() {
    final buffer = StringBuffer();
    buffer.writeln('Islamic Inheritance Calculation Results');
    buffer.writeln('=====================================');
    buffer.writeln('Deceased: ${widget.result.estate.deceasedName}');
    buffer.writeln(
        'Total Estate: ৳${widget.result.estate.totalValue.toStringAsFixed(2)}');
    buffer.writeln(
        'Calculation Date: ${_formatDate(widget.result.calculationDate)}');
    buffer.writeln('');
    buffer.writeln('Heir Shares:');

    for (final share in widget.result.heirShares) {
      buffer.writeln(
          '• ${share.heir.name}: ${share.sharePercentage} (৳${share.shareAmount.toStringAsFixed(2)})');
    }

    buffer.writeln('');
    buffer.writeln('Method: ${widget.result.scholarReference}');

    return buffer.toString();
  }
}
