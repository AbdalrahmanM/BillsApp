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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: isDark ? const Color(0xFF232323) : Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.headset_mic,
                size: 44,
                color: isDark ? Colors.white : Colors.brown,
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
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // Add your email launch logic here
                },
                icon: const Icon(Icons.email_outlined),
                label: const Text('Contact via Email'),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // Add your WhatsApp launch logic here
                },
                icon: const Icon(Icons.chat_bubble, color: Colors.white),
                label: const Text('Contact via WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                ),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF232323) : const Color(0xFFFAEBD7);
    final cardColor = isDark ? const Color(0xFF2D2D2D) : Colors.white;
    final brown = isDark ? Colors.white : const Color(0xFF8D6E63);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: brown),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.ads,
          style: TextStyle(
            color: brown,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
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
                        color: isDark
                            ? Colors.black.withOpacity(0.10)
                            : Colors.brown.withOpacity(0.10),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showHelpModal(context),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.headset_mic, color: brown, size: 38),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context)!.support,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: brown,
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
                                builder: (context) =>
                                    LoginScreen(localeNotifier: localeNotifier),
                              ),
                              (route) => false,
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.logout_outlined,
                                color: brown,
                                size: 38,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context)!.logout,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: brown,
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
    Key? key,
  }) : super(key: key);

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
