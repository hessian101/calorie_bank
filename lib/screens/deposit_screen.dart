import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calorie_provider.dart';
import '../models/transaction.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  String? _selectedExercise;
  final TextEditingController _durationController = TextEditingController();
  int _calculatedCalories = 0;

  final Map<String, int> _exerciseCaloriesPerMinute = {
    'ウォーキング': 3,
    'ランニング': 8,
    '水泳': 6,
    '筋トレ': 5,
    'サイクリング': 7,
    'ヨガ': 2,
  };

  void _calculateCalories() {
    if (_selectedExercise != null && _durationController.text.isNotEmpty) {
      final duration = int.tryParse(_durationController.text) ?? 0;
      final caloriesPerMinute = _exerciseCaloriesPerMinute[_selectedExercise!] ?? 0;
      setState(() {
        _calculatedCalories = duration * caloriesPerMinute;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('カロリー入金'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '運動の種類',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedExercise,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '運動を選択してください',
                      ),
                      items: _exerciseCaloriesPerMinute.keys.map((exercise) {
                        return DropdownMenuItem(
                          value: exercise,
                          child: Text(exercise),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedExercise = value;
                          _calculateCalories();
                        });
                      },
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
                      '運動時間（分）',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '時間を入力してください',
                        suffixText: '分',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _calculateCalories(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      '消費カロリー',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_calculatedCalories',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'kcal',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _calculatedCalories > 0 ? _deposit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('入金する'),
            ),
          ],
        ),
      ),
    );
  }

  void _deposit() async {
    if (_selectedExercise == null || _calculatedCalories <= 0) return;

    try {
      await context.read<CalorieProvider>().addTransaction(
        type: TransactionType.deposit,
        amount: _calculatedCalories,
        description: _selectedExercise!,
        category: '運動',
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('入金完了'),
            content: Text('$_calculatedCalories kcal を入金しました！'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedExercise = null;
                    _durationController.clear();
                    _calculatedCalories = 0;
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

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }
}