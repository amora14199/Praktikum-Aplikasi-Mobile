import 'package:flutter/material.dart';
import 'dashboard_screen.dart'; // Dari modul sebelumnya
import 'history_screen.dart'; // Tugas 1
import 'profile_screen.dart'; // Tugas 2

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Tab pertama aktif secara default (Beranda)

  // List kumpulan halaman
  final List<Widget> _pages = [
    const DashboardScreen(),
    // Langkah 1.4 (placeholder):
    // const Center(child: Text("Halaman Riwayat (Kosong)", style: TextStyle(fontSize: 24))),
    const HistoryScreen(), // Tugas 1
    const ProfileScreen(), // Tugas 2
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Ganti layar sesuai index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.red,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}