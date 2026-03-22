import 'package:flutter/material.dart';
import 'package:frontend/core/logout_helper.dart';
import 'package:frontend/shared/widgets/action_card.dart';
import 'dart:ui';

import 'package:frontend/shared/widgets/glassy_components.dart'; // For GlassyAppBar

// Copy colors from owner_dashboard
const Color _primaryTextColor = Colors.white;
const Color _secondaryTextColor = Colors.white70;
const Color _lightShadowColor = Color.fromARGB(255, 61, 60, 60);
const Color _darkShadowColor = Color.fromARGB(255, 23, 23, 23);

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 40),
        child: GlassyAppBar(
          logout: () => logoutUser(context),
          showEmergency: false,
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
                  const SizedBox(height: kToolbarHeight),
                  const _AdminHeader(),
                  const SizedBox(height: 30),
                  const _AdminStatsGrid(),
                  const SizedBox(height: 30),
  const _AdminActionGrid(),
                  const SizedBox(height: 30),
  const SizedBox(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Admin Dashboard 👨‍💼",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        const Text("Manage bookings, payments & registrations", style: TextStyle(color: Colors.white70)),
      ],
    );
  }
}

class _AdminStatsGrid extends StatelessWidget {
  const _AdminStatsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      children: const [
        _StatCard(title: "Total Bookings", value: "247", icon: Icons.calendar_month, color: Colors.purple),
        _StatCard(title: "Pending", value: "23", icon: Icons.pending, color: Colors.orange),
        _StatCard(title: "Total Revenue", value: "₹1,24,750", icon: Icons.attach_money, color: Colors.green),
        _StatCard(title: "New Registrations", value: "12", icon: Icons.person_add, color: Colors.blue),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
  return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminActionGrid extends StatelessWidget {
  const _AdminActionGrid();

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
          icon: Icons.verified_user,
          iconColor: Colors.blue,
          title: "Verify Vets",
          subtitle: "Approve / Reject vets",
          onTap: () => _showVetApplications(context),
        ),
        ActionCard(
          icon: Icons.home,
          iconColor: Colors.orange,
          title: "Verify Caretakers",
          subtitle: "Approve caretakers",
          onTap: () => _showCaretakerApplications(context),
        ),
        ActionCard(
          icon: Icons.people,
          iconColor: Colors.teal,
          title: "Manage Users",
          subtitle: "Activate / Deactivate",
          onTap: () => _showUsersModal(context),
        ),
        ActionCard(
          icon: Icons.payment,
          iconColor: Colors.green,
          title: "Payments",
          subtitle: "Track payments",
          onTap: () => _showPaymentsModal(context),
        ),
        ActionCard(
          icon: Icons.assignment,
          iconColor: Colors.purple,
          title: "Bookings",
          subtitle: "View all bookings",
          onTap: () {},
        ),
        ActionCard(
          icon: Icons.analytics,
          iconColor: Colors.red,
          title: "Analytics",
          subtitle: "Platform stats",
          onTap: () {},
        ),
      ],
    );
  }
}

void _showVetApplications(BuildContext context) {
  final vetApplications = [
    {"name": "Dr. Sharma", "clinic": "PetCare Clinic", "status": "pending"},
    {"name": "Dr. Anjali", "clinic": "Happy Paws Vet", "status": "pending"},
  ];

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Vet Applications",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          ...vetApplications.map((vet) => ListTile(
                leading: const Icon(Icons.medical_services),
title: Text((vet["name"] as String?) ?? 'Unknown'),
                subtitle: Text((vet["clinic"] as String?) ?? 'N/A'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {},
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}
void _showCaretakerApplications(BuildContext context) {
  final caretakers = [
    {"name": "Rahul", "experience": "3 years"},
    {"name": "Sneha", "experience": "2 years"},
  ];

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _buildModal(
      title: "Caretaker Applications",
      children: caretakers.map((c) => ListTile(
        leading: const Icon(Icons.pets),
        title: Text((c["name"] as String?) ?? 'Unknown'),
        subtitle: Text("Experience: ${(c["experience"] as String?) ?? 'N/A'}"),
        trailing: _actionButtons(),
      )).toList(),
    ),
  );
}
void _showPaymentsModal(BuildContext context) {
  final payments = [
    {"user": "Rahul", "amount": "₹500", "status": "PAID"},
    {"user": "Sneha", "amount": "₹300", "status": "PENDING"},
  ];

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _buildModal(
      title: "Payments",
      children: payments.map((p) => ListTile(
        leading: const Icon(Icons.payment),
title: Text((p["user"] as String?) ?? 'Unknown'),
        subtitle: Text((p["amount"] as String?) ?? 'N/A'),
        trailing: Text(
          p["status"]!,
          style: TextStyle(
            color: p["status"] == "PAID" ? Colors.green : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      )).toList(),
    ),
  );
}
void _showUsersModal(BuildContext context) {
  final users = [
    {"name": "Alex", "role": "OWNER", "active": true},
    {"name": "Dr. John", "role": "VET", "active": false},
  ];

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _buildModal(
      title: "Manage Users",
      children: users.map((user) => ListTile(
        leading: const Icon(Icons.person),
title: Text((user["name"] as String?) ?? 'Unknown'),
        subtitle: Text((user["role"] as String?) ?? 'N/A'),
        trailing: Switch(
          value: user["active"] as bool,
          onChanged: (_) {},
        ),
      )).toList(),
    ),
  );
}
Widget _buildModal({
  required String title,
  required List<Widget> children,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.95),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
    ),
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    ),
  );
}
Widget _actionButtons() {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: const Icon(Icons.check, color: Colors.green),
        onPressed: () {},
      ),
      IconButton(
        icon: const Icon(Icons.close, color: Colors.red),
        onPressed: () {},
      ),
    ],
  );
}