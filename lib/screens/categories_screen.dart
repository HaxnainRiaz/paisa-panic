import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/theme.dart';
import '../widgets/custom_card.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final FirestoreService _firestore = FirestoreService();

  // Recommended icons
  final Map<String, IconData> _availableIcons = {
    'salary': Icons.attach_money,
    'business': Icons.store,
    'gift': Icons.card_giftcard,
    'freelance': Icons.laptop_mac,
    'bonus': Icons.military_tech,
    'investment': Icons.show_chart,
    'food': Icons.restaurant,
    'transport': Icons.directions_car,
    'shopping': Icons.shopping_bag,
    'entertainment': Icons.movie,
    'bills': Icons.receipt,
    'health': Icons.local_hospital,
    'home': Icons.home,
    'education': Icons.school,
    'work': Icons.work,
    'travel': Icons.flight,
    'pet': Icons.pets,
    'charity': Icons.volunteer_activism,
    'attach_money': Icons.attach_money, // custom income
    'money_off': Icons.money_off, // custom expense
  };

  // Default icon for custom categories
  final IconData _defaultCustomIcon = Icons.category;

  List<Category> _defaultIncome = [];
  List<Category> _defaultExpense = [];

  @override
  void initState() {
    super.initState();
    _loadRecommendedCategories();
  }

  void _loadRecommendedCategories() {
    _defaultIncome = [
      Category(
        id: '1',
        name: 'Salary',
        type: TransactionType.income,
        icon: 'salary',
      ),
      Category(
        id: '2',
        name: 'Business',
        type: TransactionType.income,
        icon: 'business',
      ),
      Category(
        id: '3',
        name: 'Gift',
        type: TransactionType.income,
        icon: 'gift',
      ),
      Category(
        id: '4',
        name: 'Freelance',
        type: TransactionType.income,
        icon: 'freelance',
      ),
      Category(
        id: '5',
        name: 'Bonus',
        type: TransactionType.income,
        icon: 'bonus',
      ),
      Category(
        id: '6',
        name: 'Investment',
        type: TransactionType.income,
        icon: 'investment',
      ),
    ];

    _defaultExpense = [
      Category(
        id: '1',
        name: 'Food',
        type: TransactionType.expense,
        icon: 'food',
      ),
      Category(
        id: '2',
        name: 'Transport',
        type: TransactionType.expense,
        icon: 'transport',
      ),
      Category(
        id: '3',
        name: 'Shopping',
        type: TransactionType.expense,
        icon: 'shopping',
      ),
      Category(
        id: '4',
        name: 'Entertainment',
        type: TransactionType.expense,
        icon: 'entertainment',
      ),
      Category(
        id: '5',
        name: 'Bills',
        type: TransactionType.expense,
        icon: 'bills',
      ),
      Category(
        id: '6',
        name: 'Health',
        type: TransactionType.expense,
        icon: 'health',
      ),
      Category(
        id: '7',
        name: 'Home',
        type: TransactionType.expense,
        icon: 'home',
      ),
      Category(
        id: '8',
        name: 'Education',
        type: TransactionType.expense,
        icon: 'education',
      ),
      Category(
        id: '9',
        name: 'Work',
        type: TransactionType.expense,
        icon: 'work',
      ),
      Category(
        id: '10',
        name: 'Travel',
        type: TransactionType.expense,
        icon: 'travel',
      ),
      Category(
        id: '11',
        name: 'Pet',
        type: TransactionType.expense,
        icon: 'pet',
      ),
      Category(
        id: '12',
        name: 'Charity',
        type: TransactionType.expense,
        icon: 'charity',
      ),
    ];
  }

  void _addCategory(bool isIncome) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${isIncome ? 'Income' : 'Expense'} Category'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              final auth = Provider.of<AuthProvider>(context, listen: false);
              if (auth.user == null) return;

              final newCat = Category(
                id: '', // Firestore will generate
                name: nameController.text,
                type: isIncome
                    ? TransactionType.income
                    : TransactionType.expense,
                icon: isIncome ? 'attach_money' : 'money_off', // fixed icon
                isCustom: true,
              );

              await _firestore.addCategory(auth.user!.uid, newCat);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editCategory(Category cat) {
    final nameController = TextEditingController(text: cat.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              final auth = Provider.of<AuthProvider>(context, listen: false);
              if (auth.user == null) return;

              final updated = Category(
                id: cat.id,
                name: nameController.text,
                type: cat.type,
                icon: cat.icon,
                isCustom: cat.isCustom,
              );

              await _firestore.updateCategory(auth.user!.uid, updated);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(Category cat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${cat.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              if (auth.user == null) return;

              await _firestore.deleteCategory(auth.user!.uid, cat.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(Category cat, bool isIncome) {
    final icon = _availableIcons[cat.icon] ?? _defaultCustomIcon;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: (isIncome ? AppColors.secondary : AppColors.warning)
            .withOpacity(0.2),
        child: Icon(
          icon,
          color: isIncome ? AppColors.secondary : AppColors.warning,
        ),
      ),
      title: Text(cat.name, overflow: TextOverflow.ellipsis),
      trailing: cat.isCustom
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                  onPressed: () => _editCategory(cat),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  onPressed: () => _deleteCategory(cat),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildCategorySection(
    String title,
    List<Category> categories,
    bool isIncome,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => _addCategory(isIncome),
              icon: const Icon(Icons.add),
              label: const Text('Add Custom'),
            ),
          ],
        ),
        CustomCard(
          child: Column(
            children: categories
                .map((c) => _buildCategoryTile(c, isIncome))
                .toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Categories')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.user == null) {
              return const Center(
                child: Text('Please sign in to manage categories'),
              );
            }

            return StreamBuilder<List<Category>>(
              stream: _firestore.userCategoriesStream(auth.user!.uid),
              builder: (context, snapshot) {
                final remote = snapshot.data ?? [];

                // Merge defaults + remote custom categories
                final incomeMap = {for (var c in _defaultIncome) c.name: c};
                final expenseMap = {for (var c in _defaultExpense) c.name: c};

                for (var c in remote) {
                  if (c.type == TransactionType.income) {
                    if (c.isCustom) incomeMap[c.id] = c;
                  } else {
                    if (c.isCustom) expenseMap[c.id] = c;
                  }
                }

                final incomeList = incomeMap.values.toList();
                final expenseList = expenseMap.values.toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategorySection(
                      'Income Categories',
                      incomeList,
                      true,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildCategorySection(
                      'Expense Categories',
                      expenseList,
                      false,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
