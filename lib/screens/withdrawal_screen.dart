import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calorie_provider.dart';
import '../models/transaction.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _calorieController = TextEditingController();

  final List<Map<String, dynamic>> _presetFoods = [
    {'name': 'チョコレート', 'calories': 280},
    {'name': 'ポテトチップス', 'calories': 336},
    {'name': 'アイスクリーム', 'calories': 180},
    {'name': 'クッキー', 'calories': 50},
    {'name': 'ケーキ', 'calories': 350},
    {'name': 'ドーナツ', 'calories': 250},
  ];

  // Remove static balance - will use Provider

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('カロリー引き落とし'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Consumer<CalorieProvider>(
              builder: (context, provider, child) {
                return Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '現在の残高',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${provider.balance} kcal',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '食べ物名',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _foodController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '食べ物の名前を入力してください',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'カロリー',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _calorieController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'カロリーを入力してください',
                        suffixText: 'kcal',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'よく食べるもの',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presetFoods.map((food) {
                        return FilterChip(
                          label: Text('${food['name']} (${food['calories']}kcal)'),
                          onSelected: (selected) {
                            if (selected) {
                              _foodController.text = food['name'];
                              _calorieController.text = food['calories'].toString();
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _canWithdraw() ? _withdraw : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('引き落とす'),
            ),
          ],
        ),
      ),
    );
  }

  bool _canWithdraw() {
    final calories = int.tryParse(_calorieController.text) ?? 0;
    return _foodController.text.isNotEmpty && calories > 0;
  }

  void _withdraw() async {
    final calories = int.tryParse(_calorieController.text) ?? 0;
    final provider = context.read<CalorieProvider>();
    
    if (!provider.canWithdraw(calories)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('残高不足'),
          content: const Text('カロリー残高が不足しています。\n運動をしてカロリーを貯めてから再度お試しください。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      try {
        await provider.addTransaction(
          type: TransactionType.withdrawal,
          amount: calories,
          description: _foodController.text,
          category: '食べ物',
        );

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('引き落とし完了'),
              content: Text('${_foodController.text} ($calories kcal) を引き落としました！'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _foodController.clear();
                      _calorieController.clear();
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('エラーが発生しました: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _foodController.dispose();
    _calorieController.dispose();
    super.dispose();
  }
}