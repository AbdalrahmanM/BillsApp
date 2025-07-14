import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bill_details_screen.dart'; // تأكد من وجود هذه الصفحة

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
  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'abdodj9425@gmail.com',
      query: 'subject=Support%20Request',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchWhatsApp() async {
    const phone = '966500000000'; // default phone number
    final Uri whatsappUri = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    }
  }
  void _showHelpModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFB300), Color(0xFF8D6E63)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x338D6E63),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: const Icon(
                  Icons.headset_mic,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "We're Here for You",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Our support team is here to assist you at any time.",
                style: TextStyle(fontSize: 16, color: Color(0xFF8D6E63)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _launchEmail();
                    },
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Contact via Email'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6D4C41),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _launchWhatsApp();
                    },
                    icon: const Icon(Icons.chat_bubble, color: Colors.white),
                    label: const Text('Contact via WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextButton(
                onPressed: () {
                  // TODO: Implement feedback action
                  Navigator.pop(context);
                },
                child: const Text(
                  'Send Feedback',
                  style: TextStyle(color: Color(0xFF8D6E63)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFFFB300), Color(0xFF8D6E63)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x338D6E63),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showHelpModal,
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.headset_mic, color: Colors.white, size: 32),
          tooltip: 'Help',
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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BillDetailsScreen(
              type: type.toLowerCase(),
              docId: widget.docId,
            ),
          ),
        );
      },
      child: _buildBillCard(
        "${_translateType(type)}",
        "\$${bill['amount']}",
        bill['status'],
        getIcon(type),
        getColor(type),
      ),
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
