import 'package:flutter/material.dart';

const List<String> _namaBulan = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

String formatTanggal(DateTime d) =>
    '${d.day} ${_namaBulan[d.month - 1]} ${d.year}';

String formatRupiah(int angka) {
  final negatif = angka < 0;
  final s = angka.abs().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '${negatif ? '-' : ''}Rp $buf';
}

(IconData, Color) _gayaKategori(String kategori) {
  switch (kategori) {
    case 'Makanan':
      return (Icons.fastfood, Colors.orange);
    case 'Transportasi':
      return (Icons.directions_car, Colors.blueAccent);
    case 'Belanja':
      return (Icons.shopping_cart, Colors.deepOrange);
    case 'Hiburan':
      return (Icons.movie, Colors.purple);
    case 'Tagihan':
      return (Icons.receipt_long, Colors.teal);
    case 'Pemasukan':
      return (Icons.attach_money, Colors.green);
    default:
      return (Icons.category, Colors.grey);
  }
}

/// Model satu baris transaksi (dibaca dari SQLite)
class TransaksiItem {
  final int id;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String tanggal;
  final String nominal; // sudah diformat, contoh: - Rp 50.000
  final int nominalAngka;
  final String kategori;
  final bool isPengeluaran;

  const TransaksiItem({
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.tanggal,
    required this.nominal,
    required this.nominalAngka,
    required this.kategori,
    required this.isPengeluaran,
  });

  factory TransaksiItem.fromMap(Map<String, Object?> m) {
    final kategori = m['kategori'] as String;
    final angka = m['nominal'] as int;
    final pengeluaran = (m['is_pengeluaran'] as int) == 1;
    final gaya = _gayaKategori(kategori);
    return TransaksiItem(
      id: m['id'] as int,
      icon: gaya.$1,
      iconColor: gaya.$2,
      title: m['title'] as String,
      tanggal: m['tanggal'] as String,
      nominal: '${pengeluaran ? '-' : '+'} ${formatRupiah(angka)}',
      nominalAngka: angka,
      kategori: kategori,
      isPengeluaran: pengeluaran,
    );
  }
}