// in models/budget_recommendation.dart
class BudgetRecommendation {
  final String category;
  final double averageSpending;
  final double recommendedAmount;
  final String riskLevel;
  final String tip;

  BudgetRecommendation({
    required this.category,
    required this.averageSpending,
    required this.recommendedAmount,
    required this.riskLevel,
    required this.tip,
  });
}