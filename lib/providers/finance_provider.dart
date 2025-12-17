import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/firestore_service.dart';

/// FinanceProvider: single source of truth for transactions and balances
class FinanceProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  StreamSubscription<List<Transaction>>? _sub;
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  List<Transaction> get recentTransactions => _transactions.take(5).toList();

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (s, t) => s + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (s, t) => s + t.amount);

  double get balance => totalIncome - totalExpense;

  void setUser(String? userId) {
    // cancel previous subscription
    _sub?.cancel();
    _transactions = [];
    notifyListeners();

    if (userId == null) return;

    _sub = _firestoreService
        .getTransactions(userId)
        .listen(
          (txs) {
            // keep order as firestore provides (descending by date)
            _transactions = List.from(txs);
            notifyListeners();
          },
          onError: (e) {
            // swallow errors for now; consumer can show error states
            debugPrint('FinanceProvider stream error: $e');
          },
        );
  }

  Future<void> addTransaction(String userId, Transaction transaction) async {
    // optimistic insert at top
    _transactions = [transaction, ..._transactions];
    notifyListeners();

    try {
      await _firestoreService.addTransaction(userId, transaction);
      // actual firestore stream will update list; no further action
    } catch (e) {
      // rollback optimistic change on error
      _transactions = _transactions
          .where((t) => t.id != transaction.id)
          .toList();
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
