import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

enum TransactionMode { income, expense }

class IncomeExpensesScreen extends StatefulWidget {
  const IncomeExpensesScreen({super.key});

  @override
  State<IncomeExpensesScreen> createState() => _IncomeExpensesScreenState();
}

class _IncomeExpensesScreenState extends State<IncomeExpensesScreen> {
  TransactionMode _currentMode = TransactionMode.expense;

  final List<Map<String, dynamic>> _transactions = [];

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryNameController = TextEditingController();

  void _openAddTransactionDialog() {
    _amountController.clear();
    _categoryNameController.clear();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add New Transaction', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: _categoryNameController,
                decoration: const InputDecoration(
                  hintText: 'Category',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Amount',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: _currentMode == TransactionMode.income ? const Color(0xFF6B4C9A) : const Color(0xFFC4C3D0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_amountController.text.isNotEmpty && _categoryNameController.text.isNotEmpty) {
                    setState(() {
                      _transactions.add({
                        'category': _categoryNameController.text,
                        'amount': double.parse(_amountController.text),
                        'mode': _currentMode,
                      });
                    });
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _generatePieChartSections() {
    final total = _transactions.where((e) => e['mode'] == _currentMode).fold(0.0, (sum, item) => sum + item['amount']);
    if (total == 0) return [];

    return _transactions
        .where((e) => e['mode'] == _currentMode)
        .map((e) => PieChartSectionData(
              color: Colors.primaries[_transactions.indexOf(e) % Colors.primaries.length].withOpacity(0.7),
              value: (e['amount'] / total) * 100,
              title: '${e['category']}\n${e['amount'].toStringAsFixed(0)}₺',
              radius: 60,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentMode == TransactionMode.income ? const Color(0xFFEEE6FF) : const Color(0xFFF3F0F7),
      appBar: AppBar(
        title: Text(
          _currentMode == TransactionMode.income ? 'Income Tracker' : 'Expenses Tracker',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: _currentMode == TransactionMode.income ? const Color(0xFF6B4C9A) : const Color(0xFFC4C3D0),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _openAddTransactionDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ToggleButtons(
              borderRadius: BorderRadius.circular(12),
              isSelected: [_currentMode == TransactionMode.income, _currentMode == TransactionMode.expense],
              onPressed: (index) {
                setState(() {
                  _currentMode = index == 0 ? TransactionMode.income : TransactionMode.expense;
                });
              },
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('Income')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('Expenses')),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _transactions.any((e) => e['mode'] == _currentMode)
                  ? PieChart(PieChartData(
                      sections: _generatePieChartSections(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ))
                  : const Center(child: Text('No Data Yet')),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: _transactions
                    .where((e) => e['mode'] == _currentMode)
                    .map((e) => ListTile(
                          leading: Icon(Icons.circle, color: Colors.primaries[_transactions.indexOf(e) % Colors.primaries.length]),
                          title: Text(e['category']),
                          trailing: Text('${e['amount'].toStringAsFixed(2)}₺'),
                        ))
                    .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
