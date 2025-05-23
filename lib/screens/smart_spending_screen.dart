import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SmartSpendingScreen extends StatefulWidget {
  const SmartSpendingScreen({super.key});

  @override
  State<SmartSpendingScreen> createState() => _SmartSpendingScreenState();
}

class _SmartSpendingScreenState extends State<SmartSpendingScreen> {
  double _totalExpense = 0.0;
  double _generalLimit = 0.0;
  double _categoryLimit = 0.0;
  String? _selectedCategory;
  List<String> _categories = [];
  String _maxCategory = '-';
  String _minCategory = '-';
  double _maxAmount = 0.0;
  double _minAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchExpenseData();
  }

  Future<void> _fetchExpenseData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final query = await FirebaseFirestore.instance
        .collection('transactions')
        .where('uid', isEqualTo: uid)
        .where('type', isEqualTo: 'expense')
        .get();

    double total = 0.0;
    final Map<String, double> categoryTotals = {};

    for (var doc in query.docs) {
      final data = doc.data();
      final amount = (data['amount'] as num).toDouble();
      final category = data['category'] as String;

      total += amount;
      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
    }

    String maxCat = '-';
    String minCat = '-';
    double max = 0.0;
    double min = double.infinity;

    for (var entry in categoryTotals.entries) {
      if (entry.value > max) {
        max = entry.value;
        maxCat = entry.key;
      }
      if (entry.value < min) {
        min = entry.value;
        minCat = entry.key;
      }
    }

    setState(() {
      _totalExpense = total;
      _categories = categoryTotals.keys.toList();
      _maxCategory = maxCat;
      _minCategory = minCat;
      _maxAmount = max;
      _minAmount = min == double.infinity ? 0.0 : min;
    });
  }

  void _checkLimits() {
    if (_totalExpense > _generalLimit && _generalLimit > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Genel harcama limitini aştınız!")),
      );
    }

    if (_selectedCategory != null && _categoryLimit > 0) {
      final categoryTotal = _categories.contains(_selectedCategory!) ?
        (_selectedCategory == _maxCategory ? _maxAmount : (_selectedCategory == _minCategory ? _minAmount : 0.0))
        : 0.0;

      if (categoryTotal > _categoryLimit) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${_selectedCategory!} kategorisindeki harcama limiti aşıldı!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Akıllı Harcama Yönetimi"),
        backgroundColor: const Color(0xFF1C027B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Toplam Harcama: ${_totalExpense.toStringAsFixed(2)} ₺"),
            const SizedBox(height: 12),
            Text("Genel Harcama Limiti (₺)"),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) => _generalLimit = double.tryParse(value) ?? 0.0,
              decoration: const InputDecoration(hintText: "Örn. 3000"),
            ),
            const SizedBox(height: 20),
            Text("Tasarruf Yapmak İstediğiniz Kategori:"),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedCategory,
              hint: const Text("Kategori seçin"),
              items: _categories.map((cat) {
                return DropdownMenuItem<String>(
                  value: cat,
                  child: Text(cat),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),
            const SizedBox(height: 12),
            Text("Seçilen kategori limiti (₺)"),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) => _categoryLimit = double.tryParse(value) ?? 0.0,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkLimits,
              child: const Text("Limiti Kontrol Et"),
            ),
            const SizedBox(height: 20),
            Text("\u{25B2} En Fazla Harcama: $_maxCategory - ${_maxAmount.toStringAsFixed(2)} ₺"),
            Text("\u{25BC} En Az Harcama: $_minCategory - ${_minAmount.toStringAsFixed(2)} ₺"),
          ],
        ),
      ),
    );
  }
}
