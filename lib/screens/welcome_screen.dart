import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'under_maintenance.dart';
import 'profile_screen.dart';
import '../services/api_service.dart';

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
  String userName = "";
  String userImage = "";
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    fetchUser();
    fetchTitle();
    startLoading(); // 🔥 pakai API, bukan timer
  }

  // 🔥 API TITLE
  Future<void> fetchTitle() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.ppb.widiarrohman.my.id/api/2026/uts/B/kelompok2/check',
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          title = response.body;
        });
      }
    } catch (e) {
      print("ERROR TITLE: $e");
    }
  }

  Future<void> fetchUser() async {
    try {
      final data = await _apiService.getProfile();

      print("PROFILE DATA: $data");

      setState(() {
        userName = data['data']?['name'] ?? "User";
        userImage = data['data']?['profile_picture'] ?? "";
      });
    } catch (e) {
      print("ERROR: $e");

      setState(() {
        userName = "User";
      });
    }
  }

  // 🔥 STREAM / POLLING API LOGS
  void startLoading() {
    Stream.periodic(const Duration(seconds: 2)).listen((_) async {
      if (isFinished) return; // 🔥 stop kalau sudah selesai

      try {
        final response = await http
            .get(
              Uri.parse(
                'https://api.ppb.widiarrohman.my.id/api/2026/uts/B/kelompok2/logs',
              ),
            )
            .timeout(const Duration(seconds: 5));

        print("STATUS: ${response.statusCode}");

        // 🔥 kalau server respon apapun → anggap selesai
        setState(() {
          isFinished = true;
        });
      } catch (e) {
        print("TIMEOUT / ERROR: $e");

        // 🔥 INI KUNCI UTAMA
        // kalau timeout → berarti proses selesai
        setState(() {
          isFinished = true;
        });
      }
    });
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
            const UnderMaintenanceScreen(),
        transitionsBuilder: (_, animation, _, child) {
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: userImage.isNotEmpty
                                ? Image.network(userImage, fit: BoxFit.cover)
                                : const Icon(Icons.person),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome back",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userName.isEmpty
                                ? "Loading..."
                                : userName, // ✅ VARIABLE
                            style: const TextStyle(
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
                      value: isFinished ? 1 : null, // 🔥 animasi jalan terus
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

const paymentProcessIllistration = r'''
<svg xmlns="http://www.w3.org/2000/svg" width="400" height="400" viewBox="0 0 124 124" fill="none">
<rect width="124" height="124" rx="24" fill="#4DA8FF"/>
<path d="M19.375 36.7818V100.625C19.375 102.834 21.1659 104.625 23.375 104.625H87.2181C90.7818 104.625 92.5664 100.316 90.0466 97.7966L26.2034 33.9534C23.6836 31.4336 19.375 33.2182 19.375 36.7818Z" fill="white"/>
<circle cx="63.2109" cy="37.5391" r="18.1641" fill="#1E3A8A"/>
<rect opacity="0.4" x="81.1328" y="80.7198" width="17.5687" height="17.3876" rx="4" transform="rotate(-45 81.1328 80.7198)" fill="#93C5FD"/>
</svg>
''';
