import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/home_screen.dart'; // تأكد من المسار الصحيح

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Image.asset('lib/assets/friends.png', height: 180),
              const SizedBox(height: 30),
              const Text(
                "Hello",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Welcome back!",
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
                      backgroundColor: const Color(0xFF8B0000),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    child: const Text("LOGIN"),
                  ),
                ),
              ),
              // Add Get help button before login
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _showHelpModal,
                  child: const Text(
                    "Get help",
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
            child: TextButton(
              onPressed: () {},
              child: const Text(
                "EN / AR",
                style: TextStyle(color: Colors.black54),
              ),
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
                      const Text(
                        "Phone number",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: "Enter Phone Number",
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.phone, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        "Password",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: "Enter Password",
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
                          const Text("Remember me"),
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
                            backgroundColor: const Color(0xFF8B0000),
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          child: const Text("SIGN IN"),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: _showHelpModal,
                          child: const Text(
                            "Get help",
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
