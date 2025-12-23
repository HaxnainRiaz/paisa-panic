import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/firestore_service.dart';

/// FinanceProvider: single source of truth for transactions and balances
class FinanceProvider with ChangeNotifier {
  final dynamic _firestoreService;

  FinanceProvider({dynamic firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  String _selectedCurrency = 'PKR';
  StreamSubscription<List<Transaction>>? _sub;
  List<Transaction> _transactions = [];

  String get selectedCurrency => _selectedCurrency;
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
    
    // Load user profile to get currency
    _firestoreService.getUserProfile(userId).then((user) {
      if (user != null) {
        _selectedCurrency = user.currency;
        notifyListeners();
      }
    });

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

  Future<void> updateTransaction(String userId, Transaction transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      notifyListeners();
    }

    try {
      await _firestoreService.updateTransaction(userId, transaction);
    } catch (e) {
      // Revert/Reload if needed, simplified here
      debugPrint('Error updating transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(String userId, String transactionId) async {
    _transactions.removeWhere((t) => t.id == transactionId);
    notifyListeners();

    try {
      await _firestoreService.deleteTransaction(userId, transactionId);
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      rethrow;
    }
  }

  Future<void> setCurrency(String userId, String currency) async {
    _selectedCurrency = currency;
    notifyListeners();
    try {
      await _firestoreService.updateUserProfile(userId, {'currency': currency});
    } catch (e) {
      debugPrint('Error updating currency: $e');
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
