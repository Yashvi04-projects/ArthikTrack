import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';
import '../services/firestore_service.dart';

class ExpenseEntryScreen extends StatefulWidget {
  final Entry? entryToEdit;
  const ExpenseEntryScreen({super.key, this.entryToEdit});

  @override
  State<ExpenseEntryScreen> createState() => _ExpenseEntryScreenState();
}

class _ExpenseEntryScreenState extends State<ExpenseEntryScreen> {
  String type = 'expense';
  String selectedAccount = 'Cash';
  String selectedCategory = 'Food';
  String description = '';
  String amountStr = '';
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  final _firestoreService = FirestoreService();
  final _descController = TextEditingController();

  final List<String> accounts = ['Bus ticket', 'Card', 'Cash', 'Savings'];
  final List<String> categories = [
    'Baby', 'Beauty', 'Bills', 'Car', 'Clothing', 'Education', 'Electronics',
    'Entertainment', 'Food', 'Fund', 'Health', 'Home', 'Insurance', 'Shopping',
    'Social', 'Sport', 'Tax', 'Telephone', 'Transportation'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.entryToEdit != null) {
      final entry = widget.entryToEdit!;
      type = entry.type;
      selectedAccount = entry.account;
      selectedCategory = entry.category;
      description = entry.description;
      amountStr = entry.amount.toStringAsFixed(2);
      selectedDate = entry.date;
      selectedTime = TimeOfDay(hour: entry.date.hour, minute: entry.date.minute);
      _descController.text = entry.description;
    }
  }

  void _onKeyTap(String value) {
    setState(() {
      if (value == 'C') {
        amountStr = '';
      } else if (value == '<') {
        if (amountStr.isNotEmpty) amountStr = amountStr.substring(0, amountStr.length - 1);
      } else {
        amountStr += value;
      }
    });
  }

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  void _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (time != null) setState(() => selectedTime = time);
  }

  void _saveEntry() async {
    print('Saving entry...');
    if (amountStr.isEmpty) return;
    final amount = double.tryParse(amountStr) ?? 0;
    final entryDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    if (widget.entryToEdit != null) {
      // Update existing entry
      final updatedEntry = Entry(
        id: widget.entryToEdit!.id,
        amount: amount,
        type: type,
        account: selectedAccount,
        category: selectedCategory,
        description: description,
        date: entryDate,
      );
      await _firestoreService.updateEntry(updatedEntry);
    } else {
      // Add new entry
      final entry = Entry(
        id: '',
        amount: amount,
        type: type,
        account: selectedAccount,
        category: selectedCategory,
        description: description,
        date: entryDate,
      );
      print('Adding entry to Firestore: ${entry.toMap()}');
      await _firestoreService.addEntry(entry);
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6E6377),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFFD5AC6F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveEntry,
            child: const Text('SAVE', style: TextStyle(color: Color(0xFFD5AC6F), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _typeChip('INCOME', 'income'),
                  const SizedBox(width: 8),
                  _typeChip('EXPENSE', 'expense'),
                  const SizedBox(width: 8),
                  _typeChip('TRANSFER', 'transfer'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _selectTile(
                      icon: Icons.account_balance_wallet,
                      label: selectedAccount,
                      onTap: () => _showAccountPicker(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _selectTile(
                      icon: Icons.category,
                      label: selectedCategory,
                      onTap: () => _showCategoryPicker(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Add notes',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => description = val,
              ),
              const SizedBox(height: 16),
              _calculatorPad(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFC5B4A6)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_today, color: Color(0xFF6E6377)),
                            const SizedBox(width: 8),
                            Text(DateFormat('MMM dd, yyyy').format(selectedDate), style: const TextStyle(color: Color(0xFF40304D))),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFC5B4A6)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.access_time, color: Color(0xFF6E6377)),
                            const SizedBox(width: 8),
                            Text(selectedTime.format(context), style: const TextStyle(color: Color(0xFF40304D))),
                          ],
                        ),
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

  Widget _typeChip(String label, String value) {
    final isSelected = type == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFFD5AC6F),
      backgroundColor: const Color(0xFFC5B4A6),
      labelStyle: TextStyle(color: isSelected ? Color(0xFF40304D) : Color(0xFF6E6377)),
      onSelected: (_) => setState(() => type = value),
    );
  }

  Widget _selectTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFFC5B4A6)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF6E6377)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Color(0xFF40304D))),
          ],
        ),
      ),
    );
  }

  void _showAccountPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        children: [
          ...accounts.map((acc) => ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: Text(acc),
                onTap: () {
                  setState(() => selectedAccount = acc);
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        children: [
          ...categories.map((cat) => InkWell(
                onTap: () {
                  setState(() => selectedCategory = cat);
                  Navigator.pop(context);
                },
                child: Card(
                  color: selectedCategory == cat ? Color(0xFFD5AC6F) : Color(0xFFC5B4A6),
                  child: Center(child: Text(cat, style: const TextStyle(color: Color(0xFF40304D)))),
                ),
              )),
        ],
      ),
    );
  }

  Widget _calculatorPad() {
    final keys = [
      ['7', '8', '9'],
      ['4', '5', '6'],
      ['1', '2', '3'],
      ['0', '.', '<'],
      ['C'],
    ];
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFC5B4A6)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  amountStr.isEmpty ? '0' : amountStr,
                  style: const TextStyle(fontSize: 32, color: Color(0xFF40304D)),
                ),
              ),
              const SizedBox(height: 8),
              ...keys.map((row) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: row.map((key) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD5AC6F),
                            foregroundColor: const Color(0xFF40304D),
                            minimumSize: const Size(60, 48),
                          ),
                          onPressed: () => _onKeyTap(key),
                          child: Text(key, style: const TextStyle(fontSize: 20)),
                        ),
                      );
                    }).toList(),
                  )),
            ],
          ),
        ),
      ],
    );
  }
} 