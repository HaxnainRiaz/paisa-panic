import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../models/transaction.dart';
import '../models/user.dart';

/// Budget screen with monthly budget setting and progress tracking
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _budgetController = TextEditingController();
  double _monthlyBudget = MockUser.getCurrentUser().monthlyBudget;
  bool _isEditing = false;

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  double _getTotalExpenses() {
    final transactions = MockTransactions.getTransactions();
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  void _handleSaveBudget() {
    final newBudget = double.tryParse(_budgetController.text);
    if (newBudget != null && newBudget > 0) {
      setState(() {
        _monthlyBudget = newBudget;
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Budget updated successfully!'),
          backgroundColor: AppColors.secondary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalExpenses = _getTotalExpenses();
    final remainingBudget = _monthlyBudget - totalExpenses;
    final percentageUsed = (_monthlyBudget > 0) ? (totalExpenses / _monthlyBudget) : 0.0;
    final isOverBudget = remainingBudget < 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Budget'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Budget card
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Monthly Budget',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(_isEditing ? Icons.close : Icons.edit),
                        onPressed: () {
                          setState(() {
                            _isEditing = !_isEditing;
                            if (_isEditing) {
                              _budgetController.text = _monthlyBudget.toStringAsFixed(2);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (_isEditing) ...[
                    CustomTextField(
                      label: 'Monthly Budget',
                      hint: '0.00',
                      controller: _budgetController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.attach_money,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomButton(
                      text: 'Save Budget',
                      onPressed: _handleSaveBudget,
                    ),
                  ] else ...[
                    Text(
                      '\$${_monthlyBudget.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Progress indicator
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Budget Usage',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isOverBudget
                              ? AppColors.warning.withOpacity(0.1)
                              : AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${(percentageUsed * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: isOverBudget ? AppColors.warning : AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percentageUsed > 1.0 ? 1.0 : percentageUsed,
                      minHeight: 12,
                      backgroundColor: AppColors.background,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOverBudget ? AppColors.warning : AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Spent',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '\$${totalExpenses.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Remaining',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '\$${remainingBudget.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isOverBudget ? AppColors.warning : AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Warning card if over budget
            if (isOverBudget)
              CustomCard(
                color: AppColors.warning.withOpacity(0.1),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 32,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Budget Exceeded!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'You have exceeded your monthly budget by \$${remainingBudget.abs().toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

