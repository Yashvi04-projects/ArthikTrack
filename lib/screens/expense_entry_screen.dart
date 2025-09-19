import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/entry.dart';

class ExpenseEntryScreen extends StatefulWidget {
  final Entry? entryToEdit;
  const ExpenseEntryScreen({super.key, this.entryToEdit});

  @override
  State<ExpenseEntryScreen> createState() => _ExpenseEntryScreenState();
}

class _ExpenseEntryScreenState extends State<ExpenseEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  // Transaction type and categories
  String _transactionType = 'expense';
  String _selectedCategory = 'Food';
  String _selectedAccount = 'Cash';
  DateTime _selectedDate = DateTime.now();

  // Categories for different transaction types
  final List<String> _expenseCategories = [
    'Food', 'Transportation', 'Health', 'Entertainment', 
    'Shopping', 'Bills', 'Education', 'Home', 'Utilities'
  ];

  final List<String> _incomeCategories = [
    'Salary', 'Bonus', 'Investment', 'Business', 
    'Gift', 'Interest', 'Freelance', 'Other Income'
  ];

  final List<String> _accounts = ['Cash', 'Bank', 'Credit Card', 'Savings', 'Digital Wallet'];

  @override
  void initState() {
    super.initState();
    // Initialize with existing entry data if editing
    if (widget.entryToEdit != null) {
      final entry = widget.entryToEdit!;
      _amountController.text = entry.amount.toString();
      _descriptionController.text = entry.description;
      _transactionType = entry.type;
      _selectedCategory = entry.category;
      _selectedAccount = entry.account;
      _selectedDate = entry.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> currentCategories = _transactionType == 'income' 
        ? _incomeCategories 
        : _expenseCategories;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6E6377),
        elevation: 4,
        title: Text(
          widget.entryToEdit == null ? 'Add Entry' : 'Edit Entry',
          style: const TextStyle(
            color: Color(0xFFD5AC6F),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFD5AC6F)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Type Selection Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Transaction Type',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF40304D),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: _transactionType == 'expense' 
                                    ? const Color(0xFF6E6377).withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: RadioListTile<String>(
                                title: Row(
                                  children: [
                                    Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red[400],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Expense'),
                                  ],
                                ),
                                value: 'expense',
                                groupValue: _transactionType,
                                activeColor: const Color(0xFF6E6377),
                                onChanged: (value) {
                                  setState(() {
                                    _transactionType = value!;
                                    _selectedCategory = _expenseCategories[0];
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: _transactionType == 'income' 
                                    ? const Color(0xFF6E6377).withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: RadioListTile<String>(
                                title: Row(
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.green[400],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Income'),
                                  ],
                                ),
                                value: 'income',
                                groupValue: _transactionType,
                                activeColor: const Color(0xFF6E6377),
                                onChanged: (value) {
                                  setState(() {
                                    _transactionType = value!;
                                    _selectedCategory = _incomeCategories[0]; // Default to 'Salary'
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),

              // Amount Input Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      labelStyle: const TextStyle(color: Color(0xFF6E6377)),
                      hintText: 'Enter amount in ₹',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6E6377)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6E6377), width: 2),
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          '₹',
                          style: TextStyle(
                            color: _transactionType == 'income' ? Colors.green : Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      if (double.tryParse(value) == null || double.parse(value) <= 0) {
                        return 'Please enter valid amount';
                      }
                      return null;
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Category Selection Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: _transactionType == 'income' ? 'Income Source' : 'Expense Category',
                      labelStyle: const TextStyle(color: Color(0xFF6E6377)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6E6377)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6E6377), width: 2),
                      ),
                      prefixIcon: Icon(
                        _transactionType == 'income' ? Icons.trending_up : Icons.category, 
                        color: const Color(0xFF6E6377),
                      ),
                    ),
                    items: currentCategories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(
                          category,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Account Selection Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedAccount,
                    decoration: InputDecoration(
                      labelText: 'Account',
                      labelStyle: const TextStyle(color: Color(0xFF6E6377)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6E6377)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6E6377), width: 2),
                      ),
                      prefixIcon: const Icon(Icons.account_balance_wallet, color: Color(0xFF6E6377)),
                    ),
                    items: _accounts.map((account) {
                      return DropdownMenuItem(
                        value: account,
                        child: Text(
                          account,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAccount = value!;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Date Selection Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF6E6377)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Color(0xFF6E6377)),
                          const SizedBox(width: 12),
                          Text(
                            'Date: ${DateFormat('dd MMM yyyy').format(_selectedDate)}',
                            style: const TextStyle(fontSize: 16, color: Color(0xFF40304D)),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down, color: Color(0xFF6E6377)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Description Input Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      labelStyle: const TextStyle(color: Color(0xFF6E6377)),
                      hintText: _transactionType == 'income' 
                          ? 'e.g., Monthly salary, Bonus payment'
                          : 'e.g., Lunch, Grocery shopping',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6E6377)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6E6377), width: 2),
                      ),
                      prefixIcon: const Icon(Icons.notes, color: Color(0xFF6E6377)),
                    ),
                    maxLines: 3,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _transactionType == 'income' 
                          ? [Colors.green[400]!, Colors.green[600]!]
                          : [const Color(0xFF6E6377), const Color(0xFF5A5066)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (_transactionType == 'income' ? Colors.green : const Color(0xFF6E6377)).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _saveEntry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: Icon(
                      widget.entryToEdit == null ? Icons.add : Icons.save,
                      color: Colors.white,
                      size: 24,
                    ),
                    label: Text(
                      widget.entryToEdit == null 
                          ? (_transactionType == 'income' ? 'Add Income' : 'Add Expense')
                          : 'Update Entry',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6E6377),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF40304D),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      try {
        final entry = Entry(
          id: widget.entryToEdit?.id ?? '',
          amount: double.parse(_amountController.text),
          category: _selectedCategory,
          type: _transactionType, // 'income' for salary, 'expense' for expenses
          date: _selectedDate,
          description: _descriptionController.text.trim(),
          account: _selectedAccount,
        );

        if (widget.entryToEdit == null) {
          await _firestoreService.addEntry(entry);
        } else {
          await _firestoreService.updateEntry(entry);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  _transactionType == 'income' ? Icons.trending_up : Icons.trending_down,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.entryToEdit == null 
                      ? '${_transactionType == 'income' ? 'Income' : 'Expense'} added successfully!'
                      : 'Entry updated successfully!',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: _transactionType == 'income' ? Colors.green : const Color(0xFF6E6377),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Error: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
