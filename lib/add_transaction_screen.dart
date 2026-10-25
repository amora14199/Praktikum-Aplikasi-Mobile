import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'transaksi_item.dart';
import 'user_session.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _judulController = TextEditingController();
  final _nominalController = TextEditingController();
  final _tanggalController = TextEditingController();

  static const List<String> _kategoriList = [
    'Makanan',
    'Transportasi',
    'Belanja',
    'Hiburan',
    'Tagihan',
    'Pemasukan',
    'Lainnya',
  ];

  DateTime? _tanggal;
  String _kategori = 'Makanan';
  bool _argumenDibaca = false;
  bool _menyimpan = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Tombol "Pemasukan" di Dashboard mengirim kategori awal 'Pemasukan'
    if (!_argumenDibaca) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is String && _kategoriList.contains(arg)) {
        _kategori = arg;
      }
      _argumenDibaca = true;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _nominalController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  void _snack(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _tanggal = picked;
        _tanggalController.text = formatTanggal(picked);
      });
    }
  }

  Future<void> _simpan() async {
    final judul = _judulController.text.trim();
    final nominal = int.tryParse(
        _nominalController.text.replaceAll(RegExp(r'[^0-9]'), ''));

    if (judul.isEmpty) {
      _snack('Judul transaksi wajib diisi');
      return;
    }
    if (nominal == null || nominal <= 0) {
      _snack('Nominal harus berupa angka lebih dari 0');
      return;
    }

    setState(() => _menyimpan = true);
    await DatabaseHelper.instance.insertTransaksi(
      userId: UserSession.id,
      title: judul,
      nominal: nominal,
      kategori: _kategori,
      tanggal: formatTanggal(_tanggal ?? DateTime.now()),
      isPengeluaran: _kategori != 'Pemasukan',
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catat Transaksi Baru'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _judulController,
              decoration: const InputDecoration(
                labelText: 'Judul Transaksi',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nominalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nominal (Rp)',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tanggalController,
              readOnly: true,
              onTap: _pilihTanggal,
              decoration: const InputDecoration(
                labelText: 'Tanggal Transaksi',
                prefixIcon: Icon(Icons.calendar_today),
                suffixIcon: Icon(Icons.add_circle, color: Colors.red),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: _kategoriList
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _kategori = v);
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                ),
                onPressed: _menyimpan ? null : _simpan,
                child: const Text(
                  'Simpan Transaksi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}