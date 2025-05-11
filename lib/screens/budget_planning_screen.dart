import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart'; // ✅ Grafik için eklendi

class BudgetPlanningScreen extends StatefulWidget {
  const BudgetPlanningScreen({super.key});

  @override
  State<BudgetPlanningScreen> createState() => _BudgetPlanningScreenState();
}

class _BudgetPlanningScreenState extends State<BudgetPlanningScreen> {
  final TextEditingController _monthlyBudgetController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _categoryBudgetController = TextEditingController();

  List<Map<String, String>> _categoryBudgets = [];

  void _addCategoryBudget() {
    if (_categoryController.text.isNotEmpty && _categoryBudgetController.text.isNotEmpty) {
      setState(() {
        _categoryBudgets.add({
          'category': _categoryController.text,
          'budget': _categoryBudgetController.text,
        });
        _categoryController.clear();
        _categoryBudgetController.clear();
      });
    }
  }

  Future<void> _saveBudgetPlan() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _monthlyBudgetController.text.isEmpty) return;

    final Map<String, dynamic> data = {
      'userId': user.uid,
      'totalBudget': double.tryParse(_monthlyBudgetController.text) ?? 0.0,
      'categoryBudgets': _categoryBudgets,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('budgets').add(data);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Bütçe başarıyla kaydedildi.")),
    );
  }

  List<BarChartGroupData> _buildBarChartData() {
    return _categoryBudgets.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value['category'] ?? '';
      final value = double.tryParse(entry.value['budget'] ?? '0') ?? 0.0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(toY: value, width: 20, borderRadius: BorderRadius.circular(4)),
        ],
        showingTooltipIndicators: [0],
      );
    }).toList();
  }

  Widget _buildBarChart() {
    if (_categoryBudgets.isEmpty) return const SizedBox();

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          barGroups: _buildBarChartData(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= _categoryBudgets.length) return const SizedBox();
                  return Text(_categoryBudgets[index]['category'] ?? '', style: const TextStyle(fontSize: 10));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bütçe Planlama'),
        backgroundColor: const Color(0xFF1C027B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _monthlyBudgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Aylık Toplam Bütçe',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _categoryBudgetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Bütçe Tutarı',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addCategoryBudget,
                  )
                ],
              ),
              const SizedBox(height: 16),
              Column(
                children: _categoryBudgets.map((item) {
                  return ListTile(
                    title: Text("${item['category']} - ${item['budget']}₺"),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              _buildBarChart(), // ✅ Grafik eklendi
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveBudgetPlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C027B),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Bütçeyi Kaydet'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
