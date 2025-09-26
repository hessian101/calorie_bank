import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';

class CalorieProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<Transaction> _transactions = [];
  int _balance = 0;
  Map<String, int> _todayActivity = {'deposits': 0, 'withdrawals': 0};
  UserProfile? _userProfile;
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  int get balance => _balance;
  Map<String, int> get todayActivity => _todayActivity;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadAllData();
    } catch (e) {
      debugPrint('Error initializing CalorieProvider: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadTransactions(),
      _loadBalance(),
      _loadTodayActivity(),
      _loadUserProfile(),
    ]);
  }

  Future<void> _loadTransactions() async {
    final transactions = await _databaseService.getAllTransactions();
    _transactions = List<Transaction>.from(transactions);
  }

  Future<void> _loadBalance() async {
    _balance = await _databaseService.getTotalBalance();
  }

  Future<void> _loadTodayActivity() async {
    _todayActivity = await _databaseService.getTodayActivity();
  }

  Future<void> _loadUserProfile() async {
    _userProfile = await _databaseService.getUserProfile();
  }

  Future<void> addTransaction({
    required TransactionType type,
    required int amount,
    required String description,
    required String category,
  }) async {
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      amount: amount,
      description: description,
      category: category,
      timestamp: DateTime.now(),
    );

    try {
      await _databaseService.insertTransaction(transaction);
      
      _transactions.insert(0, transaction);
      
      if (type == TransactionType.deposit) {
        _balance += amount;
        _todayActivity['deposits'] = _todayActivity['deposits']! + amount;
      } else {
        _balance -= amount;
        _todayActivity['withdrawals'] = _todayActivity['withdrawals']! + amount;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _databaseService.updateTransaction(transaction);
      
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        await _loadBalance();
        await _loadTodayActivity();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _databaseService.deleteTransaction(id);
      
      _transactions.removeWhere((t) => t.id == id);
      await _loadBalance();
      await _loadTodayActivity();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      rethrow;
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _databaseService.saveUserProfile(profile);
      _userProfile = profile;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      rethrow;
    }
  }

  List<Transaction> getTransactionsByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) {
      return t.timestamp.isAfter(start) && t.timestamp.isBefore(end);
    }).toList();
  }

  Map<String, int> getWeeklyStats() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartMidnight = DateTime(weekStart.year, weekStart.month, weekStart.day);
    
    final weekTransactions = getTransactionsByDateRange(
      weekStartMidnight,
      weekStartMidnight.add(const Duration(days: 7)),
    );

    int deposits = 0;
    int withdrawals = 0;

    for (final transaction in weekTransactions) {
      if (transaction.type == TransactionType.deposit) {
        deposits += transaction.amount;
      } else {
        withdrawals += transaction.amount;
      }
    }

    return {'deposits': deposits, 'withdrawals': withdrawals};
  }

  bool canWithdraw(int amount) {
    return _balance >= amount;
  }

  Future<void> clearAllData() async {
    try {
      await _databaseService.clearAllData();
      _transactions.clear();
      _balance = 0;
      _todayActivity = {'deposits': 0, 'withdrawals': 0};
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing data: $e');
      rethrow;
    }
  }

  Future<void> refreshData() async {
    await _loadAllData();
    notifyListeners();
  }
}