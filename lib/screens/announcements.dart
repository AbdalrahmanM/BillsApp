import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:bills_app/l10n/app_localizations.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF232323) : const Color(0xFFFDE9D9);
    final loc = AppLocalizations.of(context)!;

    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // الخلفية المغوشة
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

          // المحتوى بالكامل قابل للتمرير
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    loc.announcements,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.lightBlueAccent
                          : const Color(0xFF0070F3),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // الشبكة القابلة للتكيف
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: [
                      _AnnouncementCard(
                        title: loc.maintenanceNoticeTitle,
                        description: loc.maintenanceNoticeDesc,
                        icon: null,
                        iconColor: null,
                      ),
                      _AnnouncementCard(
                        title: loc.newPaymentOptionTitle,
                        description: loc.newPaymentOptionDesc,
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor: const Color(0xFFBDBDBD),
                      ),
                      _AnnouncementCard(
                        title: loc.specialOfferTitle,
                        description: loc.specialOfferDesc,
                        icon: Icons.percent,
                        iconColor: const Color(0xFFFF8A65),
                      ),
                      _AnnouncementCard(
                        title: loc.holidayAlertTitle,
                        description: loc.holidayAlertDesc,
                        icon: Icons.error_outline,
                        iconColor: const Color(0xFFFFB300),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData? icon;
  final Color? iconColor;

  const _AnnouncementCard({
    required this.title,
    required this.description,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? const Color(0xFF2D2D2D).withOpacity(0.95)
        : Colors.white.withOpacity(0.85);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: textColor,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              description,
              style: TextStyle(fontSize: 14, color: textColor, height: 1.3),
            ),
          ),
          const Spacer(),
          if (icon != null)
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(icon, size: 36, color: iconColor ?? Colors.grey),
            ),
        ],
      ),
    );
  }
}
