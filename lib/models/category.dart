import 'transaction.dart';

/// Category model for income and expense categories
class Category {
  final String id;
  final String name;
  final TransactionType type;
  final String icon; // Icon code or name
  final bool isCustom; // true if created by user

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    this.isCustom = false,
  });

  /// Convert Category to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'icon': icon,
      'isCustom': isCustom,
    };
  }

  /// Construct Category from Firestore map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: (map['type'] ?? 'expense') == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      icon: map['icon'] ?? 'category',
      isCustom: map['isCustom'] == true,
    );
  }
}

/// Mock categories data
class MockCategories {
  static List<Category> getIncomeCategories() {
    return [
      Category(
        id: '1',
        name: 'Salary',
        type: TransactionType.income,
        icon: 'work',
      ),
      Category(
        id: '2',
        name: 'Freelance',
        type: TransactionType.income,
        icon: 'laptop',
      ),
      Category(
        id: '3',
        name: 'Investment',
        type: TransactionType.income,
        icon: 'trending_up',
      ),
      Category(
        id: '4',
        name: 'Business',
        type: TransactionType.income,
        icon: 'store',
      ),
      Category(
        id: '5',
        name: 'Other',
        type: TransactionType.income,
        icon: 'attach_money',
      ),
    ];
  }

  static List<Category> getExpenseCategories() {
    return [
      Category(
        id: '1',
        name: 'Food',
        type: TransactionType.expense,
        icon: 'restaurant',
      ),
      Category(
        id: '2',
        name: 'Transport',
        type: TransactionType.expense,
        icon: 'directions_car',
      ),
      Category(
        id: '3',
        name: 'Shopping',
        type: TransactionType.expense,
        icon: 'shopping_bag',
      ),
      Category(
        id: '4',
        name: 'Entertainment',
        type: TransactionType.expense,
        icon: 'movie',
      ),
      Category(
        id: '5',
        name: 'Bills',
        type: TransactionType.expense,
        icon: 'receipt',
      ),
      Category(
        id: '6',
        name: 'Rent',
        type: TransactionType.expense,
        icon: 'home',
      ),
      Category(
        id: '7',
        name: 'Healthcare',
        type: TransactionType.expense,
        icon: 'local_hospital',
      ),
      Category(
        id: '8',
        name: 'Education',
        type: TransactionType.expense,
        icon: 'school',
      ),
      Category(
        id: '9',
        name: 'Other',
        type: TransactionType.expense,
        icon: 'category',
      ),
    ];
  }

  static List<Category> getAllCategories() {
    return [...getIncomeCategories(), ...getExpenseCategories()];
  }
}
