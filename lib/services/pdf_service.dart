import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/person.dart';
import '../models/shared_plate.dart';
import '../models/shared_expense.dart';
import '../models/transaction.dart';

class PdfService {
  // TODO: To support Arabic text properly, load an Arabic-compatible TTF font:
  //   final arabicFont = pw.Font.ttf(await rootBundle.load('assets/fonts/Cairo-Regular.ttf'));
  // Then pass it as the font parameter to all pw.Text widgets.

  /// Generates a PDF bill summary and returns the raw bytes.
  static Future<Uint8List> generateBillPdf({
    required List<Person> people,
    required List<SharedPlate> sharedPlates,
    required List<SharedExpense> sharedExpenses,
    required List<Transaction> settlements,
    required double totalBill,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}  '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';

    // Pre-compute per-person totals for the summary table.
    final totalSharedExpenses = sharedExpenses.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );
    final sharedExpensePerPerson = people.isEmpty
        ? 0.0
        : totalSharedExpenses / people.length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // ── Title ──────────────────────────────────────────────
            pw.Center(
              child: pw.Text(
                // NOTE: Arabic glyphs will render correctly only with an
                // Arabic-compatible font loaded via pw.Font.ttf.
                'Ana Badaye3 Ya 3am Sobhy! - Bill Summary',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Text(
                // Keep the Arabic title as a subtitle for reference.
                '\u0623\u0646\u0627 \u0628\u0636\u064a\u0639 \u064a\u0627 \u0639\u0645 \u0635\u0628\u062d\u064a! - \u0641\u0627\u062a\u0648\u0631\u0629 \u0627\u0644\u062d\u0633\u0627\u0628',
                style: const pw.TextStyle(fontSize: 14),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Divider(),
            pw.SizedBox(height: 4),

            // ── Date & total ───────────────────────────────────────
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Date: $dateStr'),
                pw.Text(
                  'Total Bill: ${totalBill.toStringAsFixed(2)} EGP',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.SizedBox(height: 16),

            // ── Per-person summary table ───────────────────────────
            pw.Text(
              'Per-Person Summary',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _buildPersonTable(people, sharedPlates, sharedExpensePerPerson),
            pw.SizedBox(height: 20),

            // ── Shared plates section ──────────────────────────────
            pw.Text(
              'Shared Plates',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            if (sharedPlates.isEmpty)
              pw.Text('No shared plates.')
            else
              _buildSharedPlatesSection(sharedPlates, people),
            pw.SizedBox(height: 20),

            // ── Shared expenses section ────────────────────────────
            pw.Text(
              'Shared Expenses',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            if (sharedExpenses.isEmpty)
              pw.Text('No shared expenses.')
            else
              ..._buildSharedExpensesList(sharedExpenses, people.length),
            pw.SizedBox(height: 20),

            // ── Settlements section ────────────────────────────────
            pw.Text(
              'Settlements',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            if (settlements.isEmpty)
              pw.Text('No settlements needed — everyone is even!')
            else
              ..._buildSettlementsList(settlements),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ── Helpers ──────────────────────────────────────────────────────

  /// Builds the per-person summary table.
  static pw.Widget _buildPersonTable(
    List<Person> people,
    List<SharedPlate> sharedPlates,
    double sharedExpensePerPerson,
  ) {
    final headers = [
      'Name',
      'Personal',
      'Shared Plates',
      'Shared Exp.',
      'Total Owed',
      'Paid',
      'Net Balance',
    ];

    final data = people.map((person) {
      final personalTotal = person.totalPersonalItems;
      final sharedPlatesTotal = _personSharedPlatesTotal(
        person.id,
        sharedPlates,
      );
      final totalOwed =
          personalTotal + sharedPlatesTotal + sharedExpensePerPerson;
      final netBalance = totalOwed - person.amountPaid;

      return [
        person.name,
        personalTotal.toStringAsFixed(2),
        sharedPlatesTotal.toStringAsFixed(2),
        sharedExpensePerPerson.toStringAsFixed(2),
        totalOwed.toStringAsFixed(2),
        person.amountPaid.toStringAsFixed(2),
        netBalance.toStringAsFixed(2),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.centerLeft,
      headers: headers,
      data: data,
    );
  }

  /// Total shared-plate cost for a given person.
  static double _personSharedPlatesTotal(
    String personId,
    List<SharedPlate> sharedPlates,
  ) {
    double total = 0;
    for (final plate in sharedPlates) {
      if (plate.participantIds.contains(personId)) {
        total += plate.costPerPerson;
      }
    }
    return total;
  }

  /// Builds the shared plates section with participant names.
  static pw.Widget _buildSharedPlatesSection(
    List<SharedPlate> plates,
    List<Person> people,
  ) {
    final personMap = {for (final p in people) p.id: p.name};

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(3),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _cell('Plate Name', bold: true),
            _cell('Price', bold: true),
            _cell('Per Person', bold: true),
            _cell('Participants', bold: true),
          ],
        ),
        ...plates.map((plate) {
          final participantNames = plate.participantIds
              .map((id) => personMap[id] ?? id)
              .join(', ');
          return pw.TableRow(
            children: [
              _cell(plate.name),
              _cell(plate.price.toStringAsFixed(2)),
              _cell(plate.costPerPerson.toStringAsFixed(2)),
              _cell(participantNames),
            ],
          );
        }),
      ],
    );
  }

  /// Builds a list of shared-expense bullet entries.
  static List<pw.Widget> _buildSharedExpensesList(
    List<SharedExpense> expenses,
    int numPeople,
  ) {
    return expenses.map((e) {
      final perPerson = numPeople > 0 ? (e.amount / numPeople) : 0.0;
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Row(
          children: [
            pw.Text('\u2022  ${e.name}: '),
            pw.Text(
              '${e.amount.toStringAsFixed(2)} EGP total  '
              '(${perPerson.toStringAsFixed(2)} EGP/person)',
            ),
          ],
        ),
      );
    }).toList();
  }

  /// Builds the settlements list.
  static List<pw.Widget> _buildSettlementsList(List<Transaction> settlements) {
    return settlements.map((t) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Text(
          '${t.fromPersonName} pays ${t.amount.toStringAsFixed(2)} EGP to ${t.toPersonName}',
          // Arabic version (requires Arabic font):
          // '${t.fromPersonName} يدفع ${t.amount.toStringAsFixed(2)} ج.م إلى ${t.toPersonName}'
        ),
      );
    }).toList();
  }

  /// A small helper for table cells.
  static pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  // ── Print / Share ────────────────────────────────────────────────

  /// Opens the platform print dialog for the given PDF bytes.
  static Future<void> printPdf(Uint8List pdfData) async {
    await Printing.layoutPdf(
      onLayout: (_) async => pdfData,
      name: 'Bill Summary',
    );
  }
}
