// ignore_for_file: unused_element

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/config/api_config.dart';
import 'package:frontend/features/auth/screens/login_screen.dart';
import 'package:frontend/features/booking/screens/booking_page.dart';
import 'package:frontend/features/booking/screens/my_bookings_page.dart';
import 'package:frontend/features/pets/screens/pet_management_page.dart';
import 'package:frontend/shared/widgets/glassy_components.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// --- Colors ---
const Color _primaryTextColor = Colors.white;
const Color _secondaryTextColor = Colors.white70;
const MaterialColor _accentColor = Colors.orange;

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({Key? key}) : super(key: key);

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  String userName = "User";
  List<dynamic> pets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/api/login"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        userName = prefs.getString("name") ?? "User";
        pets = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 40),
        child: GlassyAppBar(logout: () => _logout(context)),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/nature-bg.jpg"),
                fit: BoxFit.cover,
                opacity: 0.5,
              ),
              color: Colors.black,
            ),
          ),
          SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: kToolbarHeight),

                        /// HEADER
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome back, $userName 👋",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: _primaryTextColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Manage your pets and bookings",
                                style: TextStyle(color: _secondaryTextColor),
                              ),
                              const SizedBox(height: 30),
                              _buildActionGrid(context),
                              const SizedBox(height: 30),

                              /// PET SECTION
                              const Text(
                                "My Pets",
                                style: TextStyle(
                                  color: _primaryTextColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        pets.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    "No pets added yet",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                              )
                            : _MyPetsSection(pets: pets),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _ActionCard(
          icon: Icons.search,
          title: "Find Care",
          backgroundAsset: "assets/images/find-care.jpg",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookingPage()),
            );
          },
        ),
        _ActionCard(
          icon: Icons.add,
          title: "Add Pet",
          backgroundAsset: "assets/images/pet-dog.jpg",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PetManagementPage()),
            );
          },
        ),
        _ActionCard(
          icon: Icons.schedule,
          title: "Bookings",
          backgroundAsset: "assets/images/dog_and_cat.jpg",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyBookingsPage()),
            );
          },
        ),
        _ActionCard(
          icon: Icons.flash_on,
          title: "Emergency",
          backgroundAsset: "assets/images/nature-bg.jpg",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const BookingPage(isEmergencyMode: true)),
            );
          },
        ),
      ],
    );
  }
}

/* ================= PET SECTION ================= */

class _MyPetsSection extends StatelessWidget {
  final List<dynamic> pets;

  const _MyPetsSection({required this.pets});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];

          return NeumorphicGlassContainer(
            width: 250,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet['name'] ?? '',
                    style: const TextStyle(
                      color: _primaryTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    pet['breed'] ?? '',
                    style: const TextStyle(color: _secondaryTextColor),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    pet['type'] ?? '',
                    style: const TextStyle(color: _secondaryTextColor),
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

/* ================= ACTION CARD ================= */

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? backgroundAsset;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.backgroundAsset,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicGlassContainer(
      image: backgroundAsset != null
          ? DecorationImage(
              image: AssetImage(backgroundAsset!),
              fit: BoxFit.cover,
              opacity: 0.5,
            )
          : null,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}