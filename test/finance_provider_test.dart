import 'package:flutter_test/flutter_test.dart';
import 'package:paisa_panic/providers/finance_provider.dart';
import 'package:paisa_panic/models/transaction.dart' as app_models;

// Simple fake FirestoreService for tests
class _FakeFirestoreService {
  Stream<List<app_models.Transaction>> getTransactions(String userId) =>
      Stream<List<app_models.Transaction>>.empty();
  Future<void> addTransaction(String userId, app_models.Transaction tx) async =>
      Future.value();
}

void main() {
  test('FinanceProvider optimistic addTransaction inserts immediately', () async {
    final provider = FinanceProvider(
      firestoreService: _FakeFirestoreService() as dynamic,
    );

    final tx = app_models.Transaction(
      id: 'test-tx-1',
      amount: 100.0,
      type: app_models.TransactionType.income,
      category: 'Test',
      date: DateTime.now(),
    );

    // Start the addTransaction but don't wait yet to inspect optimistic insert
    final future = provider.addTransaction('fake-user', tx);

    // Immediately after calling, optimistic insert should have occurred
    expect(
      provider.transactions.any((t) => t.id == tx.id),
      isTrue,
      reason:
          'Transaction should be optimistically inserted before awaiting Firestore call',
    );

    // Await and ensure it completes (fake service completes immediately)
    await future;
  });
}
