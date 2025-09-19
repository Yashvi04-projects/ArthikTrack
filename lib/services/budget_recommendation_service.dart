import 'dart:math';
import '../models/entry.dart';

class BudgetRecommendationService {
  // Generate AI-based budget recommendations
  static Map<String, BudgetRecommendation> generateRecommendations(
    List<Entry> historicalEntries,
    double monthlyIncome,
  ) {
    Map<String, BudgetRecommendation> recommendations = {};
    
    // Group expenses by category
    Map<String, List<double>> categoryExpenses = {};
    
    for (var entry in historicalEntries) {
      if (entry.type == 'expense') {
        categoryExpenses.putIfAbsent(entry.category, () => []).add(entry.amount);
      }
    }
    
    // Generate recommendations for each category
    categoryExpenses.forEach((category, expenses) {
      double avgSpending = expenses.reduce((a, b) => a + b) / expenses.length;
      double maxSpending = expenses.reduce(max);
      double minSpending = expenses.reduce(min);
      
      // AI Logic: Recommend 15% less than average spending
      double recommendedBudget = avgSpending * 0.85;
      
      // Cap at 80% of monthly income for essential categories
      List<String> essentialCategories = ['Food', 'Transportation', 'Bills', 'Health'];
      if (essentialCategories.contains(category)) {
        recommendedBudget = min(recommendedBudget, monthlyIncome * 0.8);
      } else {
        recommendedBudget = min(recommendedBudget, monthlyIncome * 0.3);
      }
      
      String tip = _generateTip(category, avgSpending, recommendedBudget);
      
      recommendations[category] = BudgetRecommendation(
        category: category,
        recommendedAmount: recommendedBudget,
        averageSpending: avgSpending,
        tip: tip,
        riskLevel: _calculateRiskLevel(avgSpending, monthlyIncome),
      );
    });
    
    return recommendations;
  }
  
  static String _generateTip(String category, double avgSpending, double recommended) {
    double savings = avgSpending - recommended;
    
    switch (category.toLowerCase()) {
      case 'food':
        return 'Try cooking at home more often. You could save ₹${savings.toStringAsFixed(0)} per month!';
      case 'transportation':
        return 'Consider carpooling or public transport to save ₹${savings.toStringAsFixed(0)} monthly.';
      case 'entertainment':
        return 'Look for free activities and limit movie/dining out to save ₹${savings.toStringAsFixed(0)}.';
      case 'shopping':
        return 'Make a shopping list and avoid impulse buying. Potential savings: ₹${savings.toStringAsFixed(0)}.';
      default:
        return 'Reduce ${category.toLowerCase()} expenses by ₹${savings.toStringAsFixed(0)} to stay within budget.';
    }
  }
  
  static String _calculateRiskLevel(double spending, double income) {
    double ratio = spending / income;
    if (ratio > 0.5) return 'High';
    if (ratio > 0.3) return 'Medium';
    return 'Low';
  }
}

class BudgetRecommendation {
  final String category;
  final double recommendedAmount;
  final double averageSpending;
  final String tip;
  final String riskLevel;
  
  BudgetRecommendation({
    required this.category,
    required this.recommendedAmount,
    required this.averageSpending,
    required this.tip,
    required this.riskLevel,
  });
}
