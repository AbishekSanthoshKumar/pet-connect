import 'package:flutter/material.dart';
import 'package:frontend/shared/widgets/action_card.dart';
import 'package:frontend/features/auth/screens/login_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool isLoading = true;
  List<dynamic> allBookings = [];
  List<dynamic> users = [];
  List<dynamic> vets = [];
  List<dynamic> caretakers = [];
  List<dynamic> payments = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      allBookings = await ApiService.getAllBookings();
      users = await ApiService.getUsers();
      vets = await ApiService.getVets();
      caretakers = await ApiService.getCaretakers();
      payments = await ApiService.getPayments();

      setState(() => isLoading = false);
    } catch (e) {
      print("Error loading admin data: $e");
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
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFF57C00)),
        ),
      );
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
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
                  _AdminActionGrid(
                    allBookings: allBookings,
                    vets: vets,
                    caretakers: caretakers,
                    users: users,
                    payments: payments,
                    onRefresh: loadData,
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        fixedSize: Size(
                          MediaQuery.of(context).size.width * 0.8,
                          50,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _logout(context),
                      child: const Text(
                        "Logout",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Admin Portal 👨‍💼",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text("Manage app operations", style: TextStyle(color: Colors.white70)),
      ],
    );
  }
}

class _AdminActionGrid extends StatelessWidget {
  final List<dynamic> allBookings;
  final List<dynamic> vets;
  final List<dynamic> caretakers;
  final List<dynamic> users;
  final List<dynamic> payments;
  final VoidCallback onRefresh;

  const _AdminActionGrid({
    required this.allBookings,
    required this.vets,
    required this.caretakers,
    required this.users,
    required this.payments,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Filter out already verified ones for application cards if needed,
    // or just show total counts.
    final pendingVets = vets
        .where((v) => v['is_verified'] == false || v['is_verified'] == 0)
        .toList();
    final pendingCaretakers = caretakers
        .where((c) => c['is_verified'] == false || c['is_verified'] == 0)
        .toList();
    final owners = users.where((u) => u['role'] == 'OWNER').toList();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      children: [
        ActionCard(
          icon: Icons.assignment,
          iconColor: Colors.purple,
          title: "Bookings",
          subtitle: "${allBookings.length} Total",
          onTap: () => _showBookingsModal(context, allBookings),
        ),
        ActionCard(
          icon: Icons.verified,
          iconColor: Colors.blue,
          title: "Vets",
          subtitle: "${pendingVets.length} Pending",
          onTap: () => _showVetApplications(context, vets, onRefresh),
        ),
        ActionCard(
          icon: Icons.home_work,
          iconColor: Colors.orange,
          title: "Caretakers",
          subtitle: "${pendingCaretakers.length} Pending",
          onTap: () =>
              _showCaretakerApplications(context, caretakers, onRefresh),
        ),
        ActionCard(
          icon: Icons.people,
          iconColor: Colors.teal,
          title: "Owners",
          subtitle: "${owners.length} registered",
          onTap: () => _showOwnersModal(context, owners, onRefresh),
        ),
        ActionCard(
          icon: Icons.payments,
          iconColor: Colors.green,
          title: "Payments",
          subtitle: "Review Ledgers",
          onTap: () => _showPaymentsModal(context, payments),
        ),
      ],
    );
  }
}

void _showBookingsModal(BuildContext context, List allbookings) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF2B2A2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'All App Bookings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: allbookings.isEmpty
                ? const Center(
                    child: Text(
                      "No bookings found",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: allbookings.length,
                    itemBuilder: (context, index) {
                      final b = allbookings[index];
                      final petName = b['pet']?['name'] ?? 'Unknown Pet';
                      final ownerName = b['user']?['name'] ?? 'Unknown User';
                      final providerName =
                          b['provider']?['name'] ?? 'Unknown Provider';
                      final date = b['date']?.toString().split('T')[0] ?? '';
                      final status =
                          b['status']?.toString().toUpperCase() ?? 'PENDING';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  petName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: status == 'CONFIRMED'
                                        ? Colors.green.withValues(alpha: 0.2)
                                        : Colors.orange.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: status == 'CONFIRMED'
                                          ? Colors.green
                                          : Colors.orange,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: Icons.person,
                              label: "Owner",
                              value: ownerName,
                            ),
                            _InfoRow(
                              icon: Icons.medical_services,
                              label: "Provider",
                              value: providerName,
                            ),
                            _InfoRow(
                              icon: Icons.calendar_today,
                              label: "Date",
                              value: date,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}

void _showVetApplications(
  BuildContext context,
  List vets,
  VoidCallback onRefresh,
) {
  _showEnhancedVerificationModal(
    context,
    "Vet Applications",
    Icons.verified,
    vets,
    onRefresh,
    (vet) {
      final isVerified = vet['is_verified'] == true || vet['is_verified'] == 1;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vet["name"] ?? "Unknown Vet",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            vet["clinic"] ?? "Private Clinic",
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.description, size: 12, color: Colors.blueAccent),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "Spec: ${vet["specialist"] ?? "General"} | Lic: ${vet["license"] ?? "doc_verified.pdf"}",
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (isVerified)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                "✅ VERIFIED",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      );
    },
  );
}

