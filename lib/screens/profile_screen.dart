// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6E6377),
        title: const Text('Profile', style: TextStyle(color: Color(0xFFD5AC6F))),
        iconTheme: const IconThemeData(color: Color(0xFFD5AC6F)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Profile Picture
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFFC5B4A6),
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: const Color(0xFF6E6377),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD5AC6F),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFF40304D),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            // Profile Information
            _buildInfoCard('Name', 'John Doe'),
            const SizedBox(height: 12),
            _buildInfoCard('Email', 'john@example.com'),
            const SizedBox(height: 12),
            _buildInfoCard('Phone', '+91 98765 43210'),
            const SizedBox(height: 12),
            _buildInfoCard('Total Expenses', '₹25,000.00'),
            const SizedBox(height: 12),
            _buildInfoCard('Total Income', '₹2,500,000.00'),
            const SizedBox(height: 30),
            
            // Action Buttons
            _buildActionButton('Edit Profile', Icons.edit, () {}),
            const SizedBox(height: 12),
            _buildActionButton('Settings', Icons.settings, () {}),
            const SizedBox(height: 12),
            _buildActionButton('Export Data', Icons.download, () {}),
            const SizedBox(height: 20),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showLogoutDialog(context),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      color: const Color(0xFFC5B4A6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF40304D), fontSize: 16, fontWeight: FontWeight.w500)),
            Flexible(
              child: Text(value, style: const TextStyle(color: Color(0xFF6E6377), fontSize: 16), textAlign: TextAlign.end),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return Card(
      color: const Color(0xFFD5AC6F),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF40304D)),
        title: Text(label, style: const TextStyle(color: Color(0xFF40304D), fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF40304D), size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFBFF),
        title: const Text('Logout', style: TextStyle(color: Color(0xFF40304D))),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: Color(0xFF6E6377))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6E6377))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
            onPressed: () {
              Navigator.pop(context);
              // Add logout logic here
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
