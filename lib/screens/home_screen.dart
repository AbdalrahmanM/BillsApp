import 'package:bills_app/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/login_screen.dart'; // <-- Add this import for navigation
import 'bill_details_screen.dart'; // تأكد من وجود هذه الصفحة
import 'theme_controller.dart'; // import your controller

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: isDark ? const Color(0xFF232323) : Colors.white,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF232323), Color(0xFF2D2D2D)],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                  ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isDark
                      ? const LinearGradient(
                          colors: [Color(0xFF8D6E63), Color(0xFF4E342E)],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFFFB300), Color(0xFF8D6E63)],
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.3)
                          : const Color(0x338D6E63),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
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
              Text(
                "We're Here for You",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF6D4C41),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Our support team is here to assist you at any time.",
                style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? Colors.brown.shade100
                      : const Color(0xFF8D6E63),
                ),
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
                      backgroundColor: isDark
                          ? Colors.brown.shade700
                          : const Color(0xFF6D4C41),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
                  Navigator.pop(context);
                },
                child: Text(
                  'Send Feedback',
                  style: TextStyle(
                    color: isDark
                        ? Colors.brown.shade100
                        : const Color(0xFF8D6E63),
                  ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF232323) : const Color(0xFFFAEBD7);
    final cardColor = isDark ? const Color(0xFF2D2D2D) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF6D4C41);
    final iconColor = isDark ? Colors.white : const Color(0xFF8D6E63);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: null,
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons
                        .light_mode // ☀️ أيقونة جديدة للوضع الفاتح
                  : Icons.dark_mode, // 🌙 أيقونة جديدة للوضع الداكن
              color: iconColor,
            ),
            onPressed: () {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              themeController.setTheme(
                isDark ? ThemeMode.light : ThemeMode.dark,
              );
              setState(() {});
            },
            tooltip: Theme.of(context).brightness == Brightness.dark
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : PageView(
                    children: [
                      _buildBillsPage(isDark),
                      _buildAnnouncementsPage(isDark),
                    ],
                  ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 24.0,
                  left: 16.0,
                  right: 16.0,
                ),
                child: Container(
                  width: double.infinity,
                  height: 92,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown.withOpacity(0.10),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _showHelpModal,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.headset_mic,
                                color: iconColor,
                                size: 38,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Support',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.logout_outlined,
                                color: iconColor,
                                size: 38,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillsPage(bool isDark) {
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
                _buildFromData('water', isDark),
                _buildFromData('gas', isDark),
                _buildFromData('electricity', isDark),
                _buildFromData('fees', isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFromData(String type, bool isDark) {
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
        getColor(type, isDark),
        isDark,
      ),
    );
  }

  Widget _buildBillCard(
    String title,
    String amount,
    String status,
    IconData icon,
    Color bgColor,
    bool isDark,
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
          Icon(icon, size: 30, color: isDark ? Colors.white : Colors.brown),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(amount, style: const TextStyle(fontSize: 20)),
          Text(status, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsPage(bool isDark) {
    return Center(
      child: Text(
        "Announcements",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.blue.shade700,
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

  Color getColor(String type, bool isDark) {
    switch (type.toLowerCase()) {
      case 'water':
        return isDark ? Colors.lightBlue.shade700 : Colors.lightBlue.shade100;
      case 'gas':
        return isDark ? Colors.orange.shade700 : Colors.orange.shade100;
      case 'electricity':
        return isDark ? Colors.blue.shade700 : Colors.blue.shade100;
      default:
        return isDark ? Colors.amber.shade700 : Colors.amber.shade100;
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
