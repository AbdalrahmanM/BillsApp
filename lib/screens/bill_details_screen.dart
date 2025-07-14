import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  String selectedStatus = 'All';
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

      final bills = snapshot.docs.map((doc) => doc.data()).toList();
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

    if (selectedStatus != 'All') {
      filtered = filtered
          .where(
            (bill) =>
                bill['status'].toString().toLowerCase() ==
                selectedStatus.toLowerCase(),
          )
          .toList();
    }

    if (selectedMonth != null) {
      filtered = filtered
          .where(
            (bill) =>
                int.tryParse(bill['month'] ?? '') != null &&
                monthNames[int.parse(bill['month']) - 1] == selectedMonth,
          )
          .toList();
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
    final title = _translateType(widget.type);
    final theme = ThemeData.light().copyWith(
      scaffoldBackgroundColor: const Color(0xFFFDF6EC),
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(title: Text('$title Bills')),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Filters
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            value: selectedStatus,
                            isExpanded: true,
                            items: ['All', 'Paid', 'Unpaid']
                                .map(
                                  (status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedStatus = value;
                                  applyFilters();
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButton<String>(
                            hint: const Text("Month"),
                            value: selectedMonth,
                            isExpanded: true,
                            items: monthNames
                                .map(
                                  (month) => DropdownMenuItem(
                                    value: month,
                                    child: Text(month),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedMonth = value;
                                applyFilters();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButton<String>(
                            hint: const Text("Year"),
                            value: selectedYear,
                            isExpanded: true,
                            items: availableYears
                                .map(
                                  (year) => DropdownMenuItem(
                                    value: year,
                                    child: Text(year),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedYear = value;
                                applyFilters();
                              });
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
                          : AnimatedList(
                              key: _listKey,
                              initialItemCount: filteredBills.length,
                              padding: const EdgeInsets.all(16),
                              itemBuilder: (context, index, animation) {
                                final bill = filteredBills[index];
                                return SizeTransition(
                                  sizeFactor: animation,
                                  axis: Axis.vertical,
                                  child: GestureDetector(
                                    onTap: () => _showBillDetailsModal(bill),
                                    child: _buildBillCard(bill, Colors.teal),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBillCard(Map<String, dynamic> bill, Color color) {
    final bool isPaid = bill['status']?.toString().toLowerCase() == 'paid';
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
            "${isPaid ? 'Paid' : 'Unpaid'}",
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
                  color: Colors.brown.shade300,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  "${bill['amount']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Chip(
                  label: Text(monthName),
                  backgroundColor: Colors.brown.shade50,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (year.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Chip(
                    label: Text(year),
                    backgroundColor: Colors.brown.shade50,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.brown.shade300,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  "Status: ${bill['status']}",
                  style: const TextStyle(fontSize: 15),
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
    final bool isPaid = bill['status']?.toString().toLowerCase() == 'paid';
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

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Theme.of(context).cardColor,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isPaid
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    child: Icon(
                      isPaid ? Icons.check_circle : Icons.error_outline,
                      color: isPaid ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isPaid ? 'Paid' : 'Unpaid',
                    style: TextStyle(
                      color: isPaid ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(monthName),
                    backgroundColor: Colors.brown.shade50,
                  ),
                  if (year.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Chip(
                      label: Text(year),
                      backgroundColor: Colors.brown.shade50,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Icon(Icons.attach_money, color: Colors.brown.shade300),
                  const SizedBox(width: 8),
                  Text(
                    'Amount: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${bill['amount']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.brown.shade300),
                  const SizedBox(width: 8),
                  Text(
                    'Status: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${bill['status']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (bill['note'] != null &&
                  bill['note'].toString().isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.sticky_note_2_outlined,
                      color: Colors.brown.shade300,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Note: ${bill['note']}',
                        style: const TextStyle(fontSize: 16),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.brown.shade300,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Created: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    bill['createdAt'] != null
                        ? bill['createdAt'].toString()
                        : '-',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
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
