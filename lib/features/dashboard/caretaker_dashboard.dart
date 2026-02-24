import 'package:flutter/material.dart';
import 'package:frontend/core/logout_helper.dart';
import 'package:frontend/features/dashboard/owner_dashboard.dart';
import 'package:frontend/shared/widgets/action_card.dart';


class CaretakerDashboard extends StatelessWidget {
  const CaretakerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 40),
        child: GlassyAppBar(
          logout: () => logoutUser(context), // ✅ WORKING LOGOUT
        ),
      ),
      body: Stack(
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: kToolbarHeight),
                  _CaretakerHeader(),
                  SizedBox(height: 30),
                  _CaretakerActionGrid(),
                  SizedBox(height: 30),
                  _CaretakerActiveVisits(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaretakerHeader extends StatelessWidget {
  const _CaretakerHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Good morning, Caleb 👋",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "You have 2 active care sessions today.",
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}


class _CaretakerActionGrid extends StatelessWidget {
  const _CaretakerActionGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      children: [
        ActionCard(
          icon: Icons.calendar_today,
          iconColor: Colors.blue,
          title: "My Schedule",
          subtitle: "View upcoming visits",
          onTap: () {},
        ),
        ActionCard(
          icon: Icons.pets,
          iconColor: Colors.green,
          title: "Active Visits",
          subtitle: "Ongoing sessions",
          onTap: () {},
        ),
        ActionCard(
          icon: Icons.description,
          iconColor: Colors.orange,
          title: "Submit Report",
          subtitle: "Add care notes",
          onTap: () {},
        ),
        ActionCard(
          icon: Icons.attach_money,
          iconColor: Colors.purple,
          title: "Earnings",
          subtitle: "Track income",
          onTap: () {},
        ),
      ],
    );
  }
}

class _CaretakerActiveVisits extends StatelessWidget {
  const _CaretakerActiveVisits();

  @override
  Widget build(BuildContext context) {
    return NeumorphicGlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Active Visits",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Max - Home Visit • 2:00 PM",
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 5),
            Text(
              "Care Level: Medium",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}