import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:convert';
import '../services/budget_recommendation_service.dart';
import '../services/firestore_service.dart';
import '../models/entry.dart';
import '../models/budget_recommendation.dart';

class AIInsightsScreen extends StatefulWidget {
  const AIInsightsScreen({super.key});

  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, BudgetRecommendation> recommendations = {};
  bool isLoading = true;
  double monthlyIncome = 50000; // Default, can be updated by user
  List<Entry> allEntries = [];
  String? aiAnalysisSummary; // To store the overall summary from AI

  @override
  void initState() {
    super.initState();
    // Initialize Gemini with your API key
    // IMPORTANT: Replace with your actual key and use a secure way to store it
    Gemini.init(apiKey: 'AIzaSyASgr7WX3Op27EGLZFst0Fq5iANzAQPc8I');
    _generateRecommendations();
  }

  void _generateRecommendations() async {
    setState(() => isLoading = true);

    // Fetch historical data
    DateTime now = DateTime.now();
    List<Entry> historicalEntries = [];
    for (int i = 0; i < 3; i++) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      try {
        List<Entry> monthEntries =
            await _firestoreService.getEntriesForMonth(month).first;
        historicalEntries.addAll(monthEntries);
      } catch (e) {
        print('Error fetching entries for month $month: $e');
      }
    }

    setState(() {
      allEntries = historicalEntries;
    });

    if (historicalEntries.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    // Generate a prompt for the AI
    String prompt = _composePrompt(historicalEntries, monthlyIncome, 3);

    try {
      // Call Gemini API
      final response = await Gemini.instance.text(prompt);

      final String? output = response?.output;
      
      if (output != null) {

        final cleanedOutput = output.replaceAll(RegExp(r'``````'), '').trim();

        final aiResponse = json.decode(cleanedOutput);

        // Parse the detailed recommendations and the summary
        final parsedRecommendations = BudgetRecommendationService.parseFromAIResponse(aiResponse['recommendations']);
        
        setState(() {
          recommendations = parsedRecommendations;
          aiAnalysisSummary = aiResponse['summary']; // Store the AI summary
          isLoading = false;
        });

      } else {
        throw Exception('No response from Gemini');
      }
    } catch (e) {
      print('Error with Gemini API call: $e');
      // Fallback to local logic if AI fails
      setState(() {
        recommendations = BudgetRecommendationService.generateRecommendations(historicalEntries, monthlyIncome);
        aiAnalysisSummary = "Could not connect to AI. Showing basic analysis.";
        isLoading = false;
      });
    }
  }

  String _composePrompt(List<Entry> entries, double income, int monthCount) {
  Map<String, double> categoryTotalSpend = {};
  for (var entry in entries) {
    if (entry.type == 'expense') {
      categoryTotalSpend[entry.category] =
          (categoryTotalSpend[entry.category] ?? 0) + entry.amount;
    }
  }

  Map<String, double> categoryAverageSpend = categoryTotalSpend.map(
    (key, value) => MapEntry(key, value / monthCount),
  );

  String spendingData = categoryAverageSpend.entries
      .map((e) => '"${e.key}": ${e.value.toStringAsFixed(2)}')
      .join(',\n');

  // --- MODIFIED PROMPT ---
  return '''
  You are an API that returns JSON. Do not under any circumstances write any text outside of the JSON object.

  Your entire response must be a single, valid, stringified JSON object.
  Do not include any conversational text, explanations, or markdown formatting like ```json or ```
  Your response should begin with `{` and end with `}`.

  Analyze the following financial data for a user in India.
  - User's monthly income: ₹${income.toStringAsFixed(2)}.
  - Average monthly spending over the last ${monthCount} month(s):
  {
    ${spendingData}
  }

  Generate a JSON response with two keys: "summary" and "recommendations".

  1.  "summary": A short, encouraging, and insightful overview (2-3 sentences) of the user's spending habits.
  2.  "recommendations": An array of JSON objects. Each object must contain:
      - "category" (string)
      - "riskLevel" (string: "High", "Medium", or "Low")
      - "averageSpending" (double)
      - "recommendedAmount" (double)
      - "tip" (string: a short, actionable tip)
  ''';
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
                  Text('AI is analyzing your spending...'),
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

  // --- All your other widgets like _buildIncomeSection, _buildOverallInsights, etc. remain the same ---
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
    if (recommendations.isEmpty && !isLoading) {
      return const SizedBox.shrink();
    }
    
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
            Text(
              aiAnalysisSummary ?? 'No summary available. Add more entries to get insights.',
              style: const TextStyle(color: Color(0xFF40304D), fontSize: 14),
            ),
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
                'No AI Insights Yet!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add more expense entries to get personalized AI budget recommendations.',
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
    Color riskColor = recommendation.riskLevel == 'High'
        ? Colors.red.shade700
        : recommendation.riskLevel == 'Medium'
            ? Colors.orange.shade700
            : Colors.green.shade700;

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
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
                      const Text('Current Avg / month', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
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
      case 'food': return Icons.fastfood;
      case 'transport': return Icons.directions_car;
      case 'health': return Icons.healing;
      case 'entertainment': return Icons.movie_creation;
      case 'shopping': return Icons.shopping_bag;
      case 'bills': return Icons.receipt_long;
      case 'education': return Icons.school;
      case 'home': return Icons.home;
      default: return Icons.category;
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
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
