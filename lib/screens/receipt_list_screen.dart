import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReceiptListScreen extends StatelessWidget {
  const ReceiptListScreen({super.key});

  void _deleteReceipt(BuildContext context, String docId) async {
    await FirebaseFirestore.instance.collection('receipts').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fiş silindi")),
    );
  }

  void _editReceipt(BuildContext context, String docId, String currentText) {
    final TextEditingController controller = TextEditingController(text: currentText);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Fişi Düzenle"),
        content: TextField(
          controller: controller,
          maxLines: 10,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            child: const Text("İptal"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: const Text("Kaydet"),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('receipts')
                  .doc(docId)
                  .update({'text': controller.text});
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fiş güncellendi")),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiş Listesi'),
        backgroundColor: const Color(0xFF1C027B),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('receipts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Hata oluştu"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final receipts = snapshot.data!.docs;

          if (receipts.isEmpty) {
            return const Center(child: Text("Kayıtlı fiş bulunamadı."));
          }

          return ListView.builder(
            itemCount: receipts.length,
            itemBuilder: (context, index) {
              final data = receipts[index].data() as Map<String, dynamic>;
              final text = data['text'] ?? '';
              final docId = receipts[index].id;

              // 🔁 createdAt veya timestamp kontrolü
              final rawDate = data['createdAt'] ?? data['timestamp'];
              String formattedDate = 'Tarih yok';
              if (rawDate is Timestamp) {
                formattedDate = rawDate.toDate().toString().substring(0, 16);
              }

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    text.split('\n').first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text("Tarih: $formattedDate"),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editReceipt(context, docId, text);
                      } else if (value == 'delete') {
                        _deleteReceipt(context, docId);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'edit', child: Text('Düzenle')),
                      const PopupMenuItem(value: 'delete', child: Text('Sil')),
                    ],
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
