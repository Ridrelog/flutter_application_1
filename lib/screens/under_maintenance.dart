import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/api_service.dart';
import '../models/status_model.dart';

class UnderMaintenanceScreen extends StatefulWidget {
  const UnderMaintenanceScreen({super.key});

  @override
  State<UnderMaintenanceScreen> createState() =>
      _UnderMaintenanceScreenState();
}

class _UnderMaintenanceScreenState extends State<UnderMaintenanceScreen> {
  late Future<StatusModel> futureStatus;

  @override
  void initState() {
    super.initState();
    futureStatus = ApiService.getMaintenanceStatus();
  }

  void retry() {
    setState(() {
      futureStatus = ApiService.getMaintenanceStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔥 Samakan dengan tema welcome (gradient biru)
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6FB1FF), Color(0xFF4A90E2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<StatusModel>(
            future: futureStatus,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return buildContent(
                  title: "Error",
                  description: "Gagal ambil data",
                );
              }

              final data = snapshot.data!;

              return buildContent(
                title: data.data.title,
                description: data.data.description,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildContent({
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Spacer(),

          // 🔥 Card biar mirip welcome screen
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 200,
                  child: Image.asset(
                    'assets/maintenance.png',
                    fit: BoxFit.contain,
                  )
                ),
                const SizedBox(height: 20),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  description,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 25),

                // 🔥 RETRY BUTTON (biru)
                /*ElevatedButton(
                  onPressed: retry,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF4A90E2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Retry"),
                ),*/

                const SizedBox(height: 10),

                // 🔥 BACK BUTTON
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Back"),
                ),
              ],
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}