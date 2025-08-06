import 'dart:ui'; // أضف هذا في الأعلى إذا لم يكن موجوداً
import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../main.dart';
import 'package:bills_app/l10n/app_localizations.dart'; // أضف هذا السطر

class AdsPage extends StatelessWidget {
  const AdsPage({super.key});

  void _showHelpModal(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // أيقونة الدعم داخل دائرة
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF8D6E63), // بني ناعم
                    ),
                    padding: const EdgeInsets.all(20),
                    child: const Icon(
                      Icons.headset_mic,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // العنوان
                  Text(
                    "We're Here for You",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF5D4037),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),

                  // الوصف
                  Text(
                    "Our support team is here to assist you at any time.",
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark
                          ? Colors.grey.shade300
                          : const Color(0xFF6D4C41),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // زر البريد الإلكتروني
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Launch email here
                    },
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Contact via Email'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6D4C41),
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

                  // زر واتساب
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Launch WhatsApp here
                    },
                    icon: const Icon(Icons.chat_bubble),
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
                  const SizedBox(height: 20),

                  // زر Send Feedback
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Send Feedback',
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF232323)
          : const Color(0xFFFDE9D9),
      body: Stack(
        children: [
          // الخلفية المغوشة
          Positioned.fill(
            child: Stack(
              children: [
                Image.asset(
                  'lib/assets/building.jpg', // استخدم نفس صورة الخلفية
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
          // محتوى الصفحة
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.04)
                              : Colors.brown.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: isDark
                                ? Colors.brown
                                : const Color(0xFF6D4C41),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.ads,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.lightBlueAccent
                                    : const Color(0xFF0070F3),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 48,
                        ), // لتعويض مساحة الأيقونة من اليمين
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 124.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      padding: const EdgeInsets.all(16),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _AdCard(
                          image: 'lib/assets/music.jpg',
                          title: 'Best Quality Headphones',
                          subtitle: 'Experience music like never before.',
                          details:
                              'هذه السماعات توفر جودة صوت رائعة من تسمعها من قبل!',
                          url: 'https://example.com/headphones',
                        ),
                        _AdCard(
                          image: 'lib/assets/friends.jpg',
                          title: 'Summer Sale is Here!',
                          subtitle: 'Up to 50% off\nselect styles',
                        ),
                        _AdCard(
                          image: 'lib/assets/shopping.jpg',
                          title: 'Latest Arrivals in Store',
                          subtitle: 'Check out the new collection today.',
                        ),
                        _AdCard(
                          image: 'lib/assets/car.jpg',
                          title: 'Drive Away in Your Dream Car',
                          subtitle: 'The best deals are waiting for you.',
                        ),
                      ],
                    ),
                  ),
                ),
                // الشريط السفلي الجديد (مطابق للرئيسية)
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
                              onPressed: () => _showHelpModal(context),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
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
                                    builder: (_) => LoginScreen(
                                      localeNotifier: localeNotifier,
                                    ),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
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
        ],
      ),
    );
  }
}

class _AdCard extends StatefulWidget {
  final String image;
  final String title;
  final String subtitle;
  final String details;
  final String url;

  const _AdCard({
    required this.image,
    required this.title,
    required this.subtitle,
    this.details = '',
    this.url = '',
    super.key,
  });

  @override
  State<_AdCard> createState() => _AdCardState();
}

class _AdCardState extends State<_AdCard> {
  bool _isHovered = false;
  bool _isPressed = false;
  bool _isActive = false; // جديد: لتحديد البطاقة المفتوحة

  Color get _currentColor {
    if (_isActive || _isPressed || _isHovered) {
      return const Color(0xFFD18B4E); // لون مغاير عند الفتح أو الضغط أو التمرير
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF2D2D2D) : Colors.white;
  }

  Color get _currentTextColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white : const Color(0xFF8D6E63);
  }

  void _showAdDetails(BuildContext context) async {
    setState(() => _isActive = true); // عند الفتح يصبح مغاير
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    child: Image.asset(
                      widget.image,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: _currentTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 16,
                            color: _currentTextColor.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (widget.details.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            widget.details,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.brown,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            // افتح الرابط في المتصفح
                          },
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('زيارة الموقع'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: child,
        );
      },
    );
    setState(() => _isActive = false); // عند الإغلاق يعود اللون الطبيعي
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () => _showAdDetails(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _currentColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Image.asset(
                    widget.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: _currentTextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: _currentTextColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
