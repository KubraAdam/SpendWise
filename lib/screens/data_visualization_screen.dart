import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DataVisualizationScreen extends StatefulWidget {
  final String userId;
  const DataVisualizationScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<DataVisualizationScreen> createState() => _DataVisualizationScreenState();
}

class _DataVisualizationScreenState extends State<DataVisualizationScreen> with SingleTickerProviderStateMixin {
  Map<String, double> expenseTotals = {};
  Map<String, double> incomeTotals = {};
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchTransactionData();
  }

  Future<void> _fetchTransactionData() async {
    print("Tüm veriler getiriliyor...");

    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .doc(widget.userId)
        .collection('transactions')
        .get();

    print("Toplam belge: ${snapshot.docs.length}");

    Map<String, double> tempExpenses = {};
    Map<String, double> tempIncomes = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      print("Belge: $data");
      final category = data['category'] ?? 'Bilinmeyen';
      final amount = (data['amount'] ?? 0).toDouble();
      final type = data['type'];

      if (type == 'expense') {
        tempExpenses[category] = (tempExpenses[category] ?? 0) + amount;
      } else if (type == 'income') {
        tempIncomes[category] = (tempIncomes[category] ?? 0) + amount;
      }
    }

    setState(() {
      expenseTotals = tempExpenses;
      incomeTotals = tempIncomes;
      isLoading = false;
    });
  }

  List<PieChartSectionData> _generateSections(Map<String, double> totals) {
    return totals.entries.map((entry) {
      final color = Colors.primaries[totals.keys.toList().indexOf(entry.key) % Colors.primaries.length];
      return PieChartSectionData(
        title: entry.key,
        value: entry.value,
        color: color,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Widget _buildChart(Map<String, double> totals) {
    return totals.isEmpty
        ? const Center(child: Text("Veri bulunamadı."))
        : Column(
            children: [
              AspectRatio(
                aspectRatio: 1.3,
                child: PieChart(
                  PieChartData(
                    sections: _generateSections(totals),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: totals.entries.map((entry) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.primaries[totals.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                      ),
                      title: Text(entry.key),
                      trailing: Text("₺${entry.value.toStringAsFixed(2)}"),
                    );
                  }).toList(),
                ),
              )
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Veri Görselleştirme"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Giderler'),
            Tab(text: 'Gelirler'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildChart(expenseTotals),
                _buildChart(incomeTotals),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
