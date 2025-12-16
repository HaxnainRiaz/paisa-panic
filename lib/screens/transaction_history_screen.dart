import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../widgets/transaction_item.dart';
import '../widgets/app_scaffold.dart';
import '../models/transaction.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../routes/app_routes.dart';

/// Transaction history screen with filters and sorting
class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Transaction> _allTransactions = [];
  List<Transaction> _filteredTransactions = [];
  TransactionType? _selectedType;
  String? _selectedCategory;
  String _sortBy = 'date'; // 'date' or 'amount'

  void _applyFilters() {
    setState(() {
      _filteredTransactions = _allTransactions.where((transaction) {
        if (_selectedType != null && transaction.type != _selectedType) {
          return false;
        }
        if (_selectedCategory != null &&
            transaction.category != _selectedCategory) {
          return false;
        }
        return true;
      }).toList();

      // Sort
      if (_sortBy == 'date') {
        _filteredTransactions.sort((a, b) => b.date.compareTo(a.date));
      } else {
        _filteredTransactions.sort((a, b) => b.amount.compareTo(a.amount));
      }
    });
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Transactions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Type'),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<TransactionType?>(
                    title: const Text('All'),
                    value: null,
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                      _applyFilters();
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<TransactionType?>(
                    title: const Text('Income'),
                    value: TransactionType.income,
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                      _applyFilters();
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<TransactionType?>(
                    title: const Text('Expense'),
                    value: TransactionType.expense,
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                      _applyFilters();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Sort By'),
            RadioListTile<String>(
              title: const Text('Date'),
              value: 'date',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                _applyFilters();
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Amount'),
              value: 'amount',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                _applyFilters();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.uid;

    if (userId == null) {
      return AppScaffold(
        title: 'Transaction History',
        currentRoute: AppRoutes.transactionHistory,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return AppScaffold(
      title: 'Transaction History',
      currentRoute: AppRoutes.transactionHistory,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => _showFilterDialog(context),
        ),
      ],
      body: StreamBuilder<List<Transaction>>(
        stream: _firestoreService.getTransactions(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final transactions = snapshot.data ?? [];
          if (_allTransactions != transactions) {
            _allTransactions = transactions;
            _applyFilters();
          }

          if (_filteredTransactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions found',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: _filteredTransactions.length,
            itemBuilder: (context, index) {
              return TransactionItem(
                transaction: _filteredTransactions[index],
              );
            },
          );
        },
      ),
    );
  }
}

