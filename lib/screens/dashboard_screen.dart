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

/// Dashboard/Home screen showing financial overview
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
          for (var transaction in currentMonthTransactions) {
            if (transaction.type == TransactionType.income) {
              totalIncome += transaction.amount;
            } else {
              totalExpense += transaction.amount;
            }
          }
          final currentBalance = totalIncome - totalExpense;

          // Get recent transactions (last 5)
          final recentTransactions = transactions.take(5).toList();

          return _buildDashboardContent(
            context,
            currentBalance: currentBalance,
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            recentTransactions: recentTransactions,
            userId: userId,
          );
        },
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context, {
    required double currentBalance,
    required double totalIncome,
    required double totalExpense,
    required List<Transaction> recentTransactions,
    required String userId,
  }) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _firestoreService.getBudget(userId),
      builder: (context, budgetSnapshot) {
        final budget = budgetSnapshot.data;
        final monthlyBudget = (budget?['amount'] ?? 0).toDouble();
        final remainingBudget = monthlyBudget - totalExpense;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWeb = constraints.maxWidth > 600;
            final isLargeWeb = constraints.maxWidth > 900;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isWeb ? AppSpacing.lg : AppSpacing.md),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isLargeWeb ? 1200 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary cards
                      if (isLargeWeb)
                        _buildWebSummaryGrid(
                          currentBalance: currentBalance,
                          totalIncome: totalIncome,
                          totalExpense: totalExpense,
                          remainingBudget: remainingBudget,
                        )
                      else
                        _buildMobileSummaryCards(
                          context,
                          currentBalance: currentBalance,
                          totalIncome: totalIncome,
                          totalExpense: totalExpense,
                          remainingBudget: remainingBudget,
                        ),

                      SizedBox(height: isWeb ? AppSpacing.xl : AppSpacing.lg),

                      // Main content area
                      if (isLargeWeb)
                        _buildWebContentLayout(
                          recentTransactions: recentTransactions,
                          monthlyBudget: monthlyBudget,
                        )
                      else
                        _buildMobileContentLayout(
                          context,
                          recentTransactions: recentTransactions,
                          monthlyBudget: monthlyBudget,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWebSummaryGrid({
    required double currentBalance,
    required double totalIncome,
    required double totalExpense,
    required double remainingBudget,
  }) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 2.5,
      children: [
        SummaryCard(
          title: 'Current Balance',
          amount: '\$${currentBalance.toStringAsFixed(2)}',
          icon: Icons.account_balance_wallet,
          iconColor: AppColors.secondary,
          amountColor: currentBalance >= 0
              ? AppColors.secondary
              : AppColors.warning,
        ),
        SummaryCard(
          title: 'Monthly Income',
          amount: '\$${totalIncome.toStringAsFixed(2)}',
          icon: Icons.trending_up,
          iconColor: AppColors.secondary,
        ),
        SummaryCard(
          title: 'Monthly Expense',
          amount: '\$${totalExpense.toStringAsFixed(2)}',
          icon: Icons.trending_down,
          iconColor: AppColors.warning,
          amountColor: AppColors.warning,
        ),
        SummaryCard(
          title: 'Remaining Budget',
          amount: '\$${remainingBudget.toStringAsFixed(2)}',
          icon: Icons.savings,
          iconColor: remainingBudget >= 0
              ? AppColors.secondary
              : AppColors.warning,
          amountColor: remainingBudget >= 0
              ? AppColors.secondary
              : AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildMobileSummaryCards(
    BuildContext context, {
    required double currentBalance,
    required double totalIncome,
    required double totalExpense,
    required double remainingBudget,
  }) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width - 64,
            child: SummaryCard(
              title: 'Current Balance',
              amount: '\$${currentBalance.toStringAsFixed(2)}',
              icon: Icons.account_balance_wallet,
              iconColor: AppColors.secondary,
              amountColor: currentBalance >= 0
                  ? AppColors.secondary
                  : AppColors.warning,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: MediaQuery.of(context).size.width - 64,
            child: SummaryCard(
              title: 'Monthly Income',
              amount: '\$${totalIncome.toStringAsFixed(2)}',
              icon: Icons.trending_up,
              iconColor: AppColors.secondary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: MediaQuery.of(context).size.width - 64,
            child: SummaryCard(
              title: 'Monthly Expense',
              amount: '\$${totalExpense.toStringAsFixed(2)}',
              icon: Icons.trending_down,
              iconColor: AppColors.warning,
              amountColor: AppColors.warning,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: MediaQuery.of(context).size.width - 64,
            child: SummaryCard(
              title: 'Remaining Budget',
              amount: '\$${remainingBudget.toStringAsFixed(2)}',
              icon: Icons.savings,
              iconColor: remainingBudget >= 0
                  ? AppColors.secondary
                  : AppColors.warning,
              amountColor: remainingBudget >= 0
                  ? AppColors.secondary
                  : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebContentLayout({
    required List<Transaction> recentTransactions,
    required double monthlyBudget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 20,
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
                const SizedBox(height: AppSpacing.md),
                if (recentTransactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Center(
                      child: Text(
                        'No transactions yet',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  ...recentTransactions.map(
                    (transaction) => TransactionItem(transaction: transaction),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            children: [
              CustomCard(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.budget);
                },
                child: Column(
                  children: [
                    const Icon(
                      Icons.savings,
                      size: 48,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Budget',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '\$${monthlyBudget.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              CustomCard(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.reports);
                },
                child: Column(
                  children: [
                    const Icon(
                      Icons.analytics,
                      size: 48,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Reports',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileContentLayout(
    BuildContext context, {
    required List<Transaction> recentTransactions,
    required double monthlyBudget,
  }) {
    return Column(
      children: [
        // Quick actions
        Row(
          children: [
            Expanded(
              child: CustomCard(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.budget);
                },
                child: Column(
                  children: [
                    const Icon(
                      Icons.savings,
                      size: 32,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Budget',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: CustomCard(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.reports);
                },
                child: Column(
                  children: [
                    const Icon(
                      Icons.analytics,
                      size: 32,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Reports',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: CustomCard(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.categories);
                },
                child: Column(
                  children: [
                    const Icon(
                      Icons.category,
                      size: 32,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Recent transactions
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              const SizedBox(height: AppSpacing.md),
              if (recentTransactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: Text(
                      'No transactions yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                ...recentTransactions.map(
                  (transaction) => TransactionItem(transaction: transaction),
                ),
            ],
          ),
        ),
      ],
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
