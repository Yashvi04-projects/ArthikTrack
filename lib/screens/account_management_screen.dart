import 'package:flutter/material.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  final List<String> accounts = ['Bus ticket', 'Card', 'Cash', 'Savings'];
  final TextEditingController _controller = TextEditingController();

  void _addAccount() {
    final acc = _controller.text.trim();
    if (acc.isNotEmpty && !accounts.contains(acc)) {
      setState(() {
        accounts.add(acc);
        _controller.clear();
      });
    }
  }

  void _deleteAccount(String acc) {
    setState(() {
      accounts.remove(acc);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6E6377),
        title: const Text('Manage Accounts', style: TextStyle(color: Color(0xFFD5AC6F))),
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
                      labelText: 'Add new account',
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
                  onPressed: _addAccount,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: accounts.length,
                itemBuilder: (context, idx) {
                  final acc = accounts[idx];
                  return Card(
                    color: const Color(0xFFC5B4A6),
                    child: ListTile(
                      title: Text(acc, style: const TextStyle(color: Color(0xFF40304D))),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFF6E6377)),
                        onPressed: () => _deleteAccount(acc),
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