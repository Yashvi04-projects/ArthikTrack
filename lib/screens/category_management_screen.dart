import 'package:flutter/material.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final List<String> categories = [
    'Baby', 'Beauty', 'Bills', 'Car', 'Clothing', 'Education', 'Electronics',
    'Entertainment', 'Food', 'Fund', 'Health', 'Home', 'Insurance', 'Shopping',
    'Social', 'Sport', 'Tax', 'Telephone', 'Transportation'
  ];
  final TextEditingController _controller = TextEditingController();

  void _addCategory() {
    final cat = _controller.text.trim();
    if (cat.isNotEmpty && !categories.contains(cat)) {
      setState(() {
        categories.add(cat);
        _controller.clear();
      });
    }
  }

  void _deleteCategory(String cat) {
    setState(() {
      categories.remove(cat);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6E6377),
        title: const Text('Manage Categories', style: TextStyle(color: Color(0xFFD5AC6F))),
        iconTheme: const IconThemeData(color: Color(0xFFD5AC6F)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Add new category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD5AC6F),
                    foregroundColor: const Color(0xFF40304D),
                  ),
                  onPressed: _addCategory,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, idx) {
                  final cat = categories[idx];
                  return Card(
                    color: const Color(0xFFC5B4A6),
                    child: ListTile(
                      title: Text(cat, style: const TextStyle(color: Color(0xFF40304D))),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFF6E6377)),
                        onPressed: () => _deleteCategory(cat),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 