import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart' as app_models;
import '../models/category.dart';
import '../models/user.dart' as app_user;

/// Firestore service for user data operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Profile
  Future<app_user.User?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        return app_user.User(
          id: userId,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          currency: data['currency'] ?? 'USD',
          monthlyBudget: (data['budget']?['amount'] ?? 0).toDouble(),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  // Budget
  Future<Map<String, dynamic>?> getBudget(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data()?['budget'];
    } catch (e) {
      return null;
    }
  }

  Future<void> setBudget(String userId, {
    required double amount,
    required String period,
    Map<String, double>? categoryAllocations,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'budget': {
        'amount': amount,
        'period': period,
        'categoryAllocations': categoryAllocations ?? {},
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'hasBudget': true,
    });
  }

  // Transactions
  Stream<List<app_models.Transaction>> getTransactions(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return app_models.Transaction(
          id: doc.id,
          amount: (data['amount'] ?? 0).toDouble(),
          type: data['type'] == 'income' 
              ? app_models.TransactionType.income 
              : app_models.TransactionType.expense,
          category: data['category'] ?? '',
          date: (data['date'] as Timestamp).toDate(),
          note: data['note'],
          source: data['source'],
        );
      }).toList();
    });
  }

  Future<void> addTransaction(String userId, app_models.Transaction transaction) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .add({
      'amount': transaction.amount,
      'type': transaction.type == app_models.TransactionType.income ? 'income' : 'expense',
      'category': transaction.category,
      'date': Timestamp.fromDate(transaction.date),
      'note': transaction.note,
      'source': transaction.source,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTransaction(String userId, String transactionId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }

  // Categories
  Future<List<Category>> getUserCategories(String userId, app_models.TransactionType type) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .doc(type == app_models.TransactionType.income ? 'income' : 'expense')
          .get();
      
      if (doc.exists) {
        final data = doc.data()!;
        final categories = data['categories'] as List?;
        if (categories != null) {
          return categories.map((cat) => Category(
            id: cat['id'],
            name: cat['name'],
            type: type,
            icon: cat['icon'] ?? 'category',
          )).toList();
        }
      }
      
      // Return default categories if none exist
      return _getDefaultCategories(type);
    } catch (e) {
      return _getDefaultCategories(type);
    }
  }

  Future<void> saveUserCategories(String userId, app_models.TransactionType type, List<Category> categories) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc(type == app_models.TransactionType.income ? 'income' : 'expense')
        .set({
      'categories': categories.map((cat) => {
        'id': cat.id,
        'name': cat.name,
        'icon': cat.icon,
      }).toList(),
    });
  }

  List<Category> _getDefaultCategories(app_models.TransactionType type) {
    if (type == app_models.TransactionType.income) {
      return [
        Category(id: '1', name: 'Salary', type: type, icon: 'work'),
        Category(id: '2', name: 'Freelance', type: type, icon: 'laptop'),
        Category(id: '3', name: 'Investment', type: type, icon: 'trending_up'),
        Category(id: '4', name: 'Business', type: type, icon: 'store'),
        Category(id: '5', name: 'Other', type: type, icon: 'attach_money'),
      ];
    } else {
      return [
        Category(id: '1', name: 'Food', type: type, icon: 'restaurant'),
        Category(id: '2', name: 'Transport', type: type, icon: 'directions_car'),
        Category(id: '3', name: 'Shopping', type: type, icon: 'shopping_bag'),
        Category(id: '4', name: 'Entertainment', type: type, icon: 'movie'),
        Category(id: '5', name: 'Bills', type: type, icon: 'receipt'),
        Category(id: '6', name: 'Rent', type: type, icon: 'home'),
        Category(id: '7', name: 'Healthcare', type: type, icon: 'local_hospital'),
        Category(id: '8', name: 'Education', type: type, icon: 'school'),
        Category(id: '9', name: 'Other', type: type, icon: 'category'),
      ];
    }
  }
}

