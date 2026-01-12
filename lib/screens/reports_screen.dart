import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../widgets/custom_card.dart';
import '../widgets/app_scaffold.dart';
import '../routes/app_routes.dart';
import '../models/transaction.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../helpers/currency_helper.dart';
import '../providers/finance_provider.dart';

/// Reports & Analytics screen with charts and summaries
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'monthly'; // 'daily', 'monthly'
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final financeProvider = Provider.of<FinanceProvider>(context);
    final userId = authProvider.user?.uid;
    final symbol = CurrencyHelper.getSymbol(financeProvider.selectedCurrency);

    if (userId == null) {
      return AppScaffold(
        title: 'Reports & Analytics',
        currentRoute: AppRoutes.reports,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return AppScaffold(
      title: 'Reports & Analytics',
      currentRoute: AppRoutes.reports,
      body: StreamBuilder<List<Transaction>>(
        stream: _firestoreService.getTransactions(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data ?? [];

          // Build category expenses & daily breakdown
          final categoryExpenses = <String, double>{};
          final dailyBreakdown = <String, double>{};
          double totalIncome = 0;
          double totalExpense = 0;

          for (var transaction in transactions) {
            if (transaction.type == TransactionType.expense) {
              categoryExpenses[transaction.category] =
                  (categoryExpenses[transaction.category] ?? 0) +
                  transaction.amount;
              totalExpense += transaction.amount;
            } else {
              totalIncome += transaction.amount;
            }

            final dateKey = '${transaction.date.day}/${transaction.date.month}';
            dailyBreakdown[dateKey] =
                (dailyBreakdown[dateKey] ?? 0) + transaction.amount;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period selector
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Monthly'),
                        selected: _selectedPeriod == 'monthly',
                        onSelected: (selected) {
                          setState(() {
                            _selectedPeriod = 'monthly';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Daily'),
                        selected: _selectedPeriod == 'daily',
                        onSelected: (selected) {
                          setState(() {
                            _selectedPeriod = 'daily';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Monthly Summary
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monthly Summary',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Income',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$symbol${totalIncome.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Expense',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$symbol${totalExpense.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Net Balance',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$symbol${(totalIncome - totalExpense).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Category-wise Analysis
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category-wise Expense Analysis',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ...categoryExpenses.entries.map((entry) {
                        final percentage = (entry.value / totalExpense) * 100;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '$symbol${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: percentage / 100,
                                  minHeight: 8,
                                  backgroundColor: AppColors.background,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Daily Breakdown (Placeholder Chart UI)
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily Breakdown',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bar_chart,
                                size: 48,
                                color: AppColors.textSecondary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Chart visualization placeholder',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Daily transactions: ${dailyBreakdown.length} days',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
