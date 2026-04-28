import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'under_maintenance.dart';
import 'profile_screen.dart';
import '../services/api_service.dart';
import 'dart:convert';

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
  bool isError = false;
  String getCurrentImage() {
    if (isError) return "assets/error.jpg";
    if (isFinished) return "assets/success.jpg";
    return "assets/loading.jpg";
  }

  String title = "Preparing your experience";
  String currentLog = "";
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
        final jsonData = jsonDecode(response.body);

        setState(() {
          title = jsonData['data']?['title'] ?? "No Title";
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
  void startLoading() async {
    try {
      final request = http.Request(
        'GET',
        Uri.parse('https://api.ppb.widiarrohman.my.id/api/ppb2/stream/logs'),
      );

      final response = await request.send();

      // ❗ kalau status bukan 200
      if (response.statusCode != 200) {
        setState(() {
          isError = true;
          currentLog = "Gagal terhubung ke server";
        });
        return;
      }

      response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              print("RAW: $line");

              if (line.startsWith("data: ")) {
                final message = line.replaceFirst("data: ", "");

                setState(() {
                  currentLog = message;
                });

                if (message.toLowerCase().contains("selesai")) {
                  setState(() {
                    isFinished = true;
                  });
                }
              }
            },
            onError: (e) {
              setState(() {
                isError = true;
                currentLog = "Gagal terhubung ke server";
              });
            },
            onDone: () {
              // kalau stream berhenti tapi belum selesai
              if (!isFinished && !isError) {
                setState(() {
                  isError = true;
                  currentLog = "Proses terhenti";
                });
              }
            },
          );
    } catch (e) {
      // ❗ kalau API mati / tidak bisa connect
      setState(() {
        isError = true;
        currentLog = "Gagal terhubung ke server";
      });
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Image.asset(
                      getCurrentImage(),
                      key: ValueKey(getCurrentImage()),
                      height: 220,
                    ),
                  ),
                ),

                const Spacer(),

                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isError
                              ? "Error"
                              : isFinished
                              ? "Ready to go 🚀"
                              : "Loading",
                          style: TextStyle(
                            color: isError
                                ? Colors.red
                                : isFinished
                                ? Colors.green
                                : Colors.grey[600],
                          ),
                        ),
                        if (!isFinished && !isError) buildDots(),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 🔥 SELALU TAMPIL LOG DARI API
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        currentLog,
                        key: ValueKey(currentLog),
                        style: TextStyle(
                          fontSize: 13,
                          color: isError
                              ? Colors.red
                              : isFinished
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: (isFinished)
                        ? const SizedBox() // ❌ hilang kalau selesai
                        : LinearProgressIndicator(
                            minHeight: 6,
                            value: isError ? 0 : null,
                            backgroundColor: primaryBlue.withOpacity(0.15),
                            valueColor: const AlwaysStoppedAnimation(
                              primaryBlue,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: isError ? 1 : 0, // ❗ hanya muncul saat error
                  child: isError
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (isError) {
                                setState(() {
                                  isError = false;
                                  isFinished = false;
                                  currentLog = "";
                                  title =
                                      "Preparing your experience"; // reset juga biar UX enak
                                });

                                await fetchTitle(); // ✅ refresh title dari API
                                await fetchUser(); // (opsional, kalau mau update user juga)
                                startLoading(); // lanjut stream lagi
                              } else {
                                goNext();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isError
                                  ? Colors.red
                                  : primaryBlue,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(isError ? "Retry" : "Continue"),
                          ),
                        )
                      : const SizedBox(),
                ),

                const SizedBox(height: 12),

                AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: isFinished ? 1 : 0, // ❗ hanya muncul kalau sukses
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
