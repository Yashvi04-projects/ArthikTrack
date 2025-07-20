import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/entry.dart';
import 'expense_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedMonth = DateTime.now();
  final FirestoreService _firestoreService = FirestoreService();

  void _changeMonth(int offset) {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + offset, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6E6377),
        elevation: 0,
        title: const Text('MyMoney', style: TextStyle(color: Color(0xFFD5AC6F), fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFFD5AC6F)),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<List<Entry>>(
        stream: _firestoreService.getEntriesForMonth(selectedMonth),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = snapshot.data ?? [];
          double totalExpense = 0;
          double totalIncome = 0;
          for (var entry in entries) {
            if (entry.type == 'expense') {
              totalExpense += entry.amount;
            } else {
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
              Container(
                color: const Color(0xFF6E6377),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_left, color: Color(0xFFD5AC6F)),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Text(
                      DateFormat('MMMM, yyyy').format(selectedMonth),
                      style: const TextStyle(color: Color(0xFFFFFBFF), fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_right, color: Color(0xFFD5AC6F)),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
              ),
              Container(
                color: const Color(0xFF6E6377),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _summaryTile('EXPENSE', '-₹${totalExpense.toStringAsFixed(2)}', const Color(0xFFD5AC6F)),
                    _summaryTile('INCOME', '₹${totalIncome.toStringAsFixed(2)}', const Color(0xFFC5B4A6)),
                    _summaryTile('TOTAL', '₹${total.toStringAsFixed(2)}', const Color(0xFF40304D)),
                  ],
                ),
              ),
              Expanded(
                child: entries.isEmpty
                    ? const Center(child: Text('No entries for this month'))
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
                                child: Text(
                                  DateFormat('MMM dd, EEEE').format(DateTime.parse(date)),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF40304D)),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD5AC6F),
        child: const Icon(Icons.add, color: Color(0xFF40304D)),
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ExpenseEntryScreen()),
          );
          if (result == true) setState(() {});
        },
      ),
    );
  }

  Widget _summaryTile(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _entryTile(Entry entry) {
    return GestureDetector(
      onTap: () => _showEntryDetailModal(entry),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: const Color(0xFFFFFBFF),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Icon
              CircleAvatar(
                backgroundColor: const Color(0xFFC5B4A6),
                radius: 24,
                child: Icon(
                  Icons.category, // You can map category to icons if you want
                  color: const Color(0xFF6E6377),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
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
                        // Account icon and name
                        Row(
                          children: [
                            Icon(Icons.account_balance_wallet, color: Color(0xFF6E6377), size: 16),
                            const SizedBox(width: 2),
                            Text(
                              entry.account,
                              style: const TextStyle(
                                color: Color(0xFF6E6377),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (entry.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          entry.description,
                          style: const TextStyle(color: Color(0xFF6E6377), fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                      fontSize: 18,
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

// Entry detail modal widget
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
        color: const Color(0xFFFFFBFF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top bar with close, delete, edit
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF6E6377),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                      onPressed: onDelete,
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
            color: entry.type == 'expense' ? Colors.red[400] : Colors.green[400],
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Text(
                  entry.type.toUpperCase(),
                  style: const TextStyle(color: Color(0xFFFFFBFF), fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  (entry.type == 'expense' ? '-' : '+') + '₹${entry.amount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Color(0xFFFFFBFF), fontWeight: FontWeight.bold, fontSize: 28),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy hh:mm a').format(entry.date),
                  style: const TextStyle(color: Color(0xFFFFFBFF), fontSize: 13),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Account', style: TextStyle(color: Color(0xFF40304D), fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFC5B4A6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.account_balance_wallet, color: Color(0xFF6E6377), size: 18),
                          const SizedBox(width: 4),
                          Text(entry.account, style: const TextStyle(color: Color(0xFF6E6377))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Category', style: TextStyle(color: Color(0xFF40304D), fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFC5B4A6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.category, color: Color(0xFF6E6377), size: 18),
                          const SizedBox(width: 4),
                          Text(entry.category, style: const TextStyle(color: Color(0xFF6E6377))),
                        ],
                      ),
                    ),
                  ],
                ),
                if (entry.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
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