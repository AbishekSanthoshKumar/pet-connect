import 'package:flutter/material.dart';
import 'package:frontend/core/logout_helper.dart';
import 'package:frontend/features/dashboard/owner_dashboard.dart';
import 'package:frontend/shared/widgets/action_card.dart';
import 'dart:ui';


class CaretakerDashboard extends StatelessWidget {
  const CaretakerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 40),
        child: GlassyAppBar(
          logout: () => logoutUser(context),
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

class _TrustScoreSection extends StatelessWidget {
  const _TrustScoreSection();

  // Trust score data for caretaker
  static const int _trustScore = 94;
  static const int _totalAssignments = 312;
  static const int _completedAssignments = 298;
  static const int _onTimeCount = 295;
  static const int _frequentClientCount = 78;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Trust Score",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        const SizedBox(height: 20),
        NeumorphicGlassContainer(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Circular Trust Score
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _getTrustScoreColor(_trustScore),
                          width: 5,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_trustScore',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _getTrustScoreColor(_trustScore),
                              ),
                            ),
                            Text(
                              'out of 100',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Score Breakdown",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _ScoreBreakdownItem(
                            label: "Assignment Completion",
                            value: _completedAssignments,
                            total: _totalAssignments,
                            maxPoints: 25,
                          ),
                          const SizedBox(height: 8),
                          _ScoreBreakdownItem(
                            label: "On Time Service",
                            value: _onTimeCount,
                            total: _completedAssignments,
                            maxPoints: 25,
                          ),
                          const SizedBox(height: 8),
                          _ScoreBreakdownItem(
                            label: "Frequent Clients",
                            value: _frequentClientCount,
                            total: 30,
                            maxPoints: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Statistics Row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(label: "Total Jobs", value: "$_totalAssignments"),
                      _StatItem(label: "Completed", value: "$_completedAssignments"),
                      _StatItem(label: "On Time", value: "$_onTimeCount"),
                      _StatItem(label: "Frequent", value: "$_frequentClientCount"),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Tips for improving trust score
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.blue, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getTip(),
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
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
      ],
    );
  }

  String _getTip() {
    // Generate tip based on the lowest score component
    final double completionRate = _completedAssignments / _totalAssignments;
    final double onTimeRate = _onTimeCount / _completedAssignments;
    
    if (completionRate < 0.9) {
      return "Tip: Complete more assignments to improve your trust score!";
    } else if (onTimeRate < 0.95) {
      return "Tip: Try to arrive on time for your appointments!";
    } else if (_frequentClientCount < 30) {
      return "Tip: Build relationships with repeat clients!";
    }
    return "Great job! Maintain your excellent service quality!";
  }

  Color _getTrustScoreColor(int score) {
    if (score >= 95) return Colors.green;
    if (score >= 85) return Colors.blue;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }
}

class _ScoreBreakdownItem extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final double maxPoints;

  const _ScoreBreakdownItem({
    required this.label,
    required this.value,
    required this.total,
    required this.maxPoints,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = total > 0 ? value / total : 0;
    final double points = percentage * maxPoints;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            Text(
              '${points.toStringAsFixed(1)}/$maxPoints',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(
              percentage >= 0.9 ? Colors.green :
              percentage >= 0.7 ? Colors.blue : Colors.orange,
            ),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF57C00),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}
