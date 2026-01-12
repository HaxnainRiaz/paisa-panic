import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/currency_helper.dart';
import '../models/category.dart';
import '../models/transaction.dart' as app_models;
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../services/firestore_service.dart';
import '../routes/app_routes.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AddTransactionScreen extends StatefulWidget {
  final app_models.TransactionType type;
  final app_models.Transaction? transactionToEdit;

  const AddTransactionScreen({
    super.key, 
    required this.type,
    this.transactionToEdit,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  List<Category> _categories = [];
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.transactionToEdit != null) {
      _amountController.text = widget.transactionToEdit!.amount.toString();
      _noteController.text = widget.transactionToEdit!.note ?? '';
      _selectedDate = widget.transactionToEdit!.date;
      // Category will be selected when list loads if names match
    }
  }

  StreamSubscription<List<Category>>? _categoriesSub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user == null) return;

    _categoriesSub?.cancel();
    _categoriesSub = _firestoreService
        .userCategoriesStream(auth.user!.uid)
        .listen((list) {
          final filtered = list.where((c) => c.type == widget.type).toList();

          // Merge with defaults so recommended categories are always available
          final defaults = widget.type == app_models.TransactionType.income
              ? MockCategories.getIncomeCategories()
              : MockCategories.getExpenseCategories();

          final Map<String, Category> map = {for (var d in defaults) d.name: d};
          for (var c in filtered) {
            if (c.isCustom) {
              map[c.id] = c; // custom categories keyed by id
            } else {
              map[c.name] = c; // override default
            }
          }

          if (mounted) {
            setState(() {
              _categories = map.values.toList();
              
              if (widget.transactionToEdit != null && _selectedCategory == null) {
                 try {
                   _selectedCategory = _categories.firstWhere((c) => c.name == widget.transactionToEdit!.category);
                 } catch (_) {
                   // Category might have been deleted or renamed; keep null or pick first
                 }
              }

              if (_categories.isNotEmpty && _selectedCategory == null) {
                _selectedCategory = _categories.first;
              }
            });
          }
        });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _categoriesSub?.cancel();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select a category')));
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user == null) return;

    setState(() => _isLoading = true);

    // Get currency: if editing, keep original; else use selected global currency
    final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
    final currency = widget.transactionToEdit?.currency ?? financeProvider.selectedCurrency;

    try {
      final transaction = app_models.Transaction(
        id: widget.transactionToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        amount: double.parse(_amountController.text),
        type: widget.type,
        category: _selectedCategory!.name,
        date: _selectedDate,
        currency: currency,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );

      if (widget.transactionToEdit != null) {
        await financeProvider.updateTransaction(auth.user!.uid, transaction);
      } else {
        await _firestoreService.addTransaction(auth.user!.uid, transaction);
      }

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.transactionToEdit != null 
                ? 'Transaction updated'
                : (widget.type == app_models.TransactionType.income
                    ? 'Income added'
                    : 'Expense added'),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.type == app_models.TransactionType.income;
    final financeProvider = Provider.of<FinanceProvider>(context);
    final currencySymbol = CurrencyHelper.getSymbol(financeProvider.selectedCurrency);

    return AppScaffold(
      title: widget.transactionToEdit != null 
          ? 'Edit Transaction' 
          : (isIncome ? 'Add Income' : 'Add Expense'),
      currentRoute: isIncome ? AppRoutes.addIncome : AppRoutes.addExpense,
      showBottomNav: false,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(
                label: 'Amount',
                controller: _amountController,
                prefixText: currencySymbol,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter amount';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Invalid amount';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<Category>(
                initialValue: _selectedCategory,
                hint: const Text('Select Category'),
                items: _categories
                    .map(
                      (c) => DropdownMenuItem<Category>(
                        value: c,
                        child: Text(c.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
                validator: (value) => value == null ? 'Select category' : null,
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Note (optional)',
                controller: _noteController,
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                ),
              ),

              const SizedBox(height: 24),

              CustomButton(
                text: widget.transactionToEdit != null 
                    ? 'Update Transaction' 
                    : (isIncome ? 'Save Income' : 'Save Expense'),
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _saveTransaction,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
