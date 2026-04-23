import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'under_maintenance.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF4DA8FF);
  static const Color secondaryBlue = Color(0xFFEAF4FF);

  late final AnimationController _dotsController;
  bool isFinished = false;

  String title = "Preparing your experience";

  @override
  void initState() {
    super.initState();

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    fetchTitle();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => isFinished = true);
      }
    });
  }

  Future<void> fetchTitle() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.ppb.widiarrohman.my.id/api/2026/uts/B/kelompok2/check',
        ),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          title = response.body; // 🔥 FIX DI SINI
        });
      }
    } catch (e) {
      print("ERROR: $e");
    }
  }

  @override
  void dispose() {
    _dotsController.dispose();
    super.dispose();
  }

  Widget buildDots() {
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, child) {
        int count = (_dotsController.value * 3).floor() + 1;
        return Text(
          '.' * count,
          style: const TextStyle(
            fontSize: 18,
            color: primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  void goNext() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, secondaryAnimation) =>
            const UnderMaintenancePage(),
        transitionsBuilder: (_, animation, __, child) {
          final offsetAnimation =
              Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (isFinished && details.primaryVelocity! < 0) {
            goNext();
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [primaryBlue, secondaryBlue, Colors.white],
              stops: [0, 0.4, 1],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text("👋", style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Welcome back",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "User",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Illustration
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: SvgPicture.string(
                    paymentProcessIllistration,
                    height: 220,
                  ),
                ),

                const Spacer(),

                Column(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    isFinished
                        ? const Text(
                            "Ready to go 🚀",
                            style: TextStyle(color: Colors.green),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Loading",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              buildDots(),
                            ],
                          ),
                  ],
                ),

                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      value: isFinished ? 1 : null,
                      backgroundColor: primaryBlue.withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation(primaryBlue),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: isFinished ? 1 : 0,
                  child: isFinished
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ElevatedButton(
                            onPressed: goNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Continue"),
                          ),
                        )
                      : const SizedBox(),
                ),

                const SizedBox(height: 12),

                AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: isFinished ? 1 : 0,
                  child: const Text(
                    "Swipe up to continue ↑",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const paymentProcessIllistration =
    ''' <svg width="1080" height="1080" viewBox="0 0 1080 1080" fill="none" xmlns="http://www.w3.org/2000/svg"> <path d="M590.84 242.27H877.06C880.922 242.27 884.625 243.804 887.355 246.535C890.086 249.265 891.62 252.968 891.62 256.83V543C891.62 546.862 890.086 550.565 887.355 553.295C884.625 556.026 880.922 557.56 877.06 557.56H805.37C744.62 557.56 686.358 533.431 643.397 490.479C600.435 447.527 576.293 389.27 576.28 328.52V256.83C576.28 252.968 577.814 249.265 580.545 246.535C583.275 243.804 586.978 242.27 590.84 242.27Z" fill="#E5E5E5"/> ... </svg> ''';
