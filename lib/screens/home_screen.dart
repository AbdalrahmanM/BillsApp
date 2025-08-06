import 'package:bills_app/l10n/app_localizations.dart'; // أضف هذا السطر
import 'package:bills_app/main.dart'; // Make sure this import is present
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/login_screen.dart'; // <-- Add this import for navigation
import 'bill_details_screen.dart'; // تأكد من وجود هذه الصفحة
import 'theme_controller.dart'; // import your controller
import 'announcements.dart';
import 'adspage.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart'; // أضف هذا السطر في الأعلى

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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withOpacity(0.4)
                    : Colors.white.withOpacity(0.6),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // أيقونة
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF8D6E63),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: const Icon(
                      Icons.headset_mic,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 18),
                  // العنوان (مترجم)
                  Text(
                    AppLocalizations.of(context)!.supportTitle,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF5D4037),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  // الوصف (مترجم)
                  Text(
                    AppLocalizations.of(context)!.supportDesc,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark
                          ? Colors.grey.shade300
                          : const Color(0xFF6D4C41),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // زر البريد (مترجم)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _launchEmail();
                    },
                    icon: const Icon(Icons.email_outlined),
                    label: Text(AppLocalizations.of(context)!.contactEmail),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6D4C41),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // زر واتساب (مترجم)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _launchWhatsApp();
                    },
                    icon: const Icon(Icons.chat_bubble),
                    label: Text(AppLocalizations.of(context)!.contactWhatsApp),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.getHelp,
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade300
                            : const Color(0xFF6D4C41),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
      body: SafeArea(
        child: Stack(
          children: [
            // الخلفية المشوشة
            Positioned.fill(
              child: Stack(
                children: [
                  Image.asset(
                    'lib/assets/building.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(color: Colors.white.withOpacity(0.12)),
                  ),
                ],
              ),
            ),
            // الشريط العلوي المخصص
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 12.0,
                ),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.18)
                        : Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(
                        Icons.dashboard,
                        color: Colors.brown.shade700,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Billing Hub",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: isDark ? Colors.white : Colors.brown.shade700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Theme.of(context).brightness == Brightness.dark
                              ? Icons.light_mode
                              : Icons.dark_mode,
                          color: isDark ? Colors.white : Colors.brown.shade700,
                        ),
                        onPressed: () {
                          final isDark =
                              Theme.of(context).brightness == Brightness.dark;
                          themeController.setTheme(
                            isDark ? ThemeMode.light : ThemeMode.dark,
                          );
                          setState(() {});
                        },
                        tooltip: Theme.of(context).brightness == Brightness.dark
                            ? 'Switch to Light Mode'
                            : 'Switch to Dark Mode',
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
            // باقي محتوى الصفحة (PageView وغيره)
            Padding(
              padding: const EdgeInsets.only(
                top: 84.0,
              ), // حتى لا يغطي الشريط العلوي
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PageView(
                      children: [
                        _buildBillsPage(isDark),
                        const AnnouncementsScreen(),
                      ],
                    ),
            ),
            // الشريط السفلي كما هو
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 18.0,
                  left: 12.0,
                  right: 12.0,
                ),
                child: Container(
                  width: double.infinity,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFFFAFAFA).withOpacity(0.10)
                        : Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // زر الدعم
                      Expanded(
                        child: TextButton.icon(
                          onPressed: _showHelpModal,
                          icon: Icon(
                            Icons.headset_mic,
                            color: Colors.brown.shade700,
                          ),
                          label: Text(
                            AppLocalizations.of(context)!.support,
                            style: TextStyle(
                              color: Colors.brown.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.brown.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // زر تسجيل الخروج
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    LoginScreen(localeNotifier: localeNotifier),
                              ),
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: Text(
                            AppLocalizations.of(context)!.logout,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
    final cardTextColor = isDark ? Colors.white : const Color(0xFF6D4C41);
    final cardSubTextColor = isDark ? Colors.brown.shade100 : Colors.grey;
    final cardBgColors = [
      isDark ? Colors.lightBlue.shade700 : Colors.lightBlue.shade100,
      isDark ? Colors.orange.shade700 : Colors.orange.shade100,
      isDark ? Colors.blue.shade700 : Colors.blue.shade100,
      isDark ? Colors.amber.shade700 : Colors.amber.shade100,
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // بطاقة الترحيب
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.brown.shade100,
                  child: Icon(
                    Icons.person,
                    color: Colors.brown.shade700,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${AppLocalizations.of(context)!.hello}, ${widget.userName} ${widget.lastName}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: cardTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.welcomeBack,
                        style: TextStyle(fontSize: 15, color: cardSubTextColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // بطاقة الإعلانات
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdsPage()),
              );
            },
            child: Container(
              height: 110,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                image: const DecorationImage(
                  image: AssetImage('lib/assets/ads.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: kReleaseMode
                        ? BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                            child: Container(
                              color: Colors.black.withOpacity(0.25),
                              alignment: Alignment.center,
                              child: Text(
                                'Ads',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black45,
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.black.withOpacity(0.10),
                            alignment: Alignment.center,
                            child: Text(
                              'Ads',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // شبكة البطاقات الأربع
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildFromData('water', isDark),
                _buildFromData('gas', isDark),
                _buildFromData('electricity', isDark),
                _buildFromData('fees', isDark),
              ],
            ),
          ),
          const SizedBox(
            height: 110,
          ), // مساحة للأسفل حتى لا يغطيها البار السفلي
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
        _translateType(type),
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
        return AppLocalizations.of(context)!.water;
      case 'gas':
        return AppLocalizations.of(context)!.gas;
      case 'electricity':
        return AppLocalizations.of(context)!.electricity;
      case 'fees':
        return AppLocalizations.of(context)!.additionalFees;
      default:
        return AppLocalizations.of(context)!.other;
    }
  }
}
