import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/features/auth/screens/login_screen.dart';
import 'package:frontend/features/booking/screens/booking_page.dart';
import 'package:frontend/features/booking/screens/my_bookings_page.dart';
import 'package:frontend/features/pets/screens/pet_management_page.dart';
import 'package:frontend/shared/widgets/glassy_components.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Custom Dark Color Palette ---
const Color _primaryTextColor = Colors.white;
const Color _secondaryTextColor = Colors.white70;
const MaterialColor _accentColor = Colors.orange;
const Color _containerColor = Color.fromARGB(255, 43, 42, 42);
const Color _lightShadowColor = Color.fromARGB(255, 61, 60, 60);
const Color _darkShadowColor = Color.fromARGB(255, 23, 23, 23);

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 40),
        child: GlassyAppBar(logout: () => _logout(context)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/nature-bg.jpg"),
                    opacity: 0.5,
                    fit: BoxFit.cover,
                  ),
                  color: Colors.black,
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: kToolbarHeight),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome back, Alex! 👋",
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _primaryTextColor,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Your pets are doing great. Here's what's happening.",
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: _secondaryTextColor),
                            ),
                            const SizedBox(height: 30),
                            _buildActionGrid(context, constraints),
                            const SizedBox(height: 30),
                            _buildSectionHeader(
                              context,
                              title: "My Pets",
                              actionText: "Add Pet",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const _MyPetsSection(),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              context,
                              title: "Upcoming Bookings",
                              actionText: "View All",
                            ),
                            const SizedBox(height: 20),
                            const _BookingsSection(),
                            const SizedBox(height: 30),
                            _buildSectionHeader(
                              context,
                              title: "Recent Activity",
                            ),
                            const SizedBox(height: 20),
                            const _RecentActivitySection(),
                            const SizedBox(height: 30),
                            const _DidYouKnowSection(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context, BoxConstraints constraints) {
    final bool isDesktop = constraints.maxWidth > 800;
    return GridView.count(
      crossAxisCount: isDesktop ? 4 : 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isDesktop ? 1.2 : 1,
      children: [
        _ActionCard(
          icon: Icons.search,
          iconColor: Colors.blue,
          title: "Find Care",
          subtitle: "Book a vet or caretaker",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookingPage()),
            );
          },
        ),
        _ActionCard(
          icon: Icons.add,
          iconColor: Colors.green,
          title: "Add Pet",
          subtitle: "Register a new pet",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PetManagementPage()),
            );
          },
        ),
        _ActionCard(
          icon: Icons.schedule,
          iconColor: _accentColor,
          title: "Schedule",
          subtitle: "View all bookings",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyBookingsPage()),
            );
          },
        ),
        _ActionCard(
          icon: Icons.flash_on,
          iconColor: Colors.red,
          title: "Emergency",
          subtitle: "Get help now",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookingPage(isEmergencyMode: true)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    String? actionText,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: _primaryTextColor,
          ),
        ),
        if (actionText != null)
          TextButton(
            onPressed: () {},
            child: const Text(
              "View All",
              style: TextStyle(
                color: _accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

class GlassyAppBar extends StatelessWidget {
  final VoidCallback logout;
  final bool showEmergency;

  const GlassyAppBar({required this.logout, this.showEmergency = true, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 10,
      ).copyWith(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: _darkShadowColor.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(4, 4),
          ),
        ],
        border: Border.all(
          color: _lightShadowColor.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.pets, color: _accentColor.shade300, size: 30),
                    const SizedBox(width: 8),
                    const Text(
                      "PetConnect",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _primaryTextColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showEmergency)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const BookingPage(isEmergencyMode: true)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: isMobile
                              ? const EdgeInsets.all(8)
                              : const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.flash_on,
                              color: Colors.white,
                              size: 16,
                            ),
                            if (!isMobile) ...[
                              const SizedBox(width: 4),
                              const Text(
                                "Emergency",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ],
                        ),
                      ),
                    if (showEmergency) const SizedBox(width: 10),
                    _AppBarIcon(
                      icon: Icons.notifications_none,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 10),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'logout') {
                          logout();
                        }
                      },
                      color: _containerColor,
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'logout',
                              child: Text(
                                'Logout',
                                style: TextStyle(color: _primaryTextColor),
                              ),
                            ),
                          ],
                      child: const CircleAvatar(
                        backgroundImage: AssetImage(
                          'assets/images/dog_and_cat.jpg',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AppBarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _AppBarIcon({required this.icon, required this.onPressed, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeumorphicGlassContainer(
      width: 40,
      height: 40,
      child: InkWell(
        onTap: onPressed,
        child: Icon(icon, color: _secondaryTextColor, size: 24),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeumorphicGlassContainer(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyPetsSection extends StatelessWidget {
  const _MyPetsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> pets = [
      {
        'name': 'Max',
        'type': 'Golden Retriever',
        'age': '4',
        'next_visit': 'Feb 15, 2026',
        'care': 'medium care',
        'status': 'Healthy',
      },
      {
        'name': 'Luna',
        'type': 'Persian',
        'age': '2',
        'next_visit': 'Mar 3, 2026',
        'care': 'low care',
        'status': 'Healthy',
      },
    ];

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];
          return NeumorphicGlassContainer(
            image: DecorationImage(
              image: AssetImage(
                index % 2 == 0
                    ? "assets/images/pet-dog.jpg"
                    : "assets/images/pet-cat.jpg",
              ),
              opacity: 0.5,
              colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
              fit: BoxFit.cover,
            ),
            width: 300,
            margin: const EdgeInsets.only(right: 16, left: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pet['name']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _primaryTextColor,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.health_and_safety_outlined,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            pet['status']!,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${pet['type']!} • ${pet['age']!} years",
                    style: const TextStyle(color: _secondaryTextColor),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: _secondaryTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Next: ${pet['next_visit']!}",
                        style: const TextStyle(color: _secondaryTextColor),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          pet['care']!,
                          style: const TextStyle(
                            color: _accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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

class _BookingsSection extends StatelessWidget {
  const _BookingsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> bookings = [
      {
        'pet': 'Max',
        'type': 'Vet Visit',
        'date': 'Feb 15, 2026',
        'time': '10:00 AM',
        'doctor': 'Dr. Sarah Chen',
        'rating': '94',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return NeumorphicGlassContainer(
          margin: const EdgeInsets.only(bottom: 20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${booking['type']!} for ${booking['pet']!}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _primaryTextColor,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MyBookingsPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _containerColor,
                        foregroundColor: _primaryTextColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: _lightShadowColor.withOpacity(0.5),
                          ),
                        ),
                      ),
                      child: const Text("Details"),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      booking['doctor']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _primaryTextColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        booking['rating']!,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: _secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      booking['date']!,
                      style: const TextStyle(color: _secondaryTextColor),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: _secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      booking['time']!,
                      style: const TextStyle(color: _secondaryTextColor),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> activities = [
      {
        'icon': Icons.check_circle,
        'color': Colors.green,
        'title': "Luna's grooming session completed",
        'time': '2 hours ago',
      },
      {
        'icon': Icons.arrow_upward,
        'color': Colors.blue,
        'title': "Dr. Chen's trust score increased to 94",
        'time': '1 day ago',
      },
      {
        'icon': Icons.warning_amber_rounded,
        'color': _accentColor,
        'title': "Max's vaccination due in 2 weeks",
        'time': '2 days ago',
      },
    ];

    return Column(
      spacing: 10,
      children: activities
          .map(
            (activity) => NeumorphicGlassContainer(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Icon(activity['icon'], color: activity['color']),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: _primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activity['time'],
                            style: const TextStyle(
                              color: _secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.more_horiz,
                      color: _secondaryTextColor.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DidYouKnowSection extends StatelessWidget {
  const _DidYouKnowSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeumorphicGlassContainer(
      color: _containerColor.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: _accentColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Did you know?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Providers with higher trust scores are matched first for emergency requests. Keep your pet's profile updated for better matches!",
                    style: TextStyle(color: _secondaryTextColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

