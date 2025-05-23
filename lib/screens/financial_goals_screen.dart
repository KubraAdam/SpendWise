import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FinancialGoalsScreen extends StatefulWidget {
  final String userId;
  const FinancialGoalsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<FinancialGoalsScreen> createState() => _FinancialGoalsScreenState();
}

class _FinancialGoalsScreenState extends State<FinancialGoalsScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController savedController = TextEditingController();
  DateTime? selectedDate;

  void _clearForm() {
    titleController.clear();
    amountController.clear();
    savedController.clear();
    selectedDate = null;
  }

  void _showBottomSheet({String? docId, Map<String, dynamic>? data}) {
    if (data != null) {
      titleController.text = data['title'];
      amountController.text = data['amount'].toString();
      savedController.text = data['saved'].toString();
      selectedDate = (data['targetDate'] as Timestamp).toDate();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: 'Hedef Başlığı')),
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Hedef Tutarı')),
            TextField(controller: savedController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Şu Ana Kadar Biriken')),
            Row(
              children: [
                Expanded(
                  child: Text(selectedDate == null
                      ? 'Tarih Seçilmedi'
                      : DateFormat('yyyy-MM-dd').format(selectedDate!)),
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => selectedDate = picked);
                  },
                  child: Text('Tarih Seç'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text;
                final amount = double.tryParse(amountController.text) ?? 0.0;
                final saved = double.tryParse(savedController.text) ?? 0.0;
                final targetDate = selectedDate ?? DateTime.now();

                final dataToSave = {
                  'title': title,
                  'amount': amount,
                  'saved': saved,
                  'targetDate': targetDate,
                  'createdAt': FieldValue.serverTimestamp(),
                };

                final ref = FirebaseFirestore.instance
                    .collection('financial_goals')
                    .doc(widget.userId)
                    .collection('userGoals');

                if (docId == null) {
                  await ref.add(dataToSave);
                } else {
                  await ref.doc(docId).update(dataToSave);
                }

                _clearForm();
                Navigator.pop(context);
              },
              child: Text(docId == null ? 'Ekle' : 'Güncelle'),
            ),
          ],
        ),
      ),
    ).whenComplete(() => _clearForm());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Finansal Hedefler')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('financial_goals')
            .doc(widget.userId)
            .collection('userGoals')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final goals = snapshot.data!.docs;

          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final doc = goals[index];
              final data = doc.data() as Map<String, dynamic>;
              final percent = ((data['saved'] / data['amount']) * 100).clamp(0, 100);
              final deadline = (data['targetDate'] as Timestamp).toDate();
              final remainingDays = deadline.difference(DateTime.now()).inDays;

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(data['title'] ?? 'Hedef'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hedef: ₺${data['amount']} - Biriken: ₺${data['saved']}'),
                      Text('İlerleme: ${percent.toStringAsFixed(1)}%'),
                      LinearProgressIndicator(value: percent / 100),
                      Text('Kalan Gün: $remainingDays')
                    ],
                  ),
                  onTap: () => _showBottomSheet(docId: doc.id, data: data),
                  onLongPress: () async {
                    final confirm = await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Sil'),
                        content: Text('${data['title']} hedefini silmek istiyor musun?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('İptal')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Sil')),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await FirebaseFirestore.instance
                          .collection('financial_goals')
                          .doc(widget.userId)
                          .collection('userGoals')
                          .doc(doc.id)
                          .delete();
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBottomSheet(),
        child: Icon(Icons.add),
      ),
    );
  }
}
