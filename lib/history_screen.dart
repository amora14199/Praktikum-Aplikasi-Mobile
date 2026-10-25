import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'transaction_detail_screen.dart';
import 'transaksi_item.dart';
import 'user_session.dart';

/// TUGAS 1 - Halaman Riwayat Transaksi (data dari SQLite)
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<TransaksiItem> _transaksi = [];

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    final rows = await DatabaseHelper.instance.getTransaksi(UserSession.id);
    if (!mounted) return;
    setState(() {
      _transaksi = rows.map(TransaksiItem.fromMap).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _transaksi.isEmpty
          ? const Center(
              child: Text('Belum ada riwayat transaksi',
                  style: TextStyle(fontSize: 16)),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _transaksi.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final t = _transaksi[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: t.iconColor,
                    child: Icon(t.icon, color: Colors.white),
                  ),
                  title: Text(t.title),
                  subtitle: Text('${t.tanggal} • ${t.kategori}'),
                  trailing: Text(
                    t.nominal,
                    style: TextStyle(
                      color: t.isPengeluaran ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionDetailScreen(
                          title: t.title,
                          amount: t.nominal,
                          category: t.kategori,
                          date: t.tanggal,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}