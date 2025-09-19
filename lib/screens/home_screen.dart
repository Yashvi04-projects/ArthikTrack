import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/entry.dart';
import 'expense_entry_screen.dart';
import 'ai_insights_screen.dart';
import 'category_management_screen.dart';
import 'account_management_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  final FirestoreService _firestoreService = FirestoreService();
  int _selectedIndex = 0; // For bottom navigation

  void _changeMonth(int offset) {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + offset, 1);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation for each tab
    switch (index) {
      case 0:
        // Records - stay on current screen (home with entries)
        break;
      case 1:
        // Analysis - navigate to analytics/insights
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AIInsightsScreen()));
        break;
      case 2:
        // Budget - navigate to budget screen (you can create a new screen)
        // Navigator.push(context, MaterialPageRoute(builder: (context) => const BudgetScreen()));
        break;
      case 3:
        // Account - navigate to account management
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountManagementScreen()));
        break;
      case 4:
        // Add Entry - navigate to add entry screen
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpenseEntryScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6E6377),
        elevation: 0,
        title: const Text(
          'MyMoney',
          style: TextStyle(
            color: Color(0xFFD5AC6F),
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFD5AC6F)),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CircleAvatar(
                backgroundColor: const Color(0xFFD5AC6F),
                radius: 18,
                child: Icon(Icons.person, color: Color(0xFF40304D), size: 22),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.psychology, color: Color(0xFFD5AC6F)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AIInsightsScreen()));
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFFF8F6F9),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF6E6377)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFD5AC6F),
                    child: Icon(Icons.person, size: 40, color: Color(0xFF40304D)),
                  ),
                  SizedBox(height: 12),
                  Text('ArthikTrack',
                      style: TextStyle(
                          color: Color(0xFFD5AC6F),
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  Text('Smart Expense Tracker',
                      style: TextStyle(color: Color(0xFFF8F6F9), fontSize: 14)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFF6E6377)),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.psychology, color: Color(0xFF6E6377)),
              title: const Text('AI Insights'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AIInsightsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.category, color: Color(0xFF6E6377)),
              title: const Text('Manage Categories'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryManagementScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet, color: Color(0xFF6E6377)),
              title: const Text('Manage Accounts'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountManagementScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.analytics, color: Color(0xFF6E6377)),
              title: const Text('Reports'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF6E6377)),
              title: const Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.help, color: Color(0xFF6E6377)),
              title: const Text('Help & Support'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Entry>>(
        stream: _firestoreService.getEntriesForMonth(selectedMonth),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD5AC6F)),
            );
          }

          final entries = snapshot.data ?? [];
          double totalExpense = 0;
          double totalIncome = 0;

          for (var entry in entries) {
            if (entry.type == 'expense') {
              totalExpense += entry.amount;
            } else if (entry.type == 'income') {
              totalIncome += entry.amount;
            }
          }

          double total = totalIncome - totalExpense;

          // Group entries by date
          Map<String, List<Entry>> grouped = {};
          for (var entry in entries) {
            String dateKey = DateFormat('yyyy-MM-dd').format(entry.date);
            grouped.putIfAbsent(dateKey, () => []).add(entry);
          }
          List<String> sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

          return Column(
            children: [
              // Month Navigation Header
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF6E6377),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_left, color: Color(0xFFD5AC6F), size: 28),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Text(
                      DateFormat('MMMM, yyyy').format(selectedMonth),
                      style: const TextStyle(
                          color: Color(0xFFF8F6F9),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_right, color: Color(0xFFD5AC6F), size: 28),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
              ),

              // Summary Cards
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _summaryTile('EXPENSE', '-₹${totalExpense.toStringAsFixed(2)}', const Color(0xFFD5AC6F), Icons.arrow_downward),
                    _summaryTile('INCOME', '₹${totalIncome.toStringAsFixed(2)}', const Color(0xFFC5B4A6), Icons.arrow_upward),
                    _summaryTile('TOTAL', '₹${total.toStringAsFixed(2)}', total >= 0 ? Colors.green : Colors.red, Icons.account_balance),
                  ],
                ),
              ),

              // AI Quick Insight Banner (if there are entries)
              if (entries.isNotEmpty) _buildQuickInsightBanner(totalExpense, totalIncome),

              // Entries List
              Expanded(
                child: entries.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: sortedDates.length,
                        itemBuilder: (context, idx) {
                          String date = sortedDates[idx];
                          List<Entry> dayEntries = grouped[date]!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today, color: Color(0xFF6E6377), size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      DateFormat('MMM dd, EEEE').format(DateTime.parse(date)),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF40304D),
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...dayEntries.map((entry) => _entryTile(entry)),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFFF8F6F9),
          selectedItemColor: const Color(0xFF6E6377),
          unselectedItemColor: Colors.grey[500],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              activeIcon: Icon(Icons.receipt_long, size: 28),
              label: 'Records',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics, size: 28),
              label: 'Analysis',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_outline),
              activeIcon: Icon(Icons.pie_chart, size: 28),
              label: 'Budget',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet, size: 28),
              label: 'Account',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle, size: 28),
              label: 'Add Entry',
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryTile(String label, String value, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuickInsightBanner(double totalExpense, double totalIncome) {
    String insight = "";
    Color bannerColor = const Color(0xFFD5AC6F);
    IconData iconData = Icons.trending_up;

    if (totalExpense > totalIncome) {
      insight = "⚠️ You're spending more than earning this month!";
      bannerColor = Colors.red[300]!;
      iconData = Icons.trending_down;
    } else if (totalIncome > totalExpense * 1.5) {
      insight = "🎉 Great! You're saving well this month!";
      bannerColor = Colors.green;
      iconData = Icons.savings;
    } else {
      insight = "💡 Check AI insights for budget tips!";
      bannerColor = const Color(0xFFD5AC6F);
      iconData = Icons.psychology;
    }

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bannerColor.withOpacity(0.9), bannerColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: bannerColor.withOpacity(0.18),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(iconData, color: const Color(0xFF40304D), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              insight,
              style: const TextStyle(
                color: Color(0xFF40304D),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AIInsightsScreen()));
            },
            child: const Text('View AI Tips', style: TextStyle(color: Color(0xFF40304D))),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No entries for this month',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your expenses and income',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ExpenseEntryScreen()),
              );
              if (result == true) setState(() {});
            },
            icon: const Icon(Icons.add),
            label: const Text('Add First Entry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD5AC6F),
              foregroundColor: const Color(0xFF40304D),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _entryTile(Entry entry) {
    return GestureDetector(
      onTap: () => _showEntryDetailModal(entry),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        color: const Color(0xFFF8F6F9),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Icon
              CircleAvatar(
                backgroundColor: _getCategoryColor(entry.category),
                radius: 26,
                child: Icon(
                  _getCategoryIcon(entry.category),
                  color: const Color(0xFF40304D),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              // Entry details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          entry.category,
                          style: const TextStyle(
                            color: Color(0xFF40304D),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC5B4A6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.account_balance_wallet, color: Color(0xFF6E6377), size: 13),
                              const SizedBox(width: 3),
                              Text(
                                entry.account,
                                style: const TextStyle(
                                  color: Color(0xFF6E6377),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (entry.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          entry.description,
                          style: const TextStyle(color: Color(0xFF6E6377), fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        DateFormat('hh:mm a').format(entry.date),
                        style: const TextStyle(color: Color(0xFF6E6377), fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    (entry.type == 'expense' ? '-' : '+') + '₹${entry.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: entry.type == 'expense' ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: entry.type == 'expense' ? Colors.red[50] : Colors.green[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      entry.type.toUpperCase(),
                      style: TextStyle(
                        color: entry.type == 'expense' ? Colors.red : Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange[200]!;
      case 'transportation':
        return Colors.blue[200]!;
      case 'health':
        return Colors.red[200]!;
      case 'entertainment':
        return Colors.purple[200]!;
      case 'shopping':
        return Colors.pink[200]!;
      case 'bills':
        return Colors.yellow[200]!;
      default:
        return const Color(0xFFC5B4A6);
    }
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

  void _showEntryDetailModal(Entry entry) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: _EntryDetailModal(
            entry: entry,
            onDelete: () async {
              await _firestoreService.deleteEntry(entry.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Entry deleted successfully')),
              );
            },
            onEdit: () async {
              Navigator.of(context).pop();
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ExpenseEntryScreen(
                    entryToEdit: entry,
                  ),
                ),
              );
              if (result == true) setState(() {});
            },
          ),
        );
      },
    );
  }
}

// Entry detail modal widget (unchanged)
class _EntryDetailModal extends StatelessWidget {
  final Entry entry;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _EntryDetailModal({
    required this.entry,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F6F9),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top bar with close, delete, edit
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF6E6377),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFFD5AC6F)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Color(0xFFD5AC6F)),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Entry'),
                            content: const Text('Are you sure you want to delete this entry?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  onDelete();
                                },
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFFD5AC6F)),
                      onPressed: onEdit,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: entry.type == 'expense' ? Colors.red[400] : Colors.green,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(0), bottom: Radius.circular(18)),
            ),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              children: [
                Text(
                  entry.type.toUpperCase(),
                  style: const TextStyle(color: Color(0xFFF8F6F9), fontWeight: FontWeight.bold, fontSize: 17),
                ),
                const SizedBox(height: 4),
                Text(
                  (entry.type == 'expense' ? '-' : '+') + '₹${entry.amount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Color(0xFFF8F6F9), fontWeight: FontWeight.bold, fontSize: 32),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy hh:mm a').format(entry.date),
                  style: const TextStyle(color: Color(0xFFF8F6F9), fontSize: 14),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Account', style: TextStyle(color: Color(0xFF40304D), fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFC5B4A6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_wallet, color: Color(0xFF6E6377), size: 18),
                          const SizedBox(width: 4),
                          Text(entry.account, style: const TextStyle(color: Color(0xFF6E6377))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Text('Category', style: TextStyle(color: Color(0xFF40304D), fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFC5B4A6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Row(
                        children: [
                          const Icon(Icons.category, color: Color(0xFF6E6377), size: 18),
                          const SizedBox(width: 4),
                          Text(entry.category, style: const TextStyle(color: Color(0xFF6E6377))),
                        ],
                      ),
                    ),
                  ],
                ),
                if (entry.description.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const Text('Notes', style: TextStyle(color: Color(0xFF40304D), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(entry.description, style: const TextStyle(color: Color(0xFF6E6377), fontSize: 15)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
