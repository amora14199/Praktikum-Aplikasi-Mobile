import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'transaction_detail_screen.dart';
import 'transaksi_item.dart';
import 'user_session.dart';

// HALAMAN UTAMA (Scaffold)
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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

  // Saldo = total pemasukan - total pengeluaran
  int get _saldo => _transaksi.fold(
      0,
      (total, t) =>
          total + (t.isPengeluaran ? -t.nominalAngka : t.nominalAngka));

  Future<void> _tambah([String? kategori]) async {
    // Named route '/add', lalu muat ulang data setelah kembali
    await Navigator.pushNamed(context, '/add', arguments: kategori);
    _muatData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Keuangan'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GreetingWidget(),
              const SizedBox(height: 20),
              BalanceCardWidget(saldo: _saldo),
              const SizedBox(height: 20),
              ActionButtonsWidget(onTambah: _tambah),
              const SizedBox(height: 20),
              RecentTransactionsWidget(data: _transaksi),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Catat Transaksi"),
        onPressed: () => _tambah(),
      ),
    );
  }
}

// STATELESS WIDGET (Sapaan)
class GreetingWidget extends StatelessWidget {
  const GreetingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool sudahLogin = UserSession.email.isNotEmpty;
    final String nama = sudahLogin ? UserSession.name : 'Budi';
    final String keterangan =
        sudahLogin ? UserSession.email : 'Selamat datang kembali!';

    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: Colors.redAccent,
          child: Icon(Icons.person, size: 30, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Halo, $nama',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Text(keterangan,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}

// STATEFUL WIDGET (Kartu Saldo)
class BalanceCardWidget extends StatefulWidget {
  final int saldo;
  const BalanceCardWidget({super.key, required this.saldo});

  @override
  State<BalanceCardWidget> createState() => _BalanceCardWidgetState();
}

class _BalanceCardWidgetState extends State<BalanceCardWidget> {
  bool _isBalanceVisible = true;

  void _toggleVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.redAccent,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Saldo Utama',
                    style: TextStyle(fontSize: 16, color: Colors.white70)),
                IconButton(
                  icon: Icon(
                      _isBalanceVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white),
                  onPressed: _toggleVisibility,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _isBalanceVisible ? formatRupiah(widget.saldo) : 'Rp *********',
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// WIDGET TOMBOL AKSI (ROW)
class ActionButtonsWidget extends StatelessWidget {
  final void Function(String? kategori) onTambah;
  const ActionButtonsWidget({super.key, required this.onTambah});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
            Icons.arrow_downward, 'Pemasukan', Colors.green, 'Pemasukan'),
        _buildActionButton(
            Icons.arrow_upward, 'Pengeluaran', Colors.red, null),
        _buildActionButton(Icons.swap_horiz, 'Transfer', Colors.blue, null),
      ],
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, Color color, String? kategori) {
    return GestureDetector(
      onTap: () => onTambah(kategori),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// WIDGET DAFTAR TRANSAKSI (COLUMN & LISTTILE)
class RecentTransactionsWidget extends StatelessWidget {
  final List<TransaksiItem> data;
  const RecentTransactionsWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final tampil = data.take(5).toList(); // 5 transaksi terbaru

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transaksi Terakhir',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: tampil.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text('Belum ada transaksi',
                        style: TextStyle(color: Colors.grey)),
                  ),
                )
              : Column(
                  children: [
                    for (int i = 0; i < tampil.length; i++) ...[
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: tampil[i].iconColor,
                          child: Icon(tampil[i].icon, color: Colors.white),
                        ),
                        title: Text(tampil[i].title),
                        subtitle: Text(tampil[i].tanggal),
                        trailing: Text(
                          tampil[i].nominal,
                          style: TextStyle(
                            color: tampil[i].isPengeluaran
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionDetailScreen(
                                title: tampil[i].title,
                                amount: tampil[i].nominal,
                                category: tampil[i].kategori,
                                date: tampil[i].tanggal,
                              ),
                            ),
                          );
                        },
                      ),
                      if (i != tampil.length - 1) const Divider(height: 1),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}