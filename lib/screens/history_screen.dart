import 'package:calorie_bank_app/models/transaction.dart';
import 'package:calorie_bank_app/providers/calorie_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Remove static data - will use Provider

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Transaction> _getFilteredTransactions(
    List<Transaction> allTransactions,
    String filter,
  ) {
    if (filter == 'all') return allTransactions;
    final transactionType = filter == 'deposit'
        ? TransactionType.deposit
        : TransactionType.withdrawal;
    return allTransactions
        .where((transaction) => transaction.type == transactionType)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('履歴'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '全て'),
            Tab(text: '入金'),
            Tab(text: '引き落とし'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Consumer<CalorieProvider>(
            builder: (context, provider, child) {
              return _TransactionList(
                _getFilteredTransactions(provider.transactions, 'all'),
              );
            },
          ),
          Consumer<CalorieProvider>(
            builder: (context, provider, child) {
              return _TransactionList(
                _getFilteredTransactions(provider.transactions, 'deposit'),
              );
            },
          ),
          Consumer<CalorieProvider>(
            builder: (context, provider, child) {
              return _TransactionList(
                _getFilteredTransactions(provider.transactions, 'withdrawal'),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  final List<Transaction> transactions;

  const _TransactionList(this.transactions);

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(child: Text('履歴がありません'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _TransactionCard(transaction: transaction);
      },
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isDeposit = transaction.type == TransactionType.deposit;
    final color = isDeposit ? Colors.green : Colors.orange;
    final icon = isDeposit ? Icons.add_circle : Icons.remove_circle;
    final sign = isDeposit ? '+' : '-';
    final formatter = DateFormat('MM/dd HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.shade100,
          child: Icon(icon, color: color.shade700),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${formatter.format(transaction.timestamp)} • ${transaction.category}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: Text(
          '$sign${transaction.amount} kcal',
          style: TextStyle(
            color: color.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () => _showTransactionDetails(context, transaction),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, Transaction transaction) {
    final isDeposit = transaction.type == TransactionType.deposit;
    final formatter = DateFormat('yyyy/MM/dd HH:mm');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(transaction.description),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow('種類', isDeposit ? '入金' : '引き落とし'),
            _DetailRow('カロリー', '${transaction.amount} kcal'),
            _DetailRow('カテゴリ', transaction.category),
            _DetailRow('日時', formatter.format(transaction.timestamp)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditOptions(context, transaction);
            },
            child: const Text('編集'),
          ),
        ],
      ),
    );
  }

  void _showEditOptions(BuildContext context, Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('編集オプション'),
        content: const Text('この記録を編集または削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await context.read<CalorieProvider>().deleteTransaction(
                  transaction.id,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('削除しました')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('削除に失敗しました: $e')));
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('編集機能は開発中です')));
            },
            child: const Text('編集'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
