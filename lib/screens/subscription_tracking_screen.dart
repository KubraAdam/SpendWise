import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class SubscriptionTrackingScreen extends StatefulWidget {
  final String userId;
  const SubscriptionTrackingScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<SubscriptionTrackingScreen> createState() => _SubscriptionTrackingScreenState();
}

class _SubscriptionTrackingScreenState extends State<SubscriptionTrackingScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController serviceController = TextEditingController();
  DateTime? selectedDate;
  bool isActive = true;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
  }

  Future<void> _scheduleNotification(String title, DateTime billingDate) async {
    final scheduledDate = billingDate.subtract(Duration(days: 1));
    if (scheduledDate.isBefore(DateTime.now())) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      title.hashCode,
      'Yaklaşan Ödeme',
      '$title aboneliğinizin ödemesi yarın!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'subscription_channel',
          'Abonelik Bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  void _saveSubscription({String? docId}) async {
    final name = nameController.text;
    final price = double.tryParse(priceController.text) ?? 0.0;
    final service = serviceController.text;

    final data = {
      'name': name,
      'price': price,
      'service': service,
      'billingDate': selectedDate ?? DateTime.now(),
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final collection = FirebaseFirestore.instance
        .collection('subscriptions')
        .doc(widget.userId)
        .collection('userSubscriptions');

    if (docId == null) {
      await collection.add(data);
    } else {
      await collection.doc(docId).update(data);
    }

    await _scheduleNotification(name, selectedDate ?? DateTime.now());
    _clearForm();
  }

  void _clearForm() {
    nameController.clear();
    priceController.clear();
    serviceController.clear();
    selectedDate = null;
    isActive = true;
    setState(() {});
  }

  void _editSubscription(String docId, Map<String, dynamic> data) {
    nameController.text = data['name'];
    priceController.text = data['price'].toString();
    serviceController.text = data['service'];
    selectedDate = (data['billingDate'] as Timestamp).toDate();
    isActive = data['isActive'];

    _showBottomSheet(docId: docId);
  }

  void _showBottomSheet({String? docId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Abonelik Adı')),
            TextField(controller: priceController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Aylık Ücret')),
            TextField(controller: serviceController, decoration: InputDecoration(labelText: 'Servis')),
            Row(
              children: [
                Expanded(
                  child: Text(selectedDate == null ? 'Tarih Seçilmedi' : DateFormat('yyyy-MM-dd').format(selectedDate!)),
                ),
                TextButton(onPressed: _pickDate, child: Text("Tarih Seç")),
              ],
            ),
            Row(
              children: [
                Checkbox(value: isActive, onChanged: (val) => setState(() => isActive = val!)),
                Text("Aktif mi?")
              ],
            ),
            ElevatedButton(
              onPressed: () {
                _saveSubscription(docId: docId);
                Navigator.pop(context);
              },
              child: Text(docId == null ? "Ekle" : "Güncelle"),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Abonelik Takibi')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('subscriptions')
            .doc(widget.userId)
            .collection('userSubscriptions')
            .orderBy('billingDate')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;
              final billingDate = (data['billingDate'] as Timestamp).toDate();
              final daysLeft = billingDate.difference(DateTime.now()).inDays;

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(data['name']),
                  subtitle: Text('₺${data['price']} - ${data['service']}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Kalan: $daysLeft gün'),
                      Icon(data['isActive'] ? Icons.check_circle : Icons.cancel, color: data['isActive'] ? Colors.green : Colors.red),
                    ],
                  ),
                  onTap: () => _editSubscription(docId, data),
                  onLongPress: () async {
                    final confirmed = await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("Silmek istiyor musun?"),
                        content: Text("${data['name']} aboneliği silinecek."),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("İptal")),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Sil")),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await FirebaseFirestore.instance
                          .collection('subscriptions')
                          .doc(widget.userId)
                          .collection('userSubscriptions')
                          .doc(docId)
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
