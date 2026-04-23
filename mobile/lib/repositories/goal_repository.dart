import 'package:afc/models/goal_model.dart';
import 'package:afc/services/goal_service.dart';

class GoalRepository {
  GoalRepository({GoalService? service}) : _service = service ?? GoalService();

  final GoalService _service;

  Future<List<GoalModel>> getGoals() => _service.fetchGoals();

  Future<GoalModel> createGoal(Map<String, dynamic> data) =>
      _service.createGoal(data);

  Future<GoalModel> updateGoal(String id, Map<String, dynamic> data) =>
      _service.updateGoal(id, data);

  Future<void> deleteGoal(String id) => _service.deleteGoal(id);

  Future<GoalModel> addContribution(String id, double amount) =>
      _service.addContribution(id, amount);
}
