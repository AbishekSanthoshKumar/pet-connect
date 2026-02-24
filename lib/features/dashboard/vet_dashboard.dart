// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:frontend/shared/widgets/action_card.dart';
import 'owner_dashboard.dart'; // reuse container + appbar
import 'dart:ui';
import 'package:frontend/features/auth/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/logout_helper.dart';

class VetDashboard extends StatelessWidget {
  const VetDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 40),
        child:GlassyAppBar( logout: () => logoutUser(context),
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
                  _VetHeader(),
                  SizedBox(height: 30),
                  _VetActionGrid(),
                  SizedBox(height: 30),
                  _TodayAppointmentsSection(),
                  SizedBox(height: 30),
                  _TrustScoreSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VetHeader extends StatelessWidget {
  const _VetHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Good morning, Dr. Sarah 👩‍⚕️",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "You have 4 appointments today.",
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}

class _VetActionGrid extends StatelessWidget {
  const _VetActionGrid();

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
          icon: Icons.schedule,
          iconColor: Colors.blue,
          title: "Manage Availability",
          subtitle: "Update your schedule",
          onTap: () {},
        ),
        ActionCard(
          icon: Icons.note_alt,
          iconColor: Colors.green,
          title: "Visit Summaries",
          subtitle: "Write treatment notes",
          onTap: () {},
        ),
        ActionCard(
          icon: Icons.folder,
          iconColor: Colors.orange,
          title: "Patient Records",
          subtitle: "View pet history",
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

class _TodayAppointmentsSection extends StatelessWidget {
  const _TodayAppointmentsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Appointments",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        const SizedBox(height: 20),
        NeumorphicGlassContainer(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Max - Vaccination",
                    style: TextStyle(color: Colors.white)),
                SizedBox(height: 5),
                Text("9:00 AM • Medium Care",
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TrustScoreSection extends StatelessWidget {
  const _TrustScoreSection();

  @override
  Widget build(BuildContext context) {
    return NeumorphicGlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Trust Score",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: 0.94,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation(Colors.green),
            ),
            SizedBox(height: 5),
            Text("94 / 100",
                style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

