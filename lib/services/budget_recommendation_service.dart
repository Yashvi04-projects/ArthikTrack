// In budget_recommendation_service.dart

import 'dart:convert';
import '../models/budget_recommendation.dart'; // Make sure you have this model

class BudgetRecommendationService {

  // New method to parse Gemini's JSON response
  static Map<String, BudgetRecommendation> parseFromAIResponse(List<dynamic> recommendationsData) {
    Map<String, BudgetRecommendation> recommendations = {};

    for (var item in recommendationsData) {
      try {
        final recommendation = BudgetRecommendation(
          category: item['category'],
          riskLevel: item['riskLevel'],
          averageSpending: (item['averageSpending'] as num).toDouble(),
          recommendedAmount: (item['recommendedAmount'] as num).toDouble(),
          tip: item['tip'],
        );
        recommendations[recommendation.category] = recommendation;
      } catch (e) {
        print('Error parsing recommendation item: $item. Error: $e');
        // Skip malformed items
      }
    }
    return recommendations;
  }

  // Your existing fallback method
  static Map<String, BudgetRecommendation> generateRecommendations(List entries, double monthlyIncome) {
    // Your original local logic here...
    print("Fallback to local recommendation logic.");
    // This is just a placeholder for your actual implementation
    return {
      "Food": BudgetRecommendation(
        category: "Food",
        averageSpending: 2000,
        recommendedAmount: 1800,
        riskLevel: "Medium",
        tip: "This is a fallback tip for food."
      )
    };
  }
}

