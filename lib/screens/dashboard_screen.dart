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
  final bool hideShellElements;
  const DashboardScreen({super.key, this.hideShellElements = false});

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
      title: 'Paisa Panic',
      currentRoute: AppRoutes.dashboard,
      hideShellElements: widget.hideShellElements,
      actions: const [],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: _firestoreService.getTransactions(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data ?? [];
          final now = DateTime.now();
          final currentMonthTransactions = transactions.where((t) {
            return t.date.year == now.year && t.date.month == now.month;
          }).toList();

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
          final recentTransactions = transactions.take(5).toList();

          final finance = Provider.of<FinanceProvider>(context);
          final symbol = CurrencyHelper.getSymbol(finance.selectedCurrency);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  // Premium Balance Card
                  Hero(
                    tag: 'balance_card',
                    child: GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Balance',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            child: Text(
                              '$symbol${currentBalance.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              _buildCompactMetric(
                                label: 'Income',
                                amount: totalIncome,
                                symbol: symbol,
                                color: AppColors.secondary,
                                icon: Icons.arrow_downward,
                              ),
                              const SizedBox(width: 32),
                              _buildCompactMetric(
                                label: 'Expenses',
                                amount: totalExpense,
                                symbol: symbol,
                                color: AppColors.expense,
                                icon: Icons.arrow_upward,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),
                  
                  // Quick Actions Grid (4 columns)
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.75, // Allow more height for the labels
                    children: [
                      _buildQuickAction(
                        title: 'Budget',
                        icon: Icons.account_balance_wallet_outlined,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.budget),
                      ),
                      _buildQuickAction(
                        title: 'Reports',
                        icon: Icons.insert_chart_outlined_rounded,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.reports),
                      ),
                      _buildQuickAction(
                        title: 'Category',
                        icon: Icons.grid_view_rounded,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.categories),
                      ),
                      _buildQuickAction(
                        title: 'History',
                        icon: Icons.history_rounded,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.transactionHistory),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Recent Transactions Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.transactionHistory),
                        child: const Text('View All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  
                  if (recentTransactions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No transactions yet',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: recentTransactions.asMap().entries.map((entry) {
                        final t = entry.value;
                        final isLast = entry.key == recentTransactions.length - 1;
                        return Column(
                          children: [
                            TransactionItem(
                              transaction: t,
                              onEdit: () => _editTransaction(t),
                              onDelete: () => _confirmDelete(userId, t.id),
                            ),
                            if (!isLast)
                              Divider(
                                height: 1,
                                thickness: 0.5,
                                indent: 56,
                                color: Colors.black.withValues(alpha: 0.05),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompactMetric({
    required String label,
    required double amount,
    required String symbol,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 10),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$symbol${amount.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
          ),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  void _editTransaction(Transaction t) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(
          type: t.type,
          transactionToEdit: t,
        ),
      ),
    );
  }

  void _confirmDelete(String userId, String transactionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Provider.of<FinanceProvider>(context, listen: false)
                  .deleteTransaction(userId, transactionId);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text('Add Transaction', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 24),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE1FBF2),
                child: Icon(Icons.add_chart_rounded, color: AppColors.secondary),
              ),
              title: const Text('Income', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Salary, Gifts, Investments'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRoutes.addIncome);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFEE2E2),
                child: Icon(Icons.analytics_outlined, color: AppColors.expense),
              ),
              title: const Text('Expense', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Food, Rent, Shopping'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRoutes.addExpense);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
