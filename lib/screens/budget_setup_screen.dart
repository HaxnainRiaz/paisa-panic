import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_card.dart';
import '../services/firestore_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../routes/app_routes.dart';
import '../helpers/currency_helper.dart';
import '../providers/finance_provider.dart';

/// Guided budget setup screen for new users
class BudgetSetupScreen extends StatefulWidget {
  const BudgetSetupScreen({super.key});

  @override
  State<BudgetSetupScreen> createState() => _BudgetSetupScreenState();
}

class _BudgetSetupScreenState extends State<BudgetSetupScreen> {
  final PageController _pageController = PageController();
  final _amountController = TextEditingController();
  int _currentStep = 0;
  String _selectedPeriod = 'monthly';
  String _selectedCurrency = 'PKR';
  final List<String> _currencies = ['PKR', 'USD', 'EUR', 'GBP', 'INR', 'JPY', 'CAD'];
  double _totalBudget = 0;
  final Map<String, double> _categoryAllocations = {};
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    _pageController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      if (_currentStep == 0 && _amountController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a budget amount'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _completeSetup() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;

    try {
      await _firestoreService.setBudget(
        authProvider.user!.uid,
        amount: _totalBudget,
        period: _selectedPeriod,
        categoryAllocations: _categoryAllocations,
      );

      // Save Currency via Provider to sync local state
      if (!mounted) return;
      await Provider.of<FinanceProvider>(context, listen: false)
          .setCurrency(authProvider.user!.uid, _selectedCurrency);

      await authProvider.hasBudgetSetup();

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Budget Setup'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // Progress indicator
              Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(
                        right: index < 3 ? AppSpacing.sm : 0,
                      ),
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? AppColors.secondary
                            : AppColors.textSecondary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.xl),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    SingleChildScrollView(child: _buildStepAmountAndCurrency()), // Step 1: Amount & Currency
                    SingleChildScrollView(child: _buildStepPeriod()), // Step 2: Period
                    _buildStep3(),
                    SingleChildScrollView(child: _buildStepReview()),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Navigation buttons
              Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: CustomButton(
                        text: 'Back',
                        onPressed: _previousStep,
                        isOutlined: true,
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: CustomButton(
                      text: _currentStep == 3 ? 'Finish' : 'Next',
                      onPressed: _currentStep == 3 ? _completeSetup : _nextStep,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildStepPeriod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Budget Period',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose how often you want to track your budget',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        CustomCard(
          onTap: () {
            setState(() {
              _selectedPeriod = 'monthly';
            });
          },
          child: Row(
            children: [
              Radio<String>(
                value: 'monthly',
                groupValue: _selectedPeriod,
                onChanged: (value) {
                  setState(() {
                    _selectedPeriod = value!;
                  });
                },
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CustomCard(
          onTap: () {
            setState(() {
              _selectedPeriod = 'weekly';
            });
          },
          child: Row(
            children: [
              Radio<String>(
                value: 'weekly',
                groupValue: _selectedPeriod,
                onChanged: (value) {
                  setState(() {
                    _selectedPeriod = value!;
                  });
                },
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
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

  Widget _buildStepAmountAndCurrency() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total Budget & Currency',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Select your currency and budget limit.',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        DropdownButtonFormField<String>(
          initialValue: _selectedCurrency,
          decoration: const InputDecoration(
            labelText: 'Currency',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.currency_exchange),
          ),
          items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedCurrency = val);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        CustomTextField(
          label: 'Budget Amount',
          hint: '0.00',
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          prefixIcon: Icons.attach_money,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Enter amount';
            if (double.tryParse(value) == null) return 'Invalid amount';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStep3() {
    if (_amountController.text.isNotEmpty) {
      _totalBudget = double.tryParse(_amountController.text) ?? 0;
    }

    final categories = [
      'Food',
      'Transport',
      'Shopping',
      'Entertainment',
      'Bills',
      'Rent',
      'Healthcare',
      'Education',
      'Other',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Allocate Budget to Categories',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Distribute your budget across different categories (optional)',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final allocated = _categoryAllocations[category] ?? 0.0;
                        final symbol = CurrencyHelper.getSymbol(_selectedCurrency);
                        return CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '$symbol${allocated.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                    const SizedBox(height: 8),
                    TextField(
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter amount',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                         final amount = double.tryParse(value) ?? 0.0;
                         // symbol unused here but was defined previously? I'll remove it if unused to avoid warning, or keep it.
                         // The user code had `final symbol = ...`. I'll keep it or ignore.
                         // Actually I can just use amount.
                        
                         setState(() {
                          _categoryAllocations[category] = amount;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStepReview() {
    if (_amountController.text.isNotEmpty) {
      _totalBudget = double.tryParse(_amountController.text) ?? 0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review & Confirm',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.lg),
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Budget Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildSummaryRow(
                'Period',
                _selectedPeriod == 'monthly' ? 'Monthly' : 'Weekly',
              ),
              const Divider(),
              _buildSummaryRow(
                'Total Budget',
                '${CurrencyHelper.getSymbol(_selectedCurrency)}${_totalBudget.toStringAsFixed(2)}',
              ),
              if (_categoryAllocations.isNotEmpty) ...[
                const Divider(),
                const Text(
                  'Category Allocations:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ..._categoryAllocations.entries.map((entry) {
                  if (entry.value > 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key),
                          Text('${CurrencyHelper.getSymbol(_selectedCurrency)}${entry.value.toStringAsFixed(2)}'),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
