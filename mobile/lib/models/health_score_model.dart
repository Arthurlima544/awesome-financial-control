import 'package:equatable/equatable.dart';

class HealthScoreModel extends Equatable {
  final int score;
  final int savingsScore;
  final int limitsScore;
  final int goalsScore;
  final int varianceScore;
  final List<int> historicalScores;

  const HealthScoreModel({
    required this.score,
    required this.savingsScore,
    required this.limitsScore,
    required this.goalsScore,
    required this.varianceScore,
    required this.historicalScores,
  });

  factory HealthScoreModel.fromJson(Map<String, dynamic> json) {
    return HealthScoreModel(
      score: json['score'] as int,
      savingsScore: json['savingsScore'] as int,
      limitsScore: json['limitsScore'] as int,
      goalsScore: json['goalsScore'] as int,
      varianceScore: json['varianceScore'] as int,
      historicalScores: List<int>.from(json['historicalScores']),
    );
  }

  @override
  List<Object?> get props => [
    score,
    savingsScore,
    limitsScore,
    goalsScore,
    varianceScore,
    historicalScores,
  ];
}
