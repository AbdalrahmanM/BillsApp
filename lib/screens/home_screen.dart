import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String lastName;
  final String docId;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.lastName,
    required this.docId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> bills = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBills();
  }

  Future<void> fetchBills() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.docId)
          .collection('Bills')
          .get();

      Map<String, Map<String, dynamic>> latestBills = {};

      for (var doc in snapshot.docs) {
        var data = doc.data();
        String type = data['type'].toString().toLowerCase();
        int month = int.tryParse(data['month']?.toString() ?? "0") ?? 0;

        if (!latestBills.containsKey(type)) {
          latestBills[type] = data;
        } else {
          int existingMonth =
              int.tryParse(latestBills[type]?['month']?.toString() ?? "0") ?? 0;
          if (month > existingMonth) {
            latestBills[type] = data;
          }
        }
      }

      setState(() {
        bills = latestBills.values.toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching bills: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAEBD7),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : PageView(
                children: [_buildBillsPage(), _buildAnnouncementsPage()],
              ),
      ),
    );
  }

  Widget _buildBillsPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('lib/assets/profile.jpg'),
          ),
          const SizedBox(height: 10),
          Text(
            "Hello, ${widget.userName} ${widget.lastName}",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Welcome back!",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildFromData('water'),
                _buildFromData('gas'),
                _buildFromData('electricity'),
                _buildFromData('fees'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFromData(String type) {
    final bill = bills.firstWhere(
      (b) => b['type'].toString().toLowerCase() == type,
      orElse: () => {'amount': 0, 'status': 'N/A'},
    );

    return _buildBillCard(
      "${_translateType(type)} ",
      "\$${bill['amount']}",
      bill['status'],
      getIcon(type),
      getColor(type),
    );
  }

  Widget _buildBillCard(
    String title,
    String amount,
    String status,
    IconData icon,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: Colors.brown),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(amount, style: const TextStyle(fontSize: 20)),
          Text(status, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsPage() {
    return Center(
      child: Text(
        "Announcements",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  IconData getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'water':
        return Icons.water_drop;
      case 'gas':
        return Icons.local_fire_department;
      case 'electricity':
        return Icons.bolt;
      default:
        return Icons.payments;
    }
  }

  Color getColor(String type) {
    switch (type.toLowerCase()) {
      case 'water':
        return Colors.lightBlue.shade100;
      case 'gas':
        return Colors.orange.shade100;
      case 'electricity':
        return Colors.blue.shade100;
      default:
        return Colors.amber.shade100;
    }
  }

  String _translateType(String type) {
    switch (type.toLowerCase()) {
      case 'water':
        return 'Water';
      case 'gas':
        return 'Gas';
      case 'electricity':
        return 'Electricity';
      case 'fees':
        return 'Additional Fees';
      default:
        return 'Other';
    }
  }
}
