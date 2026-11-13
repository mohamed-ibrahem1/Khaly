import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';

import '../providers/bill_provider.dart';
import '../models/person.dart';
import '../widgets/settlement_card.dart';
import '../services/pdf_service.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('الحساب')),
      body: Consumer<BillProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ──── إجمالي الفاتورة ────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'إجمالي الفاتورة',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${provider.getTotalBill().toStringAsFixed(2)} ج.م',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ──── تفاصيل كل شخص ────
                Text(
                  'تفاصيل كل شخص 📊',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...provider.people.map(
                  (person) =>
                      _buildPersonBreakdownCard(context, provider, person),
                ),
                const SizedBox(height: 20),

                // ──── التسويات ────
                if (provider.settlements.isNotEmpty) ...[
                  Text(
                    'التسويات 🤝',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...provider.settlements.map(
                    (t) => SettlementCard(transaction: t),
                  ),
                ],

                if (provider.settlements.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'مفيش تسويات – الكل متساوي!',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // ──── أزرار التصدير ────
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _exportPdf(context, provider),
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('PDF ارسال'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor: colorScheme.error,
                          foregroundColor: colorScheme.onError,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _copyToWhatsApp(context, provider),
                        icon: const Icon(Icons.copy),
                        label: const Text('نسخ'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor: colorScheme.secondary,
                          foregroundColor: colorScheme.onSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonBreakdownCard(
    BuildContext context,
    BillProvider provider,
    Person person,
  ) {
    final personalTotal = provider.getPersonSubtotal(person.id);
    final sharedPlatesTotal = provider.getPersonSharedPlatesTotal(person.id);
    final sharedExpensesShare = provider.getPersonSharedExpensesShare();
    final totalOwed = provider.getPersonTotalOwed(person.id);
    final netBalance = provider.getPersonNetBalance(person.id);

    final isCreditor = netBalance < 0;
    final balanceColor = isCreditor
        ? const Color(0xFF00E676) // green — paid more
        : netBalance > 0
        ? const Color(0xFFFF5252) // red — owes
        : Colors.white70;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            Text(
              person.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.white24),
            _buildRow('الأصناف الشخصية', personalTotal),
            _buildRow('نصيب الأطباق المشتركة', sharedPlatesTotal),
            _buildRow('نصيب المصاريف المشتركة', sharedExpensesShare),
            const Divider(color: Colors.white24),
            _buildRow('إجمالي المطلوب', totalOwed, bold: true),
            _buildRow(
              'المدفوع',
              person.amountPaid,
              color: const Color(0xFF00B0FF),
            ),
            const Divider(color: Colors.white24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  netBalance > 0
                      ? 'مدين (عليه)'
                      : netBalance < 0
                      ? 'دائن (ليه)'
                      : 'متساوي',
                  style: TextStyle(
                    color: balanceColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${netBalance.abs().toStringAsFixed(2)} ج.م',
                  style: TextStyle(
                    color: balanceColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    double amount, {
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color ?? Colors.white70,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} ج.م',
            style: TextStyle(
              color: color ?? Colors.white,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, BillProvider provider) async {
    try {
      final pdfData = await PdfService.generateBillPdf(
        people: provider.people,
        sharedPlates: provider.sharedPlates,
        sharedExpenses: provider.sharedExpenses,
        settlements: provider.settlements,
        totalBill: provider.getTotalBill(),
      );
      await Printing.layoutPdf(onLayout: (_) => pdfData);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في إنشاء PDF: $e')));
      }
    }
  }

  void _copyToWhatsApp(BuildContext context, BillProvider provider) {
    final text = provider.generateShareText();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم النسخ! 📋'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
