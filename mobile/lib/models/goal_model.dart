class GoalModel {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final double progressPercentage;
  final DateTime deadline;
  final String? icon;
  final DateTime createdAt;

  GoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.progressPercentage,
    required this.deadline,
    this.icon,
    required this.createdAt,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'],
      name: json['name'],
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      deadline: DateTime.parse(json['deadline']),
      icon: json['icon'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  int get daysRemaining {
    final now = DateTime.now();
    if (deadline.isBefore(now)) return 0;
    return deadline.difference(now).inDays;
  }
}
