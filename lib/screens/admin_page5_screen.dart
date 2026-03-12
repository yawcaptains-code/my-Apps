import 'package:flutter/material.dart';

/// Admin Page 5 – (Coming Soon)
class AdminPage5Screen extends StatelessWidget {
  const AdminPage5Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF990000),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2D0000), Color(0xFF990000), Color(0xFFC62828)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        title: const Text('Admin Page 5',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/admin-dashboard');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            tooltip: 'Admin Page 6',
            onPressed: () => Navigator.pushNamed(context, '/admin-page6'),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Coming Soon',
          style: TextStyle(color: Colors.white54, fontSize: 18),
        ),
      ),
    );
  }
}
