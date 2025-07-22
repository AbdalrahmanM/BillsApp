import 'package:flutter/material.dart';
import 'package:bills_app/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MockPaymentScreen extends StatefulWidget {
  final double amount;
  final String docId;
  final String billId;
  const MockPaymentScreen({
    super.key,
    required this.amount,
    required this.docId,
    required this.billId,
  });

  @override
  State<MockPaymentScreen> createState() => _MockPaymentScreenState();
}

class _MockPaymentScreenState extends State<MockPaymentScreen>
    with SingleTickerProviderStateMixin {
  String paymentMethod = 'card';
  final cardController = TextEditingController();
  final phoneController = TextEditingController();
  final cardMonthController = TextEditingController();
  final cardYearController = TextEditingController();
  final cardCvvController = TextEditingController();
  bool isLoading = false;
  bool isSuccess = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    cardController.dispose();
    phoneController.dispose();
    cardMonthController.dispose();
    cardYearController.dispose();
    cardCvvController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text(loc.payment), backgroundColor: Colors.brown),
      backgroundColor: isDark
          ? const Color(0xFF232323)
          : const Color(0xFFFAEBD7),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${loc.amount}: ${widget.amount}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Text(
              '${loc.choosePaymentMethod}:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    value: 'card',
                    groupValue: paymentMethod,
                    title: Text(loc.bankCard),
                    activeColor: Colors.brown,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setState(() => paymentMethod = v!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    value: 'zain',
                    groupValue: paymentMethod,
                    title: Text(loc.zainCash),
                    activeColor: Colors.brown,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setState(() => paymentMethod = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (paymentMethod == 'card') ...[
              TextField(
                controller: cardController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: loc.cardNumber,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // شهر الانتهاء
                  Expanded(
                    child: TextField(
                      controller: cardMonthController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'MM',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLength: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // سنة الانتهاء (4 أرقام)
                  Expanded(
                    child: TextField(
                      controller: cardYearController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'YYYY',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLength: 4,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // CVV (3 أرقام)
                  Expanded(
                    child: TextField(
                      controller: cardCvvController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLength: 3,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
            ],
            if (paymentMethod == 'zain')
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: loc.phoneNumber,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            const Spacer(),
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: isLoading
                    ? ScaleTransition(
                        scale: CurvedAnimation(
                          parent: _animController..forward(from: 0),
                          curve: Curves.elasticOut,
                        ),
                        child: const SizedBox(
                          width: 56,
                          height: 56,
                          child: CircularProgressIndicator(
                            color: Colors.brown,
                            strokeWidth: 5,
                          ),
                        ),
                      )
                    : isSuccess
                    ? ScaleTransition(
                        scale: CurvedAnimation(
                          parent: _animController..forward(from: 0),
                          curve: Curves.elasticOut,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 56,
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          key: const ValueKey('payBtn'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 4,
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () async {
                            setState(() => isLoading = true);
                            _animController.forward(from: 0);
                            await Future.delayed(const Duration(seconds: 2));
                            // تحديث حالة الفاتورة في فايربيس
                            await FirebaseFirestore.instance
                                .collection('Users')
                                .doc(widget.docId)
                                .collection('Bills')
                                .doc(widget.billId)
                                .update({'status': 'paid'});
                            setState(() {
                              isLoading = false;
                              isSuccess = true;
                            });
                            _animController.forward(from: 0);
                            await Future.delayed(const Duration(seconds: 1));
                            if (mounted) Navigator.pop(context, true);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.credit_card,
                                        key: ValueKey('icon'),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Text(loc.confirmPayment),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
