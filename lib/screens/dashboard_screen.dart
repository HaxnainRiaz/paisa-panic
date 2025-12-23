import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../widgets/custom_card.dart';
import '../widgets/transaction_item.dart';
import '../widgets/app_scaffold.dart';
import '../models/transaction.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../routes/app_routes.dart';
import '../providers/finance_provider.dart';
import 'add_transaction_screen.dart';

import '../helpers/currency_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.uid;

    if (userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AppScaffold(
      title: 'Dashboard',
      currentRoute: AppRoutes.dashboard,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionDialog(context),
        label: const Text('Add Transaction'),
        icon: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: _firestoreService.getTransactions(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final transactions = snapshot.data ?? [];
          final now = DateTime.now();
          final currentMonthTransactions = transactions.where((t) {
            return t.date.year == now.year && t.date.month == now.month;
          }).toList();

          // Calculate totals
          double totalIncome = 0;
          double totalExpense = 0;
          for (var t in currentMonthTransactions) {
            if (t.type == TransactionType.income) {
              totalIncome += t.amount;
            } else {
              totalExpense += t.amount;
            }
          }
          final currentBalance = totalIncome - totalExpense;

          // Get recent transactions (last 5)
          final recentTransactions = transactions.take(5).toList();

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Summary cards
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // center all cards
                      children: [
                        _buildSummaryCard(
                          title: 'Current Balance',
                          amount: currentBalance,
                          icon: Icons.account_balance_wallet,
                          color: currentBalance >= 0
                              ? AppColors.secondary
                              : AppColors.warning,
                        ),
                        const SizedBox(width: 8), // smaller space between cards
                        _buildSummaryCard(
                          title: 'Monthly Income',
                          amount: totalIncome,
                          icon: Icons.trending_up,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        _buildSummaryCard(
                          title: 'Monthly Expense',
                          amount: totalExpense,
                          icon: Icons.trending_down,
                          color: AppColors.warning,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Quick Action Buttons: Budget, Reports, Categories
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // centers buttons
                    children: [
                  Flexible(
                    flex: 1,
                    child: _buildQuickAction(
                      title: 'Budget',
                      icon: Icons.savings,
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.budget);
                      },
                    ),
                  ),
                  const SizedBox(width: 4), // Reduced spacing
                  Flexible(
                    flex: 1,
                    child: _buildQuickAction(
                      title: 'Reports',
                      icon: Icons.analytics,
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.reports);
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    flex: 1,
                    child: _buildQuickAction(
                      title: 'Categories',
                      icon: Icons.category,
                      onTap: () {
                        Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.categories);
                      },
                    ),
                  ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Recent Transactions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.transactionHistory);
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  if (recentTransactions.isEmpty)
                    const Center(
                      child: Text(
                        'No transactions yet',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  else
                    Column(
                      children: recentTransactions
                          .map((t) => TransactionItem(
                                transaction: t,
                                onEdit: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddTransactionScreen(
                                        type: t.type,
                                        transactionToEdit: t,
                                      ),
                                    ),
                                  );
                                },
                                onDelete: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Transaction'),
                                      content: const Text('Are you sure you want to delete this transaction?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(ctx);
                                            await Provider.of<FinanceProvider>(context, listen: false)
                                                .deleteTransaction(userId, t.id);
                                          },
                                          child: const Text('Delete', style: TextStyle(color: AppColors.warning)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    // Get currency symbol from provider
    final finance = Provider.of<FinanceProvider>(context);
    final symbol = CurrencyHelper.getSymbol(finance.selectedCurrency);

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: SizedBox(
        width: 170, // Increased width slightly
        child: CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Icon center
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: AppSpacing.sm),
              // Text and Amount Left Aligned inside a container/column
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12, // Smaller font as requested
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$symbol${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2), // Reduced padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.secondary, size: 24), // Reduced icon size
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.visible, // User said "hided the text... i dont want this". Visible means no ellipsis? But might overflow. Use `fittedBox`?
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), // Reduced font
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Transaction',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: const Icon(
                Icons.trending_up,
                color: AppColors.secondary,
              ),
              title: const Text('Add Income'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRoutes.addIncome);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.trending_down,
                color: AppColors.warning,
              ),
              title: const Text('Add Expense'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRoutes.addExpense);
              },
            ),
          ],
        ),
      ),
    );
  }
}
