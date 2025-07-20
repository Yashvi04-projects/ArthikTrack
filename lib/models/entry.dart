import 'package:cloud_firestore/cloud_firestore.dart';

class Entry {
  final String id;
  final double amount;
  final String type; // 'income' or 'expense'
  final String account;
  final String category;
  final String description;
  final DateTime date;

  Entry({
    required this.id,
    required this.amount,
    required this.type,
    required this.account,
    required this.category,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'type': type,
      'account': account,
      'category': category,
      'description': description,
      'date': Timestamp.fromDate(date),
    };
  }

  factory Entry.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Entry(
      id: doc.id,
      amount: (data['amount'] as num).toDouble(),
      type: data['type'],
      account: data['account'],
      category: data['category'],
      description: data['description'],
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}