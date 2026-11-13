import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bill_history.dart';
import '../providers/bill_provider.dart';
import 'results_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سجل الفواتير')),
      body: Consumer<BillProvider>(
        builder: (context, provider, _) {
          if (provider.billHistory.isEmpty) {
            return const Center(child: Text('لا توجد فواتير محفوظة بعد'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.billHistory.length,
            itemBuilder: (context, index) {
              final bill = provider.billHistory[index];
              return _HistoryCard(
                bill: bill,
                onTap: () {
                  provider.loadBillFromHistory(bill);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ResultsScreen()),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.bill, required this.onTap});

  final BillHistory bill;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = bill.date.toLocal();
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} - ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(Icons.receipt_long, color: colorScheme.primary, size: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${bill.totalBill.toStringAsFixed(2)} ج.م',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(formattedDate),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left),
            ],
          ),
        ),
      ),
    );
  }
}