void _showCaretakerApplications(
  BuildContext context,
  List caretakers,
  VoidCallback onRefresh,
) {
  _showEnhancedVerificationModal(
    context,
    "Caretaker Applications",
    Icons.home_work,
    caretakers,
    onRefresh,
    (caretaker) {
      final isVerified =
          caretaker['is_verified'] == true || caretaker['is_verified'] == 1;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            caretaker["name"] ?? "Unknown Caretaker",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Exp: ${caretaker["experience"] ?? "Not specified"} years",
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star, size: 12, color: Colors.orangeAccent),
              const SizedBox(width: 4),
              Text(
                "Spec: ${caretaker["specialist"] ?? "General Care"}",
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (isVerified)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                "✅ VERIFIED",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      );
    },
  );
}

void _showOwnersModal(
  BuildContext context,
  List owners,
  VoidCallback onRefresh,
) {
  _showEnhancedVerificationModal(
    context,
    "Owner Verification",
    Icons.people,
    owners,
    onRefresh,
    (user) {
      "SELECT id, name, email, phone, experience, specialist, is_verified, is_active FROM users WHERE role = 'CARETAKER' ORDER BY created_at DESC";
      final isVerified =
          user['is_verified'] == true || user['is_verified'] == 1;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user["name"] as String,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user["email"] ?? "No email",
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          if (isVerified)
            const Text(
              "✅ VERIFIED",
              style: TextStyle(
                color: Colors.green,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      );
    },
  );
}

void _showPaymentsModal(BuildContext context, payments) {
  _showStaticPlaceholderModal(
    context,
    "Payment Ledger",
    Icons.payments,
    payments,
    (payment) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "From: ${payment["user"]} → ${payment["provider"]}",
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                payment["amount"]!,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: payment["status"] == "COMPLETED"
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              payment["status"]!,
              style: TextStyle(
                color: payment["status"] == "COMPLETED"
                    ? Colors.green
                    : Colors.orange,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}

// Enhanced modal with real API integration and refreshing
void _showEnhancedVerificationModal(
  BuildContext context,
  String title,
  IconData icon,
  List items,
  VoidCallback onRefresh,
  Widget Function(Map<String, dynamic>) buildContent,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Color(0xFF2B2A2A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(icon, color: const Color(0xFFF57C00)),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? const Center(
                        child: Text(
                          "No items found",
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final isVerified =
                              item['is_verified'] == true ||
                              item['is_verified'] == 1;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              children: [
                                Expanded(child: buildContent(item)),
                                if (!isVerified)
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.green,
                                        ),
                                        onPressed: () async {
                                          try {
                                            await ApiService.verifyUser(
                                              item['id'],
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Verified successfully!",
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                            onRefresh(); // Refresh parent dashboard
                                            Navigator.pop(
                                              context,
                                            ); // Close sheet
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text("Error: $e"),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.highlight_off,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          try {
                                            await ApiService.rejectUser(
                                              item['id'],
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Rejected successfully.",
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            onRefresh();
                                            Navigator.pop(context);
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text("Error: $e"),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

// A reusable bottom sheet for simple viewing (like Payments)
void _showStaticPlaceholderModal(
  BuildContext context,
  String title,
  IconData icon,
  List items,
  Widget Function(Map<String, dynamic>) buildContent,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF2B2A2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      "No data",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: buildContent(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white54),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
