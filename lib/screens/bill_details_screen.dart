import 'package:bills_app/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'mock_payment_screen.dart';
import 'package:bills_app/widgets/flushbar_helper.dart';
import 'dart:ui';

class BillDetailsScreen extends StatefulWidget {
  final String type;
  final String docId;

  const BillDetailsScreen({super.key, required this.type, required this.docId});

  @override
  State<BillDetailsScreen> createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends State<BillDetailsScreen> {
  List<Map<String, dynamic>> allBills = [];
  List<Map<String, dynamic>> filteredBills = [];
  bool isLoading = true;
  String selectedStatus = 'all';
  String? selectedMonth;
  String? selectedYear;
  final List<String> monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  List<String> availableYears = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

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
          .where('type', isEqualTo: widget.type)
          .orderBy('year', descending: true)
          .orderBy('month', descending: true)
          .get();

      final bills = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      // Extract unique years from bills
      final years =
          bills.map((b) => b['year']?.toString() ?? '').toSet().toList()
            ..sort();

      setState(() {
        allBills = bills;
        filteredBills = bills;
        availableYears = years;
        isLoading = false;
      });
      // Animate cards in
      if (_listKey.currentState != null) {
        for (int i = 0; i < bills.length; i++) {
          Future.delayed(Duration(milliseconds: 80 * i), () {
            if (_listKey.currentState != null) {
              _listKey.currentState!.insertItem(i);
            }
          });
        }
      }
    } catch (e) {
      print('Error fetching bills: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void applyFilters() {
    List<Map<String, dynamic>> filtered = allBills;

    if (selectedStatus != 'all') {
      filtered = filtered
          .where(
            (bill) =>
                bill['status'].toString().toLowerCase() ==
                selectedStatus.toLowerCase(),
          )
          .toList();
    }

    if (selectedMonth != null) {
      filtered = filtered.where((bill) {
        final monthStr = bill['month']?.toString() ?? '';
        final monthNum = int.tryParse(monthStr);
        // تحقق أن monthNum ليس null وأنه بين 1 و12
        if (monthNum != null && monthNum >= 1 && monthNum <= 12) {
          return monthNames[monthNum - 1] == selectedMonth;
        }
        return false;
      }).toList();
    }

    if (selectedYear != null) {
      filtered = filtered
          .where((bill) => bill['year']?.toString() == selectedYear)
          .toList();
    }

    setState(() {
      filteredBills = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Colors.transparent; // <-- اجعلها شفافة
    final cardColor = isDark ? const Color(0xFF2D2D2D) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF6D4C41);
    final loc = AppLocalizations.of(context)!;
    final title = "${loc.bills} ${_localizedType(context, widget.type)}";
    final theme = ThemeData.light().copyWith(
      scaffoldBackgroundColor: Colors.transparent, // <-- اجعلها شفافة
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            // الخلفية المشوشة (كما هي)
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
            // شريط العنوان الدائري
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 50.0,
                  left: 12.0,
                  right: 12.0,
                  bottom: 12.0,
                ), // <-- هنا التعديل
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
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.brown),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: isDark ? Colors.white : Colors.brown.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // محتوى الصفحة مع padding من الأعلى
            Padding(
              padding: const EdgeInsets.only(
                top: 115,
              ), // حتى لا يغطيه الشريط العلوي
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        // الفلاتر
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.brown.shade700,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  icon: const Icon(Icons.filter_alt_rounded),
                                  label: Text(loc.filter),
                                  onPressed: () async {
                                    await showModalBottomSheet(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                                      ),
                                      backgroundColor: isDark ? cardColor : Colors.white,
                                      builder: (context) {
                                        String tempStatus = selectedStatus;
                                        String? tempMonth = selectedMonth;
                                        String? tempYear = selectedYear;
                                        return StatefulBuilder(
                                          builder: (context, setModalState) => Padding(
                                            padding: const EdgeInsets.all(24.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(loc.filter, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: isDark ? Colors.white : Colors.brown)),
                                                const SizedBox(height: 18),
                                                Text(loc.status, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.brown)),
                                                Wrap(
                                                  spacing: 10,
                                                  children: [
                                                    ChoiceChip(
                                                      label: Text(loc.all),
                                                      selected: tempStatus == 'all',
                                                      onSelected: (_) => setModalState(() => tempStatus = 'all'),
                                                    ),
                                                    ChoiceChip(
                                                      label: Text(loc.paid),
                                                      selected: tempStatus == 'paid',
                                                      onSelected: (_) => setModalState(() => tempStatus = 'paid'),
                                                    ),
                                                    ChoiceChip(
                                                      label: Text(loc.unpaid),
                                                      selected: tempStatus == 'unpaid',
                                                      onSelected: (_) => setModalState(() => tempStatus = 'unpaid'),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 18),
                                                Text(loc.month, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.brown)),
                                                Wrap(
                                                  spacing: 8,
                                                  children: monthNames.map((month) => ChoiceChip(
                                                    label: Text(month),
                                                    selected: tempMonth == month,
                                                    onSelected: (_) => setModalState(() => tempMonth = tempMonth == month ? null : month),
                                                  )).toList(),
                                                ),
                                                const SizedBox(height: 18),
                                                Text(loc.year, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.brown)),
                                                Wrap(
                                                  spacing: 8,
                                                  children: availableYears.map((year) => ChoiceChip(
                                                    label: Text(year),
                                                    selected: tempYear == year,
                                                    onSelected: (_) => setModalState(() => tempYear = tempYear == year ? null : year),
                                                  )).toList(),
                                                ),
                                                const SizedBox(height: 24),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: OutlinedButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                        child: Text(loc.cancel),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.brown,
                                                          foregroundColor: Colors.white,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            selectedStatus = tempStatus;
                                                            selectedMonth = tempMonth;
                                                            selectedYear = tempYear;
                                                            applyFilters();
                                                          });
                                                          Navigator.pop(context);
                                                        },
                                                        child: Text(loc.apply),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Pull-to-refresh and AnimatedList
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              setState(() {
                                isLoading = true;
                              });
                              await fetchBills();
                              applyFilters();
                            },
                            child: filteredBills.isEmpty
                                ? const Center(child: Text("No bills found."))
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: filteredBills.length,
                                    itemBuilder: (context, index) {
                                      final bill = filteredBills[index];
                                      return GestureDetector(
                                        onTap: () =>
                                            _showBillDetailsModal(bill),
                                        child: _buildBillCard(
                                          bill,
                                          Colors.teal,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillCard(Map<String, dynamic> bill, Color color) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isPaid = bill['status']?.toString().toLowerCase() == 'paid';
    final String localizedStatus = isPaid ? loc.paid : loc.unpaid;
    final int? monthIndex = int.tryParse(bill['month'] ?? '') != null
        ? int.parse(bill['month']) - 1
        : null;
    final String monthName =
        (monthIndex != null &&
            monthIndex >= 0 &&
            monthIndex < monthNames.length)
        ? monthNames[monthIndex]
        : bill['month']?.toString() ?? '';
    final String year = bill['year']?.toString() ?? '';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border(
          left: BorderSide(color: isPaid ? Colors.green : Colors.red, width: 6),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPaid ? Colors.green.shade100 : Colors.red.shade100,
          child: Icon(
            isPaid ? Icons.check_circle : Icons.error_outline,
            color: isPaid ? Colors.green : Colors.red,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            localizedStatus,
            style: TextStyle(
              color: isPaid ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  color: isDark ? Colors.brown.shade100 : Colors.brown.shade300,
                  size: 20,
                ),
                Text(
                  "${bill['amount']}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  ":${loc.amount}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.brown,
                  ),
                ),
                if (year.isNotEmpty)
                  Chip(
                    label: Text(
                      year,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.brown,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: isDark
                        ? Colors.brown.shade800
                        : Colors.brown.shade50,
                  ),
                if (year.isNotEmpty && monthName.isNotEmpty)
                  const SizedBox(width: 8), // أضف هذا السطر للفصل بين الشيبس
                if (monthName.isNotEmpty)
                  Chip(
                    label: Text(
                      monthName,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.brown,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: isDark
                        ? Colors.brown.shade800
                        : Colors.brown.shade50,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: isDark ? Colors.brown.shade100 : Colors.brown.shade300,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  // Use localized status here!
                  isPaid ? loc.paid : loc.unpaid,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  " :${loc.status}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: isDark ? Colors.white70 : Colors.brown,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.brown.shade200,
          size: 18,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
    );
  }

  void _showBillDetailsModal(Map<String, dynamic> bill) {
    final loc = AppLocalizations.of(context)!;
    final bool isPaid = bill['status']?.toString().toLowerCase() == 'paid';
    final String localizedStatus = isPaid ? loc.paid : loc.unpaid;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final int? monthIndex = int.tryParse(bill['month'] ?? '') != null
        ? int.parse(bill['month']) - 1
        : null;
    final String monthName =
        (monthIndex != null &&
            monthIndex >= 0 &&
            monthIndex < monthNames.length)
        ? monthNames[monthIndex]
        : bill['month']?.toString() ?? '';
    final String year = bill['year']?.toString() ?? '';

    // استخراج تاريخ الفاتورة
    DateTime? createdAt;
    if (bill['createdAt'] != null) {
      try {
        createdAt = DateTime.parse(bill['createdAt'].toString());
      } catch (_) {}
    }
    // حساب تاريخ الاستحقاق (بعد أسبوع)
    DateTime? dueDate;
    if (bill['dueDate'] != null) {
      if (bill['dueDate'] is Timestamp) {
        dueDate = (bill['dueDate'] as Timestamp).toDate();
      } else if (bill['dueDate'] is String) {
        try {
          dueDate = DateTime.parse(bill['dueDate']);
        } catch (_) {}
      }
    }

    // أضف 7 أيام على dueDate إذا كانت موجودة
    if (dueDate != null) {
      dueDate = dueDate.add(const Duration(days: 7));
    }

    // إذا لم يوجد dueDate استخدم createdAt + 7 أيام
    if (dueDate == null && bill['createdAt'] != null) {
      if (bill['createdAt'] is Timestamp) {
        dueDate = (bill['createdAt'] as Timestamp).toDate().add(
          const Duration(days: 7),
        );
      } else if (bill['createdAt'] is String) {
        try {
          final createdAt = DateTime.parse(bill['createdAt']);
          dueDate = createdAt.add(const Duration(days: 7));
        } catch (_) {}
      }
    }

    // تنسيق التاريخ
    String formattedDueDate = '-';
    if (dueDate != null && dueDate.month >= 1 && dueDate.month <= 12) {
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      formattedDueDate =
          '${dueDate.day} ${months[dueDate.month - 1]} ${dueDate.year}';
    } else {
      formattedDueDate = '-';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark
          ? const Color(0xFF232323)
          : const Color(0xFFFDF6EC),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(
            context,
          ).viewInsets.add(const EdgeInsets.all(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رأس البطاقة
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: isPaid
                        ? (isDark
                              ? Colors.green.shade900
                              : Colors.green.shade100)
                        : (isDark ? Colors.red.shade900 : Colors.red.shade100),
                    child: Icon(
                      isPaid ? Icons.check_circle : Icons.error_outline,
                      color: isPaid ? Colors.green : Colors.red,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizedStatus, // <-- use localized status here
                        style: TextStyle(
                          color: isPaid
                              ? (isDark ? Colors.green.shade200 : Colors.green)
                              : (isDark ? Colors.red.shade200 : Colors.red),
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                  const Spacer(),
                  // Month & Year Chips
                  if (monthName.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(
                          monthName,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.brown,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: isDark
                            ? Colors.brown.shade800
                            : const Color(0xFFEDE0C8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 0,
                        ),
                      ),
                    ),
                  if (year.isNotEmpty)
                    Chip(
                      label: Text(
                        year,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.brown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: isDark
                          ? Colors.brown.shade800
                          : const Color(0xFFEDE0C8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              // Amount
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    color: isDark
                        ? Colors.brown.shade100
                        : Colors.brown.shade300,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${bill['amount']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    " :${loc.amount}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: isDark ? Colors.white70 : Colors.brown,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Status
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: isDark
                        ? Colors.brown.shade100
                        : Colors.brown.shade300,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    // Use localized status here!
                    isPaid ? loc.paid : loc.unpaid,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    " :${loc.status}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: isDark ? Colors.white70 : Colors.brown,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Due Date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: isDark
                        ? Colors.brown.shade100
                        : Colors.brown.shade300,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedDueDate,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    " :${loc.dueDate}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: isDark ? Colors.white70 : Colors.brown,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // أزرار
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final userInfo = await fetchUserInfo();
                        final existing = await FirebaseFirestore.instance
                            .collection('bill_requests')
                            .where('userId', isEqualTo: widget.docId)
                            .where('bill.id', isEqualTo: bill['id'])
                            .get();

                        if (existing.docs.isNotEmpty) {
                          // إشعار أن الطلب مكرر
                          showCustomFlushbar(
                            context,
                            message: AppLocalizations.of(
                              context,
                            )!.billRequestAlreadySent,
                            icon: 'lib/assets/lottie/warning.json',
                            color: Colors.orange,
                          );
                          return;
                        }

                        await FirebaseFirestore.instance
                            .collection('bill_requests')
                            .add({
                              'userId': widget.docId,
                              'userName': userInfo?['firstName'] ?? '',
                              'userLastName': userInfo?['lastName'] ?? '',
                              'userPhone': userInfo?['phone'] ?? '',
                              'bill': bill,
                              'timestamp': FieldValue.serverTimestamp(),
                            });
                        Navigator.pop(context);
                        showCustomFlushbar(
                          context,
                          message: AppLocalizations.of(
                            context,
                          )!.billRequestSent,
                          icon: 'lib/assets/lottie/success.json',
                          color: Colors.green,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green, width: 2),
                        backgroundColor: isDark
                            ? const Color(0xFF232323)
                            : const Color(0xFFFDF6EC),
                        foregroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        loc.requestBill,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isPaid
                          ? null // إذا كانت مدفوعة لا يمكن الدفع
                          : () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MockPaymentScreen(
                                    amount: bill['amount']?.toDouble() ?? 0,
                                    docId: widget.docId,
                                    billId:
                                        bill['id'], // تأكد أن كل فاتورة لديها حقل id يساوي documentId
                                  ),
                                ),
                              );
                              if (result == true) {
                                // يمكنك هنا إعادة تحميل الفواتير أو عرض رسالة نجاح
                                await fetchBills();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: Icon(Icons.credit_card, size: 26), // أيقونة البطاقة
                      label: Text(
                        loc.pay ?? "Pay",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> sendBillRequestEmail({
    required String adminEmail,
    required String userName,
    required String userLastName,
    required String userPhone,
    required Map<String, dynamic> bill,
  }) async {
    // إعداد SMTP (يفضل بريد خاص بالتطبيق)
    final smtpServer = gmail(
      'abdodj9425@gmail.com',
      'Qazwsxedc1',
    ); // غيّرها لاحقاً

    final message = Message()
      ..from = Address('abdodj9425@gmail.com', 'Bills App')
      ..recipients.add(adminEmail)
      ..subject = 'طلب فاتورة من المستخدم $userName $userLastName'
      ..text =
          '''
تم طلب فاتورة جديدة من المستخدم:
الاسم: $userName $userLastName
رقم الهاتف: $userPhone

معلومات الفاتورة:
${bill.entries.map((e) => '${e.key}: ${e.value}').join('\n')}
''';

    try {
      await send(message, smtpServer);
    } catch (e) {
      print('فشل إرسال الإيميل: $e');
      rethrow;
    }
  }

  String _localizedType(BuildContext context, String type) {
    final loc = AppLocalizations.of(context)!;
    switch (type.toLowerCase()) {
      case 'water':
        return loc.water;
      case 'gas':
        return loc.gas;
      case 'electricity':
        return loc.electricity;
      case 'fees':
        return loc.additionalFees;
      default:
        return loc.other;
    }
  }

  Future<Map<String, dynamic>?> fetchUserInfo() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.docId)
          .get();
      return doc.data();
    } catch (e) {
      print('فشل جلب بيانات المستخدم: $e');
      return null;
    }
  }
}
