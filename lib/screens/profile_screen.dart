import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primaryBlue = Color(0xFF4DA8FF);
  static const Color secondaryBlue = Color(0xFFEAF4FF);

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<ProfileViewModel>(context, listen: false).fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProfileViewModel>(
        builder: (context, vm, child) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [primaryBlue, secondaryBlue, Colors.white],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // HEADER
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white24,
                          backgroundImage: vm.imageUrl.isNotEmpty
                              ? NetworkImage(vm.imageUrl)
                              : null,
                          child: vm.imageUrl.isEmpty
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),

                        const SizedBox(width: 12),

                        const Text(
                          "User Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // CARD
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
                    child: vm.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: vm.imageUrl.isNotEmpty
                                    ? NetworkImage(vm.imageUrl)
                                    : null,
                                child: vm.imageUrl.isEmpty
                                    ? const Icon(Icons.person, size: 40)
                                    : null,
                              ),

                              Text(
                                vm.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                vm.email,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                  ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Back"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
