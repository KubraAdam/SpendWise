// Yeni versiyonda fl_chart kullanilmadigi varsayilarak, bu dosyada sadece PieChart kullanildigi kismi ve kategori listesini guncelliyoruz.
// Bu dosya, yukarida saglanan kodun gelismis halidir. Asagida 3 maddeye gore guncellenmistir.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kisiselfinansapp/models/category.dart';
import 'dart:math';

class IncomeExpensesScreen extends StatefulWidget {
  const IncomeExpensesScreen({super.key});

  @override
  State<IncomeExpensesScreen> createState() => _IncomeExpensesScreenState();
}

class _IncomeExpensesScreenState extends State<IncomeExpensesScreen> {
  bool isIncome = true;
  final TextEditingController _amountController = TextEditingController();
  Category? selectedCategory;
  List<Map<String, dynamic>> incomeTransactions = [];
  List<Map<String, dynamic>> expenseTransactions = [];

  String selectedMonth = 'All';
  bool isDescending = true;

  final List<String> months = [
    'All', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  List<Category> get filteredCategories => isIncome
      ? [
          Category(name: "Salary", icon: Icons.attach_money, color: Colors.green),
          Category(name: "Gift", icon: Icons.card_giftcard, color: Colors.blue),
          Category(name: "Freelance", icon: Icons.laptop_mac, color: Colors.teal),
          Category(name: "Investment", icon: Icons.trending_up, color: Colors.orange),
        ]
      : [
          Category(name: "Market", icon: Icons.shopping_cart, color: Colors.red),
          Category(name: "Transport", icon: Icons.directions_bus, color: Colors.deepPurple),
          Category(name: "Health", icon: Icons.healing, color: Colors.pink),
          Category(name: "Education", icon: Icons.school, color: Colors.indigo),
        ];

  @override
  Widget build(BuildContext context) {
    final allTransactions = isIncome ? incomeTransactions : expenseTransactions;
    final filteredTransactions = _filterAndSortTransactions(allTransactions);
    final totalAmount = filteredTransactions.fold<double>(
        0.0, (sum, tx) => sum + tx['amount']);

    return Scaffold(
      backgroundColor: isIncome ? const Color(0xFFC1CBEF) : const Color(0xFFF3E8FF),
      appBar: AppBar(
        title: Text(isIncome ? "Income Tracking" : "Expenses Tracking"),
        backgroundColor: isIncome ? const Color(0xFF5946D2) : const Color(0xFF9575CD),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: [isIncome, !isIncome],
              onPressed: (index) {
                setState(() {
                  isIncome = index == 0;
                  selectedCategory = null;
                });
              },
              borderRadius: BorderRadius.circular(12),
              selectedColor: Colors.white,
              fillColor: isIncome ? const Color(0xFF9B9698) : const Color(0xFF9575CD),
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Text("Income")),
                Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Text("Expenses")),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildMonthDropdown()),
                IconButton(
                  onPressed: () {
                    setState(() {
                      isDescending = !isDescending;
                    });
                  },
                  icon: Icon(isDescending ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildWeeklySummary(),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount",
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = filteredCategories[index];
                  final isSelected = selectedCategory == category;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? category.color.withOpacity(0.7) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: category.color),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(category.icon, color: category.color, size: 30),
                          const SizedBox(height: 6),
                          Text(category.name, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _buildAddTransactionDialog,
              icon: const Icon(Icons.add),
              label: const Text("Add"),
              style: ElevatedButton.styleFrom(
                backgroundColor: isIncome ? const Color(0xFF9B9698) : const Color(0xFF9575CD),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),
            if (filteredTransactions.isNotEmpty)
              SizedBox(
                height: 160,
                width: 160,
                child: CustomPaint(
                  painter: _PieChartPainter(filteredTransactions, totalAmount),
                  child: Center(
                    child: Text(
                      "Total: \$${totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ...filteredTransactions.map((tx) => Card(
              child: ListTile(
                leading: Icon(tx['category'].icon, color: tx['category'].color),
                title: Text(tx['category'].name),
                subtitle: Text(
                  "\$${tx['amount'].toStringAsFixed(2)}\nDate: ${_formatDate(tx['date'])}",
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Icon(
                  isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isIncome ? const Color.fromARGB(255, 54, 101, 89) : Colors.red,
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySummary() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final txList = isIncome ? incomeTransactions : expenseTransactions;
    final weeklyTx = txList.where((tx) => tx['date'].isAfter(weekAgo)).toList();
    final totalWeekly = weeklyTx.fold<double>(0.0, (sum, tx) => sum + tx['amount']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isIncome ? const Color(0xFFDDEAFE) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weekly Summary",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.blue : Colors.redAccent,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text("Total: \$${totalWeekly.toStringAsFixed(2)}"),
          const SizedBox(height: 4),
          ...weeklyTx.map((tx) => Text("- ${tx['category'].name}: \$${tx['amount'].toStringAsFixed(2)}"))
        ],
      ),
    );
  }

  Widget _buildMonthDropdown() {
    return DropdownButton<String>(
      value: selectedMonth,
      isExpanded: true,
      items: months.map((month) {
        return DropdownMenuItem(value: month, child: Text(month));
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedMonth = value!;
        });
      },
    );
  }

  void _buildAddTransactionDialog() {
    if (_amountController.text.isEmpty || selectedCategory == null) return;

    final newTransaction = {
      'amount': double.parse(_amountController.text),
      'category': selectedCategory!,
      'month': DateTime.now().month,
      'date': DateTime.now(),
      'type': isIncome ? 'income' : 'expense',
    };

    setState(() {
      if (isIncome) {
        incomeTransactions.add(newTransaction);
      } else {
        expenseTransactions.add(newTransaction);
      }
      _amountController.clear();
      selectedCategory = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('transactions').add({
        'uid': user.uid,
        'amount': newTransaction['amount'],
        'category': (newTransaction['category'] as Category).name,
        'categoryIcon': (newTransaction['category'] as Category).icon.codePoint,
        'categoryColor': (newTransaction['category'] as Category).color.value,
        'month': newTransaction['month'],
        'date': newTransaction['date'],
        'type': newTransaction['type'],
      });
    }
  }

  List<Map<String, dynamic>> _filterAndSortTransactions(List<Map<String, dynamic>> transactions) {
    List<Map<String, dynamic>> filtered = transactions;
    if (selectedMonth != 'All') {
      final monthIndex = months.indexOf(selectedMonth);
      filtered = transactions.where((tx) => tx['month'] == monthIndex).toList();
    }
    filtered.sort((a, b) => isDescending ? b['amount'].compareTo(a['amount']) : a['amount'].compareTo(b['amount']));
    return filtered;
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}

class _PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> transactions;
  final double total;

  _PieChartPainter(this.transactions, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    double startRadian = -pi / 2;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    for (var tx in transactions) {
      final value = tx['amount'] as double;
      final sweep = (value / total) * 2 * pi;
      paint.color = (tx['category'] as Category).color;
      canvas.drawArc(rect, startRadian, sweep, true, paint);

      final percentage = ((value / total) * 100).toStringAsFixed(1);
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${tx['category'].name}\n$percentage%',
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );

      final angle = startRadian + sweep / 2;
      final offset = Offset(
        size.width / 2 + cos(angle) * (size.width / 3.2) - 10,
        size.height / 2 + sin(angle) * (size.height / 3.2) - 10,
      );
      textPainter.layout(minWidth: 0, maxWidth: size.width);
      textPainter.paint(canvas, offset);

      startRadian += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
