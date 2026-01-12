import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/transaction.dart' as app_models;
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../routes/app_routes.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AddTransactionScreen extends StatefulWidget {
  final app_models.TransactionType type;

  const AddTransactionScreen({super.key, required this.type});

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

  StreamSubscription<List<Category>>? _categoriesSub;

  @override
  void initState() {
    super.initState();
  }

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

          // Merge with defaults
          final defaults = MockCategories.getExpenseCategories();
          final map = {for (var d in defaults) d.name: d};
          for (var c in filtered) {
            if (c.isCustom) {
              map[c.id] = c;
            } else {
              map[c.name] = c;
            }
          }

          if (mounted) setState(() => _categories = map.values.toList());
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
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user == null) return;

    setState(() => _isLoading = true);

    try {
      final transaction = app_models.Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: double.parse(_amountController.text),
        type: widget.type,
        category: _selectedCategory!.name,
        date: _selectedDate,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );

      await _firestoreService.addTransaction(auth.user!.uid, transaction);

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.type == app_models.TransactionType.income
                ? 'Income added successfully'
                : 'Expense added successfully',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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

    return AppScaffold(
      title: isIncome ? 'Add Income' : 'Add Expense',
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
                text: isIncome ? 'Save Income' : 'Save Expense',
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
