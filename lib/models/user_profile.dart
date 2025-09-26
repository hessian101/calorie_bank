class UserProfile {
  final double weight;
  final double height;
  final int age;
  final int dailyGoal;

  UserProfile({
    required this.weight,
    required this.height,
    required this.age,
    required this.dailyGoal,
  });

  Map<String, dynamic> toMap() {
    return {
      'weight': weight,
      'height': height,
      'age': age,
      'daily_goal': dailyGoal,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      weight: map['weight']?.toDouble() ?? 0.0,
      height: map['height']?.toDouble() ?? 0.0,
      age: map['age'] ?? 0,
      dailyGoal: map['daily_goal'] ?? 0,
    );
  }

  UserProfile copyWith({
    double? weight,
    double? height,
    int? age,
    int? dailyGoal,
  }) {
    return UserProfile(
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }

  double get bmi => weight / ((height / 100) * (height / 100));

  double calculateBMR() {
    return 10 * weight + 6.25 * height - 5 * age + 5;
  }
}