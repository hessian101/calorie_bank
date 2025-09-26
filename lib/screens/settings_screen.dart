import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calorie_provider.dart';
import '../models/user_profile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
  }

  void _loadUserProfile() {
    final provider = context.read<CalorieProvider>();
    final profile = provider.userProfile;
    if (profile != null) {
      _weightController.text = profile.weight.toString();
      _heightController.text = profile.height.toString();
      _ageController.text = profile.age.toString();
      _goalController.text = profile.dailyGoal.toString();
    } else {
      // Default values
      _weightController.text = '65';
      _heightController.text = '170';
      _ageController.text = '25';
      _goalController.text = '300';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _UserInfoSection(
            weightController: _weightController,
            heightController: _heightController,
            ageController: _ageController,
          ),
          const SizedBox(height: 24),
          _GoalSection(goalController: _goalController),
          const SizedBox(height: 24),
          _DataSection(onClearData: _loadUserProfile),
          const SizedBox(height: 24),
          const _AppInfoSection(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _goalController.dispose();
    super.dispose();
  }
}

class _UserInfoSection extends StatelessWidget {
  final TextEditingController weightController;
  final TextEditingController heightController;
  final TextEditingController ageController;

  const _UserInfoSection({
    required this.weightController,
    required this.heightController,
    required this.ageController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ユーザー情報', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _InputField(
              label: '体重',
              controller: weightController,
              suffix: 'kg',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _InputField(
              label: '身長',
              controller: heightController,
              suffix: 'cm',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _InputField(
              label: '年齢',
              controller: ageController,
              suffix: '歳',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final profile = UserProfile(
                      weight: double.tryParse(weightController.text) ?? 65.0,
                      height: double.tryParse(heightController.text) ?? 170.0,
                      age: int.tryParse(ageController.text) ?? 25,
                      dailyGoal: 300, // Default daily goal
                    );

                    await context.read<CalorieProvider>().saveUserProfile(
                      profile,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ユーザー情報を保存しました')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('保存に失敗しました: $e')));
                    }
                  }
                },
                child: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalSection extends StatelessWidget {
  final TextEditingController goalController;

  const _GoalSection({required this.goalController});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('目標設定', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _InputField(
              label: '1日の目標消費カロリー',
              controller: goalController,
              suffix: 'kcal',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final currentProfile = context
                        .read<CalorieProvider>()
                        .userProfile;
                    final updatedProfile = UserProfile(
                      weight: currentProfile?.weight ?? 65.0,
                      height: currentProfile?.height ?? 170.0,
                      age: currentProfile?.age ?? 25,
                      dailyGoal: int.tryParse(goalController.text) ?? 300,
                    );

                    await context.read<CalorieProvider>().saveUserProfile(
                      updatedProfile,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('目標を保存しました')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('保存に失敗しました: $e')));
                    }
                  }
                },
                child: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataSection extends StatelessWidget {
  final VoidCallback onClearData;
  const _DataSection({required this.onClearData});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('データ管理', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('データをバックアップ'),
              subtitle: const Text('データをエクスポートします'),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('バックアップ機能は開発中です')));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('データを復元'),
              subtitle: const Text('バックアップからデータを復元します'),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('復元機能は開発中です')));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('全データを削除', style: TextStyle(color: Colors.red)),
              subtitle: const Text('この操作は取り消すことができません'),
              contentPadding: EdgeInsets.zero,
              onTap: () => _showResetDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('データリセット'),
        content: const Text('全てのデータが削除されます。\nこの操作は取り消すことができません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await context.read<CalorieProvider>().clearAllData();
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('全データを削除しました')));
                  // Reset form to default values
                  onClearData();
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
        ],
      ),
    );
  }
}

class _AppInfoSection extends StatelessWidget {
  const _AppInfoSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('アプリ情報', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('バージョン'),
              subtitle: const Text('1.0.0'),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('ヘルプ'),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('ヘルプ機能は開発中です')));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('プライバシーポリシー'),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('プライバシーポリシーは開発中です')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String suffix;
  final TextInputType keyboardType;

  const _InputField({
    required this.label,
    required this.controller,
    required this.suffix,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            suffixText: suffix,
            isDense: true,
          ),
        ),
      ],
    );
  }
}
