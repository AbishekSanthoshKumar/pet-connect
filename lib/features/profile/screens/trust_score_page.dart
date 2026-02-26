import 'dart:ui';
import 'package:flutter/material.dart';

class TrustScorePage extends StatelessWidget {
  final String userType; // 'owner', 'vet', 'caretaker'

  const TrustScorePage({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Trust Score',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
                children: [
                  const SizedBox(height: 40),
                  _TrustScoreCard(
                    score: _getTrustScore(),
                    totalAssignments: _getTotalAssignments(),
                    completedAssignments: _getCompletedAssignments(),
                    onTimeCount: _getOnTimeCount(),
                    frequentClientCount: _getFrequentClientCount(),
                  ),
                  const SizedBox(height: 24),
                  _ScoreBreakdown(
                    trustScore: _getTrustScore(),
                    totalAssignments: _getTotalAssignments(),
                    completedAssignments: _getCompletedAssignments(),
                    onTimeCount: _getOnTimeCount(),
                    frequentClientCount: _getFrequentClientCount(),
                  ),
                  const SizedBox(height: 24),
                  _StatsSection(
                    totalAssignments: _getTotalAssignments(),
                    completedAssignments: _getCompletedAssignments(),
                    onTimeCount: _getOnTimeCount(),
                    frequentClientCount: _getFrequentClientCount(),
                  ),
                  const SizedBox(height: 24),
                  _HowToImproveSection(userType: userType),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getTrustScore() {
    switch (userType) {
      case 'vet':
        return 98;
      case 'caretaker':
        return 94;
      default:
        return 85;
    }
  }

  int _getTotalAssignments() {
    switch (userType) {
      case 'vet':
        return 156;
      case 'caretaker':
        return 312;
      default:
        return 45;
    }
  }

  int _getCompletedAssignments() {
    switch (userType) {
      case 'vet':
        return 152;
      case 'caretaker':
        return 298;
      default:
        return 42;
    }
  }

  int _getOnTimeCount() {
    switch (userType) {
      case 'vet':
        return 148;
      case 'caretaker':
        return 295;
      default:
        return 40;
    }
  }

  int _getFrequentClientCount() {
    switch (userType) {
      case 'vet':
        return 45;
      case 'caretaker':
        return 78;
      default:
        return 15;
    }
  }
}

class _TrustScoreCard extends StatelessWidget {
  final int score;
  final int totalAssignments;
  final int completedAssignments;
  final int onTimeCount;
  final int frequentClientCount;

  const _TrustScoreCard({
    required this.score,
    required this.totalAssignments,
    required this.completedAssignments,
    required this.onTimeCount,
    required this.frequentClientCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF57C00).withOpacity(0.3),
            const Color(0xFF2196F3).withOpacity(0.3),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Score Circle
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 12,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation(
                          _getScoreColor(score),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$score',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(score),
                          ),
                        ),
                        Text(
                          'out of 100',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Trust Score',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Score Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _getScoreColor(score).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getScoreBadgeIcon(score),
                        color: _getScoreColor(score),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getScoreBadgeText(score),
                        style: TextStyle(
                          color: _getScoreColor(score),
                          fontWeight: FontWeight.bold,
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
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 95) return Colors.green;
    if (score >= 85) return Colors.blue;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  IconData _getScoreBadgeIcon(int score) {
    if (score >= 95) return Icons.emoji_events;
    if (score >= 85) return Icons.verified;
    if (score >= 70) return Icons.thumb_up;
    return Icons.warning;
  }

  String _getScoreBadgeText(int score) {
    if (score >= 95) return 'Excellent Provider';
    if (score >= 85) return 'Trusted Provider';
    if (score >= 70) return 'Verified Provider';
    return 'Needs Improvement';
  }
}

class _ScoreBreakdown extends StatelessWidget {
  final int trustScore;
  final int totalAssignments;
  final int completedAssignments;
  final int onTimeCount;
  final int frequentClientCount;

  const _ScoreBreakdown({
    required this.trustScore,
    required this.totalAssignments,
    required this.completedAssignments,
    required this.onTimeCount,
    required this.frequentClientCount,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate breakdown scores (out of 100)
    final double assignmentCompletion = totalAssignments > 0 
        ? (completedAssignments / totalAssignments) * 25 
        : 0;
    final double onTimeScore = completedAssignments > 0 
        ? (onTimeCount / completedAssignments) * 25 
        : 0;
    final double frequentVisits = frequentClientCount >= 30 
        ? 20.0 
        : (frequentClientCount / 30) * 20;
    final double reliability = trustScore - assignmentCompletion - onTimeScore - frequentVisits;
    final double professionalism = reliability > 0 ? reliability * 0.5 : 0;
    final double communication = reliability > 0 ? reliability * 0.5 : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Score Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _ScoreBar(
            label: 'Assignment Completion',
            value: assignmentCompletion,
            maxValue: 25,
            current: completedAssignments,
            total: totalAssignments,
            color: Colors.green,
            icon: Icons.check_circle,
          ),
          const SizedBox(height: 16),
          _ScoreBar(
            label: 'On Time Service',
            value: onTimeScore,
            maxValue: 25,
            current: onTimeCount,
            total: completedAssignments,
            color: Colors.blue,
            icon: Icons.access_time,
          ),
          const SizedBox(height: 16),
          _ScoreBar(
            label: 'Frequent Clients',
            value: frequentVisits,
            maxValue: 20,
            current: frequentClientCount,
            total: 30,
            color: Colors.purple,
            icon: Icons.replay,
          ),
          const SizedBox(height: 16),
          _ScoreBar(
            label: 'Professionalism',
            value: professionalism,
            maxValue: 15,
            color: Colors.teal,
            icon: Icons.star,
          ),
          const SizedBox(height: 16),
          _ScoreBar(
            label: 'Communication',
            value: communication,
            maxValue: 15,
            color: Colors.orange,
            icon: Icons.chat_bubble,
          ),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final int? current;
  final int? total;
  final Color color;
  final IconData icon;

  const _ScoreBar({
    required this.label,
    required this.value,
    required this.maxValue,
    this.current,
    this.total,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = maxValue > 0 ? value / maxValue : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}/$maxValue',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
        if (current != null && total != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '$current / $total',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }
}

class _StatsSection extends StatelessWidget {
  final int totalAssignments;
  final int completedAssignments;
  final int onTimeCount;
  final int frequentClientCount;

  const _StatsSection({
    required this.totalAssignments,
    required this.completedAssignments,
    required this.onTimeCount,
    required this.frequentClientCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: "Total Jobs",
                value: "$totalAssignments",
                icon: Icons.assignment,
                color: Colors.blue,
              ),
              _StatItem(
                label: "Completed",
                value: "$completedAssignments",
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: "On Time",
                value: "$onTimeCount",
                icon: Icons.access_time,
                color: Colors.purple,
              ),
              _StatItem(
                label: "Frequent",
                value: "$frequentClientCount",
                icon: Icons.replay,
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _HowToImproveSection extends StatelessWidget {
  final String userType;

  const _HowToImproveSection({required this.userType});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.blue.withOpacity(0.1),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'How to Improve',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _TipItem(
            icon: Icons.check_circle,
            text: 'Complete all assigned jobs to increase completion rate',
          ),
          const SizedBox(height: 12),
          _TipItem(
            icon: Icons.access_time,
            text: 'Arrive on time for appointments to improve on-time score',
          ),
          const SizedBox(height: 12),
          _TipItem(
            icon: Icons.people,
            text: 'Build relationships with repeat clients for frequent visits',
          ),
          const SizedBox(height: 12),
          _TipItem(
            icon: Icons.chat_bubble,
            text: 'Maintain clear communication with pet owners',
          ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
