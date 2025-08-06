import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/home_screen.dart'; // تأكد من المسار الصحيح
import 'package:bills_app/l10n/app_localizations.dart';
import 'dart:ui'; // مهم للـ ImageFilter

class LoginScreen extends StatefulWidget {
  final ValueNotifier<Locale> localeNotifier;
  const LoginScreen({super.key, required this.localeNotifier});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool rememberInfo = false;
  bool showForm = false;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void toggleForm() {
    setState(() {
      showForm = !showForm;
      if (showForm) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Future<void> handleLogin() async {
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both phone and password")),
      );
      return;
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .get();

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['phone'] == phone && data['password'] == password) {
          String name = data['name'] ?? "User";
          String lastName = data['lastname'] ?? "User";
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                userName: name,
                lastName: lastName,
                docId: doc.id, // ✅ أضف هذا
              ),
            ),
          );
          return;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid phone or password")),
      );
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("An error occurred")));
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
        return Padding(
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
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6D4C41),
                ),
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
                  // TODO: Implement feedback action
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

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'abdodj9425@gmail.com',
      query: 'subject=Support%20Request',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No email app found. Please install or configure an email app.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAEBD7),
      body: Stack(
        children: [
          // صورة الخلفية مع Blur
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Image.asset('lib/assets/building.jpg', fit: BoxFit.cover),
            ),
          ),
          // محتوى الصفحة
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown.withOpacity(0.15),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                    border: Border.all(color: Colors.brown.shade200, width: 4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Image.asset(
                      'lib/assets/building.jpg',
                      height: 160,
                      width: 280,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                AppLocalizations.of(context)!.hello,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.welcomeBack,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: toggleForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: const Color(0xFF1E4FB2),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.login),
                  ),
                ),
              ),
              // Add Get help button before login
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _showHelpModal,
                  child: Text(
                    AppLocalizations.of(context)!.getHelp,
                    style: TextStyle(color: Colors.purple),
                  ),
                ),
              ),
              const SizedBox(height: 44),
            ],
          ),

          // Language Switcher
          Positioned(
            bottom: 20,
            right: 20,
            child: ValueListenableBuilder<Locale>(
              valueListenable: widget.localeNotifier,
              builder: (context, locale, _) {
                return TextButton(
                  onPressed: () {
                    if (locale.languageCode == 'en') {
                      widget.localeNotifier.value = const Locale('ar');
                    } else {
                      widget.localeNotifier.value = const Locale('en');
                    }
                  },
                  child: Text(
                    locale.languageCode == 'en' ? "AR" : "EN",
                    style: const TextStyle(color: Colors.black54),
                  ),
                );
              },
            ),
          ),

          // Sliding Form Panel
          if (showForm)
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: _offsetAnimation,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 30,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: toggleForm,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.phoneNumber,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          )!.enterPhoneNumber,
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.phone, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        AppLocalizations.of(context)!.password,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.enterPassword,
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.lock, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Checkbox(
                            value: rememberInfo,
                            onChanged: (value) {
                              setState(() {
                                rememberInfo = value ?? false;
                              });
                            },
                          ),
                          Text(AppLocalizations.of(context)!.rememberMe),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: handleLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor: const Color(0xFF1E4FB2),
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          child: Text(AppLocalizations.of(context)!.signIn),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: _showHelpModal,
                          child: Text(
                            AppLocalizations.of(context)!.getHelp,
                            style: TextStyle(color: Colors.purple),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Center(child: Text("© 2023")),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
