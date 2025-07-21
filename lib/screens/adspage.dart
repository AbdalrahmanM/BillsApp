/*import 'package:flutter/material.dart';
import 'login_screen.dart';

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
    final bgColor = const Color(0xFFFAEBD7);
    final cardColor = Colors.white;
    final brown = const Color(0xFF8D6E63);

    return Scaffold(
      backgroundColor: bgColor,
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
                    image: 'lib/assets/headphones.jpg',
                    title: 'Best Quality Headphones',
                    subtitle: 'Experience music like never before.',
                    bgColor: cardColor,
                    textColor: brown,
                  ),
                  _AdCard(
                    image: 'lib/assets/sale.jpg',
                    title: 'Summer Sale is Here!',
                    subtitle: 'Up to 50% off\nselect styles',
                    bgColor: const Color(0xFFD18B4E),
                    textColor: Colors.white,
                  ),
                  _AdCard(
                    image: 'lib/assets/arrivals.jpg',
                    title: 'Latest Arrivals in Store',
                    subtitle: 'Check out the new collection today.',
                    bgColor: cardColor,
                    textColor: brown,
                  ),
                  _AdCard(
                    image: 'lib/assets/car.jpg',
                    title: 'Drive Away in Your Dream Car',
                    subtitle: 'The best deals are waiting for you.',
                    bgColor: cardColor,
                    textColor: brown,
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
                          onTap: () => _showHelpModal(context),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.headset_mic, color: brown, size: 38),
                              const SizedBox(height: 8),
                              Text(
                                'Support',
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
                                color: brown,
                                size: 38,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Logout',
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

class _AdCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color textColor;

  const _AdCard({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
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
                image,
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
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 15,
                    color: textColor.withOpacity(0.8),
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
*/
