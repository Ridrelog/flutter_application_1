import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'under_maintenance.dart';
import 'profile_screen.dart';
import '../viewmodels/welcome_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';
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

  @override
  void initState() {
    super.initState();

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchUser();
      fetchTitle();
      startLoading();
    });
  }

  Future<void> fetchTitle() async {
    await context.read<WelcomeViewModel>().fetchTitle();
  }

  Future<void> fetchUser() async {
    await context.read<ProfileViewModel>().fetchProfile();
  }

  void startLoading() async {
    try {
      final request = http.Request(
        'GET',
        Uri.parse('https://api.ppb.widiarrohman.my.id/api/ppb2/stream/logs'),
      );

      final response = await request.send();

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
              if (!isFinished && !isError) {
                setState(() {
                  isError = true;
                  currentLog = "Proses terhenti";
                });
              }
            },
          );
    } catch (e) {
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

  IconData getStatusIcon() {
    if (isError) return Icons.error_rounded;
    if (isFinished) return Icons.check_circle_rounded;
    return Icons.hourglass_top_rounded;
  }

  Color getStatusColor() {
    if (isError) return Colors.red;
    if (isFinished) return Colors.green;
    return primaryBlue;
  }

  @override
  Widget build(BuildContext context) {
    final welcomeViewModel = context.watch<WelcomeViewModel>();
    final profileViewModel = context.watch<ProfileViewModel>();

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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER PROFILE
                  Row(
                    children: [
                       Container(
                          width: 48,
                          height: 48,
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: profileViewModel.imageUrl.isNotEmpty
                                ? Image.network(
                                    profileViewModel.imageUrl,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.person_rounded,
                                    color: primaryBlue,
                                  ),
                          ),
                        ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Selamat Datang kembali",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              profileViewModel.name.isEmpty
                                  ? "Loading..."
                                  : profileViewModel.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.manage_accounts_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 38),

                  // STATUS CHIP
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          getStatusIcon(),
                          size: 17,
                          color: getStatusColor(),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isError
                              ? "Gagal Terhubung ke API"
                              : isFinished
                              ? "Terhubung ke API"
                              : "Tunggu Bentar Ya...",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: getStatusColor(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // TITLE
                  Text(
                    welcomeViewModel.apiTitle.isEmpty
                        ? "Flutter Library Welcome Screen"
                        : welcomeViewModel.apiTitle,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 31,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      height: 1.12,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (welcomeViewModel.apiMessage.isNotEmpty)
                    Text(
                      welcomeViewModel.apiMessage,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.55,
                      ),
                    ),

                  const SizedBox(height: 22),

                  // IMAGE + STATUS CARD
                  Expanded(
                    child: Center(
                      child: Transform.translate(
                        offset: const Offset(0, -70), // <- ini yang bikin naik
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 135,
                                height: 135,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 118,
                                      height: 118,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: primaryBlue.withOpacity(0.08),
                                      ),
                                    ),
                                    Positioned(
                                      right: 10,
                                      top: 16,
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: secondaryBlue.withOpacity(
                                            0.95,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 12,
                                      bottom: 18,
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: primaryBlue.withOpacity(0.14),
                                        ),
                                      ),
                                    ),
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      child: Image.asset(
                                        getCurrentImage(),
                                        key: ValueKey(getCurrentImage()),
                                        height: 120,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: getStatusColor().withOpacity(
                                          0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        getStatusIcon(),
                                        color: getStatusColor(),
                                        size: 25,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            isError
                                                ? "Error"
                                                : isFinished
                                                ? "Ready to go 🚀"
                                                : "Loading",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              color: getStatusColor(),
                                            ),
                                          ),
                                        ),
                                        if (!isFinished && !isError)
                                          buildDots(),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      child: Text(
                                        currentLog.isEmpty
                                            ? "Starting process..."
                                            : currentLog,
                                        key: ValueKey(currentLog),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isError
                                              ? Colors.red
                                              : isFinished
                                              ? Colors.green
                                              : Colors.grey[600],
                                          height: 1.45,
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
                    ),
                  ),

                  const SizedBox(height: 16),

                  // PROGRESS BAR
                  if (!isFinished)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: LinearProgressIndicator(
                        minHeight: 7,
                        value: isError ? 0 : null,
                        backgroundColor: primaryBlue.withOpacity(0.15),
                        valueColor: const AlwaysStoppedAnimation(primaryBlue),
                      ),
                    ),

                  const SizedBox(height: 18),

                  // ERROR BUTTON
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: isError ? 1 : 0,
                    child: isError
                        ? ElevatedButton.icon(
                            onPressed: () async {
                              if (isError) {
                                setState(() {
                                  isError = false;
                                  isFinished = false;
                                  currentLog = "";
                                  title = "Preparing your experience";
                                });

                                await fetchTitle();
                                await fetchUser();
                                startLoading();
                              } else {
                                goNext();
                              }
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(isError ? "Refresh" : "Continue"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isError
                                  ? Colors.red
                                  : primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ),

                  if (isFinished)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.keyboard_arrow_up_rounded,
                              size: 20,
                              color: primaryBlue,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Scroll ke atas untuk melanjutkan",
                              style: TextStyle(
                                fontSize: 12,
                                color: primaryBlue,
                                fontWeight: FontWeight.w700,
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
      ),
    );
  }
}
