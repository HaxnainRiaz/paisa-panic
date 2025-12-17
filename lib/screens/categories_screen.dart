import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../widgets/custom_card.dart';
import '../models/category.dart';
import '../models/transaction.dart';

/// Categories management screen
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Category> _incomeCategories = MockCategories.getIncomeCategories();
  List<Category> _expenseCategories = MockCategories.getExpenseCategories();

  void _showAddCategoryDialog(bool isIncome) {
    final nameController = TextEditingController();
    final iconController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${isIncome ? 'Income' : 'Expense'} Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: iconController,
              decoration: const InputDecoration(
                labelText: 'Icon Name (e.g., restaurant)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final newCategory = Category(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  type: isIncome
                      ? TransactionType.income
                      : TransactionType.expense,
                  icon: iconController.text.isEmpty
                      ? 'category'
                      : iconController.text,
                );
                setState(() {
                  if (isIncome) {
                    _incomeCategories.add(newCategory);
                  } else {
                    _expenseCategories.add(newCategory);
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(Category category) {
    final nameController = TextEditingController(text: category.name);
    final iconController = TextEditingController(text: category.icon);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: iconController,
              decoration: const InputDecoration(
                labelText: 'Icon Name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  final index = category.type == TransactionType.income
                      ? _incomeCategories.indexWhere((c) => c.id == category.id)
                      : _expenseCategories.indexWhere(
                          (c) => c.id == category.id,
                        );

                  final updatedCategory = Category(
                    id: category.id,
                    name: nameController.text,
                    type: category.type,
                    icon: iconController.text.isEmpty
                        ? 'category'
                        : iconController.text,
                  );

                  if (category.type == TransactionType.income) {
                    _incomeCategories[index] = updatedCategory;
                  } else {
                    _expenseCategories[index] = updatedCategory;
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (category.type == TransactionType.income) {
                  _incomeCategories.removeWhere((c) => c.id == category.id);
                } else {
                  _expenseCategories.removeWhere((c) => c.id == category.id);
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Category deleted')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories, bool isIncome) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isIncome ? AppColors.secondary : AppColors.warning)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIconData(category.icon),
              color: isIncome ? AppColors.secondary : AppColors.warning,
            ),
          ),
          title: Text(category.name, overflow: TextOverflow.ellipsis),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _showEditCategoryDialog(category),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                color: AppColors.warning,
                onPressed: () => _showDeleteConfirmation(category),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'movie':
        return Icons.movie;
      case 'receipt':
        return Icons.receipt;
      case 'home':
        return Icons.home;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'work':
        return Icons.work;
      case 'laptop':
        return Icons.laptop;
      case 'trending_up':
        return Icons.trending_up;
      case 'store':
        return Icons.store;
      case 'attach_money':
        return Icons.attach_money;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Categories')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Income Categories
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Income Categories',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => _showAddCategoryDialog(true),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            CustomCard(child: _buildCategoryList(_incomeCategories, true)),
            const SizedBox(height: AppSpacing.lg),

            // Expense Categories
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Expense Categories',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => _showAddCategoryDialog(false),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            CustomCard(child: _buildCategoryList(_expenseCategories, false)),
          ],
        ),
      ),
    );
  }
}
