import 'package:flutter/material.dart';
import 'package:frontend/features/auth/screens/login_screen.dart';
import 'package:frontend/features/booking/screens/booking_page.dart';
import 'package:frontend/features/booking/screens/my_bookings_page.dart';
import 'package:frontend/features/pets/screens/pet_management_page.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/shared/widgets/glassy_components.dart';
import 'package:frontend/shared/widgets/action_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color _primaryTextColor = Colors.white;
const Color _secondaryTextColor = Colors.white70;

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({Key? key}) : super(key: key);

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  String userName = "User";
  int userId = 0;
  List<dynamic> pets = [];
  bool isLoading = true;

  int _caretakerBookings = 0;
  int _vetBookings = 0;
  int _emergencyBookings = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    userId = prefs.getInt("user_id") ?? 0;
    userName = prefs.getString("name") ?? "User";

    try {
      final data = await ApiService.getPets(userId);
      final bookingData = await ApiService.getBookings(userId);

      int ctCount = 0;
      int vCount = 0;
      int emCount = 0;

      for (var b in bookingData) {
        if (b["status"] == "emergency" || b["isEmergency"] == true) {
          emCount++;
        }
        final String pType = (b["provider"]?["type"] ?? "")
            .toString()
            .toLowerCase();
        if (pType == "caretaker") {
          ctCount++;
        } else if (pType == "vet" || pType == "veterinarian") {
          vCount++;
        }
      }

      setState(() {
        pets = data;
        _caretakerBookings = ctCount;
        _vetBookings = vCount;
        _emergencyBookings = emCount;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
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
                              GestureDetector(
                                child: Wrap(
                                  children: [
                                    Text(
                                      "Welcome $userName 👋",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            color: _primaryTextColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
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
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              fixedSize: Size(
                                MediaQuery.of(context).size.width * 0.8,
                                30,
                              ),
                            ),
                            onPressed: () => _logout(context),
                            child: Text("Logout"),
                          ),
                        ),
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
        ActionCard(
          icon: Icons.search,
          iconColor: Colors.orange,
          title: "Find Specialists",
          subtitle: "Vets & Caretakers",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BookingPage()),
            );
          },
        ),
        ActionCard(
          icon: Icons.add,
          iconColor: Colors.green,
          title: "Add Pet",
          subtitle: "Manage pets",
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PetManagementPage(),
              ),
            );
            loadData();
          },
        ),
        ActionCard(
          icon: Icons.schedule,
          iconColor: Colors.blue,
          title: "Bookings",
          subtitle:
              "$_caretakerBookings Care • $_vetBookings Vet • $_emergencyBookings ER",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyBookingsPage()),
            );
          },
        ),
        ActionCard(
          icon: Icons.flash_on,
          iconColor: Colors.red,
          title: "Emergency",
          subtitle: "Quick help",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BookingPage(isEmergencyMode: true),
              ),
            );
          },
        ),
      ],
    );
  }
}

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

          String imagePath =
              (pet['type'] ?? 'dog').toString().toLowerCase() == 'cat'
              ? 'assets/images/pet-cat.jpg'
              : 'assets/images/pet-dog.jpg';

          return NeumorphicGlassContainer(
            width: 250,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5),
                    BlendMode.darken,
                  ),
                ),
              ),
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
            ),
          );
        },
      ),
    );
  }
}

//devananda
//franky
//caleb
