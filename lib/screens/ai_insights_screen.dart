import 'package:flutter/material.dart';
import '../services/budget_recommendation_service.dart';
import '../services/firestore_service.dart';
import '../models/entry.dart';

class AIInsightsScreen extends StatefulWidget {
  const AIInsightsScreen({super.key});

  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, BudgetRecommendation> recommendations = {};
  bool isLoading = true;
  double monthlyIncome = 50000; // Default, should be user input
  List<Entry> allEntries = [];

  @override
  void initState() {
    super.initState();
    _generateRecommendations();
  }

  void _generateRecommendations() async {
    setState(() => isLoading = true);
    
    // Get last 3 months data for better AI analysis
    DateTime now = DateTime.now();
    List<Entry> historicalEntries = [];
    
    // Get data from last 3 months
    for (int i = 0; i < 3; i++) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      try {
        List<Entry> monthEntries = await _firestoreService.getEntriesForMonth(month).first;
        historicalEntries.addAll(monthEntries);
      } catch (e) {
        print('Error fetching entries for month $month: $e');
      }
    }
    
    setState(() {
      allEntries = historicalEntries;
      if (historicalEntries.isNotEmpty) {
        recommendations = BudgetRecommendationService.generateRecommendations(
          historicalEntries, 
          monthlyIncome
        );
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6E6377),
        title: const Text('AI Budget Insights', style: TextStyle(color: Color(0xFFD5AC6F))),
        iconTheme: const IconThemeData(color: Color(0xFFD5AC6F)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFD5AC6F)),
            onPressed: _generateRecommendations,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFD5AC6F)),
                  SizedBox(height: 16),
                  Text('AI is analyzing your spending patterns...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIncomeSection(),
                  const SizedBox(height: 20),
                  _buildOverallInsights(),
                  const SizedBox(height: 20),
                  _buildRecommendationsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildIncomeSection() {
    return Card(
      color: const Color(0xFFC5B4A6),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Color(0xFF40304D)),
                SizedBox(width: 8),
                Text('Monthly Income', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF40304D))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text('₹${monthlyIncome.toStringAsFixed(0)}', 
                    style: const TextStyle(fontSize: 28, color: Color(0xFF40304D), fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: _updateIncome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD5AC6F),
                    foregroundColor: const Color(0xFF40304D),
                  ),
                  child: const Text('Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallInsights() {
    int totalRecommendations = recommendations.length;
    int highRiskCategories = recommendations.values
        .where((r) => r.riskLevel == 'High').length;
    
    double totalExpenses = allEntries
        .where((e) => e.type == 'expense')
        .fold(0.0, (sum, e) => sum + e.amount);
    
    double savingsRate = ((monthlyIncome - (totalExpenses / 3)) / monthlyIncome * 100);
    
    return Card(
      color: const Color(0xFFD5AC6F),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.psychology, color: Color(0xFF40304D)),
                SizedBox(width: 8),
                Text('AI Analysis Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF40304D))),
              ],
            ),
            const SizedBox(height: 12),
            if (totalRecommendations > 0) ...[
              Text('📊 $totalRecommendations categories analyzed', style: const TextStyle(color: Color(0xFF40304D))),
              Text('⚠️ $highRiskCategories high-risk categories', style: const TextStyle(color: Color(0xFF40304D))),
              Text('💰 ${savingsRate.toStringAsFixed(1)}% savings rate', style: const TextStyle(color: Color(0xFF40304D))),
              const SizedBox(height: 8),
              Text(
                savingsRate > 20 ? '🎉 Excellent savings rate!' : 
                savingsRate > 10 ? '👍 Good savings rate' : 
                '⚠️ Try to save more!',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF40304D))
              ),
            ] else ...[
              const Text('📝 Add more expense entries to get AI insights', style: TextStyle(color: Color(0xFF40304D))),
              const Text('💡 Start tracking for at least a week for better recommendations', style: TextStyle(color: Color(0xFF40304D))),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsList() {
    if (recommendations.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(Icons.insights, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'No AI insights yet!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add more expense entries across different categories to get personalized AI budget recommendations.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.lightbulb, color: Color(0xFFD5AC6F)),
            SizedBox(width: 8),
            Text('AI Recommendations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        ...recommendations.values.map((recommendation) => _buildRecommendationCard(recommendation)),
      ],
    );
  }

  Widget _buildRecommendationCard(BudgetRecommendation recommendation) {
    Color riskColor = recommendation.riskLevel == 'High' ? Colors.red :
                     recommendation.riskLevel == 'Medium' ? Colors.orange : Colors.green;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getCategoryIcon(recommendation.category), color: const Color(0xFF6E6377)),
                const SizedBox(width: 8),
                Text(recommendation.category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: riskColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    recommendation.riskLevel, 
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Current Avg', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('₹${recommendation.averageSpending.toStringAsFixed(0)}', 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('AI Recommends', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('₹${recommendation.recommendedAmount.toStringAsFixed(0)}', 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(recommendation.tip, style: const TextStyle(fontSize: 13))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transportation':
        return Icons.directions_car;
      case 'health':
        return Icons.medical_services;
      case 'entertainment':
        return Icons.movie;
      case 'shopping':
        return Icons.shopping_bag;
      case 'bills':
        return Icons.receipt;
      case 'education':
        return Icons.school;
      case 'home':
        return Icons.home;
      default:
        return Icons.category;
    }
  }

  void _updateIncome() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController(text: monthlyIncome.toString());
        return AlertDialog(
          title: const Text('Update Monthly Income'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Monthly Income (₹)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cancel')
            ),
            TextButton(
              onPressed: () {
                double? newIncome = double.tryParse(controller.text);
                if (newIncome != null && newIncome > 0) {
                  setState(() {
                    monthlyIncome = newIncome;
                  });
                  Navigator.pop(context);
                  _generateRecommendations();
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
