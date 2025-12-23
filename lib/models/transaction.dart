/// Transaction model representing income or expense
class Transaction {
  final String id;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String currency;
  final String? note;
  final String? source; // For income transactions

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.currency = 'PKR',
    this.note,
    this.source,
  });
}

enum TransactionType {
  income,
  expense,
}

/// Mock data generator for transactions
class MockTransactions {
  static List<Transaction> getTransactions() {
    final now = DateTime.now();
    return [
      Transaction(
        id: '1',
        amount: 5000.0,
        type: TransactionType.income,
        category: 'Salary',
        date: DateTime(now.year, now.month, 1),
        source: 'Company Inc.',
      ),
      Transaction(
        id: '2',
        amount: 150.0,
        type: TransactionType.expense,
        category: 'Food',
        date: DateTime(now.year, now.month, 5),
        note: 'Groceries',
      ),
      Transaction(
        id: '3',
        amount: 800.0,
        type: TransactionType.expense,
        category: 'Rent',
        date: DateTime(now.year, now.month, 1),
        note: 'Monthly rent',
      ),
      Transaction(
        id: '4',
        amount: 50.0,
        type: TransactionType.expense,
        category: 'Transport',
        date: DateTime(now.year, now.month, 10),
        note: 'Uber ride',
      ),
      Transaction(
        id: '5',
        amount: 200.0,
        type: TransactionType.income,
        category: 'Freelance',
        date: DateTime(now.year, now.month, 15),
        source: 'Client A',
      ),
      Transaction(
        id: '6',
        amount: 120.0,
        type: TransactionType.expense,
        category: 'Entertainment',
        date: DateTime(now.year, now.month, 18),
        note: 'Movie tickets',
      ),
      Transaction(
        id: '7',
        amount: 300.0,
        type: TransactionType.expense,
        category: 'Shopping',
        date: DateTime(now.year, now.month, 20),
        note: 'Clothing',
      ),
      Transaction(
        id: '8',
        amount: 100.0,
        type: TransactionType.income,
        category: 'Other',
        date: DateTime(now.year, now.month, 22),
        source: 'Gift',
      ),
    ];
  }
}

