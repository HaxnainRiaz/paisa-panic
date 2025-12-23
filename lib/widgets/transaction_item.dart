import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../helpers/currency_helper.dart';
import '../providers/finance_provider.dart';

/// Transaction list item widget
class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionItem({
    super.key, 
    required this.transaction, 
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  String _formatCurrency(double amount, String symbol) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'restaurant':
        return Icons.restaurant;
      case 'transport':
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping':
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'bills':
      case 'receipt':
        return Icons.receipt;
      case 'rent':
      case 'home':
        return Icons.home;
      case 'healthcare':
      case 'local_hospital':
        return Icons.local_hospital;
      case 'education':
      case 'school':
        return Icons.school;
      case 'salary':
      case 'work':
        return Icons.work;
      case 'freelance':
      case 'laptop':
      case 'laptop_mac':
        return Icons.laptop;
      case 'investment':
      case 'trending_up':
      case 'show_chart':
        return Icons.trending_up;
      case 'business':
      case 'store':
        return Icons.store;
      case 'travel':
      case 'flight':
        return Icons.flight;
      case 'pet':
      case 'pets':
        return Icons.pets;
      case 'charity':
      case 'volunteer_activism':
        return Icons.volunteer_activism;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? AppColors.secondary : AppColors.warning;
    final amountPrefix = isIncome ? '+' : '-';

    final finance = Provider.of<FinanceProvider>(context);
    final symbol = CurrencyHelper.getSymbol(finance.selectedCurrency);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: amountColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getCategoryIcon(transaction.category),
                color: amountColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.category,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (transaction.note != null || transaction.source != null)
                    const SizedBox(height: 4),
                  if (transaction.note != null)
                    Text(
                      transaction.note!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (transaction.source != null)
                    Text(
                      transaction.source!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(transaction.date),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$amountPrefix${_formatCurrency(transaction.amount, symbol)}',
              style: TextStyle(
                fontSize: 16, // Reduced slightly to fit currency code
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
            if (onEdit != null || onDelete != null)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                onSelected: (value) {
                  if (value == 'edit' && onEdit != null) onEdit!();
                  if (value == 'delete' && onDelete != null) onDelete!();
                },
                itemBuilder: (context) => [
                  if (onEdit != null)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                  if (onDelete != null)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: AppColors.warning),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: AppColors.warning)),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
