import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/shared/widgets/action_card.dart';
import 'package:frontend/shared/widgets/glassy_components.dart';
import 'dart:ui';
import 'package:frontend/features/auth/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class VetDashboard extends StatefulWidget {
  const VetDashboard({super.key});

  @override
  State<VetDashboard> createState() => _VetDashboardState();
}

class _VetDashboardState extends State<VetDashboard> {
  String userName = "Dr. Vet";
  int vetId = 0;
  bool isLoading = true;
  int todayApptsCount = 0;
  List<dynamic> bookings = [];
  List<dynamic> todaysAppts = [];
  List<Map<String, String>> earningsHistory = [];
  Map<String, dynamic>? trustData;
  List<Map<String, String>> recentPets = [];

  Map<String, dynamic>? vetDashboardData;
  DateTime _selectedWeekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  String _getWeekLabel(DateTime start) {
    final end = start.add(const Duration(days: 6));
    final format = DateFormat('MMM d');
    return "${format.format(start)} - ${format.format(end)}";
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      vetId = prefs.getInt("user_id") ?? 0;
      userName = prefs.getString("name") ?? "Dr. Vet";
      final dashData = await ApiService.getVetDashboard(vetId);
      final bksData = await ApiService.getBookingsByProvider(vetId); // ✅ Use new unified booking fetcher
      final now = DateTime.now();
      final todayApptsList = bksData.where((b) {
        if (b['date'] == null) return false;
        final date = DateTime.parse(b['date'].toString());
        return date.day == now.day &&
            date.month == now.month &&
            date.year == now.year;
      }).toList();

      setState(() {
        vetDashboardData = dashData;
        bookings = bksData;
        todaysAppts = todayApptsList.take(3).toList();
        todayApptsCount = todayApptsList.length;

        List<Map<String, String>> parsedEarnings = [];
        if (dashData['earningsHistory'] != null) {
          for (var e in dashData['earningsHistory']) {
            parsedEarnings.add({
              'month': e['month']?.toString() ?? '',
              'amount': e['amount']?.toString() ?? '0',
              'jobs': e['jobs']?.toString() ?? '0',
            });
          }
        }
        earningsHistory = parsedEarnings;
        trustData = dashData['trustScore'];
        isLoading = false;
      });
    } catch (e) {
      print("Error loading vet dashboard data: $e");
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
                  SizedBox(height: kToolbarHeight),
                  _VetHeader(
                    userName: userName,
                    todayApptsCount: todayApptsCount,
                  ),
                  SizedBox(height: 30),
                  _VetActionGrid(
                    bookings: bookings,
                    vetId: vetId,
                    earningsHistory: earningsHistory,
                    availability: vetDashboardData?['availability'],
                    selectedWeekStart: _selectedWeekStart,
                    onWeekChanged: (newDate) {
                      setState(() => _selectedWeekStart = newDate);
                    },
                    onRefresh: loadData,
                  ),
                  SizedBox(height: 30),
                  _TodayAppointmentsSection(bookings: bookings),
                  const SizedBox(height: 30),
                  _BookingRequestsSection(
                    bookings: bookings,
                    onStatusUpdated: loadData,
                  ),
                  const SizedBox(height: 30),
                  _TrustScoreSection(trustData: trustData),
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
}

class _VetHeader extends StatelessWidget {
  final String userName;
  final int todayApptsCount;

  const _VetHeader({required this.userName, required this.todayApptsCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "Good morning, $userName 👩‍⚕️",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "You have $todayApptsCount appointments today.",
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}

class _VetActionGrid extends StatefulWidget {
  final List<dynamic> bookings;
  final int vetId;
  final List<Map<String, String>> earningsHistory;
  final Map<String, dynamic>? availability;
  final DateTime selectedWeekStart;
  final Function(DateTime) onWeekChanged;
  final VoidCallback onRefresh;

  const _VetActionGrid({
    required this.bookings,
    required this.vetId,
    required this.earningsHistory,
    required this.availability,
    required this.selectedWeekStart,
    required this.onWeekChanged,
    required this.onRefresh,
  });

  @override
  State<_VetActionGrid> createState() => _VetActionGridState();
}

class _VetActionGridState extends State<_VetActionGrid> {

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
          title: "Schedule",
          subtitle: "Manage your availability",
          onTap: () => _showScheduleDialog(context),
        ),
        ActionCard(
          icon: Icons.calendar_month,
          iconColor: Colors.purple,
          title: "Bookings",
          subtitle: "View all appointments",
          onTap: () => _showBookingsPage(context),
        ),
        ActionCard(
          icon: Icons.note_alt,
          iconColor: Colors.green,
          title: "Visit Summary",
          subtitle: "Write treatment notes",
          onTap: () => _showVisitSummaryDialog(context),
        ),
        ActionCard(
          icon: Icons.pets,
          iconColor: Colors.orange,
          title: "Pet Details",
          subtitle: "View pet information",
          onTap: () => _showPetDetailsPage(context),
        ),
        ActionCard(
          icon: Icons.event_available,
          iconColor: Colors.teal,
          title: "Availability",
          subtitle: "Set working hours",
          onTap: () => _showAvailabilityDialog(context),
        ),
        ActionCard(
          icon: Icons.attach_money,
          iconColor: Colors.purple,
          title: "Earnings",
          subtitle: "Track income",
          onTap: () => _showEarningsSheet(context),
        ),
        ActionCard(
          icon: Icons.person,
          iconColor: Colors.tealAccent,
          title: "Edit Profile",
          subtitle: "Update license & info",
          onTap: () => _showProfileSheet(context),
        ),
      ],
    );
  }

  void _showScheduleDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return _ScheduleSheet(
            availability: widget.availability,
            weekStart: widget.selectedWeekStart,
            onWeekChanged: (newWeek) {
              widget.onWeekChanged(newWeek);
              setModalState(() {});
            },
          );
        },
      ),
    );
  }

  void _showAvailabilityDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AvailabilitySheet(
        vetId: widget.vetId,
        weekStart: widget.selectedWeekStart,
      ),
    ).then((result) {
      if (result != null) {
        widget.onRefresh();
      }
    });
  }

  void _showBookingsPage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AllBookingsSheet(bookings: widget.bookings),
    );
  }

  void _showVisitSummaryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          _VisitSummarySheet(bookings: widget.bookings, providerId: widget.vetId),
    );
  }

  void _showPetDetailsPage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PetDetailsSheet(bookings: widget.bookings),
    );
  }

  void _showEarningsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _EarningsSheet(earnings: widget.earningsHistory),
    );
  }
  
  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ProfileSheet(vetId: widget.vetId, onRefresh: widget.onRefresh),
    );
  }
}

class _ProfileSheet extends StatefulWidget {
  final int vetId;
  final VoidCallback onRefresh;
  const _ProfileSheet({required this.vetId, required this.onRefresh});

  @override
  State<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<_ProfileSheet> {
  final _licenseController = TextEditingController();
  final _specialistController = TextEditingController();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _licenseController.text = prefs.getString("license") ?? "";
      _specialistController.text = prefs.getString("specialist") ?? "";
    });
  }

  void _saveProfile() async {
    setState(() => isSaving = true);
    try {
      final res = await ApiService.updateProfile(widget.vetId, {
        "license": _licenseController.text.trim(),
        "specialist": _specialistController.text.trim(),
      });

      if (res["status"] == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("license", _licenseController.text.trim());
        await prefs.setString("specialist", _specialistController.text.trim());
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated")),
        );
        widget.onRefresh();
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF2B2A2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Update Profile",
              style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _licenseController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Medical License Number",
                labelStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.verified_user_outlined, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _specialistController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Specialised Area",
                labelStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.star_outline, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF57C00)),
                child: isSaving 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EarningsSheet extends StatelessWidget {
  final List<dynamic> earnings;
  const _EarningsSheet({required this.earnings});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Earnings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: earnings.isEmpty
                ? const Center(
                    child: Text(
                      "No earnings recorded",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: earnings.length,
                    itemBuilder: (context, index) {
                      final earning = earnings[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  earning['month']?.toString() ?? 'Unknown',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${earning['jobs'] ?? 0} jobs',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '₹${earning['amount'] ?? 0}',
                              style: const TextStyle(
                                color: Color(0xFFF57C00),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
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
  }
}

class _ScheduleSheet extends StatelessWidget {
  final Map<String, dynamic>? availability;
  final DateTime weekStart;
  final Function(DateTime) onWeekChanged;

  const _ScheduleSheet({
    required this.availability,
    required this.weekStart,
    required this.onWeekChanged,
  });

  @override
  Widget build(BuildContext context) {
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Schedule',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white70),
                      onPressed: () => onWeekChanged(weekStart.subtract(const Duration(days: 7))),
                    ),
                    Text(
                      DateFormat('MMM d').format(weekStart),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white70),
                      onPressed: () => onWeekChanged(weekStart.add(const Duration(days: 7))),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 7,
              itemBuilder: (context, index) {
                final date = weekStart.add(Duration(days: index));
                final dayName = DateFormat('EEE').format(date);
                final fullDayName = DateFormat('EEEE').format(date);
                
                // Search for availability in the map by 'Mon', 'Tue', etc.
                final shortDay = dayName.substring(0, 3);
                final dayData = availability?[shortDay];
                final start = dayData?['start'];
                final end = dayData?['end'];
                final isAvailable = start != null && end != null;

                return _ScheduleItem(
                  day: "$fullDayName (${DateFormat('MMM d').format(date)})",
                  time: isAvailable ? "$start - $end" : "Off",
                  isAvailable: isAvailable,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final String day;
  final String time;
  final bool isAvailable;
  const _ScheduleItem({
    required this.day,
    required this.time,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              day,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              time,
              style: TextStyle(
                color: isAvailable ? Colors.white70 : Colors.red,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isAvailable
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isAvailable ? 'Available' : 'Off',
              style: TextStyle(
                color: isAvailable ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllBookingsSheet extends StatelessWidget {
  final List<dynamic> bookings;
  const _AllBookingsSheet({required this.bookings});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'All Bookings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: bookings.isEmpty
                ? const Center(
                    child: Text(
                      "No bookings yet",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      final petName = booking['pet_name'] ?? 'Unknown Pet';
                      final ownerName =
                          booking['owner_name'] ?? 'Unknown Owner';
                      final time = booking['time'] ?? '';
                      final date = booking['booking_date'] != null
                          ? booking['booking_date'].toString().split('T')[0]
                          : '';
                      final status = booking['status'] ?? 'pending';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
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
                                    color: status == 'confirmed'
                                        ? Colors.green.withOpacity(0.2)
                                        : Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status == 'confirmed'
                                        ? 'Confirmed'
                                        : status.toString().toUpperCase(),
                                    style: TextStyle(
                                      color: status == 'confirmed'
                                          ? Colors.green
                                          : Colors.orange,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Owner: $ownerName',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.white54,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$date $time',
                                  style: const TextStyle(color: Colors.white54),
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
  }
}

class _VisitSummarySheet extends StatefulWidget {
  final List<dynamic> bookings;
  final int providerId;

  const _VisitSummarySheet({required this.bookings, required this.providerId});

  @override
  State<_VisitSummarySheet> createState() => _VisitSummarySheetState();
}

class _VisitSummarySheetState extends State<_VisitSummarySheet> {
  dynamic _selectedBooking;

  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _prescriptionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _followUpDate;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();

    // ✅ Auto select first booking
    if (widget.bookings.isNotEmpty) {
      _selectedBooking = widget.bookings[0];
    }
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _prescriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ✅ REAL SAVE FUNCTION
  void _saveAndSendToOwner() async {
    if (_diagnosisController.text.isEmpty ||
        _prescriptionController.text.isEmpty ||
        _selectedBooking == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await ApiService.saveVisitSummary({
        "booking_id": _selectedBooking['id'],
        "diagnosis": _diagnosisController.text,
        "prescription": _prescriptionController.text,
        "notes": _notesController.text,
        "follow_up": _followUpDate?.toIso8601String(),
      });

      setState(() {
        _isSaved = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Visit summary saved! Trust Score +5 🌟"),
          backgroundColor: Colors.green,
        ),
      );

      // Show success dialog like in caretaker dashboard
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF2B2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('Sent to Owner!', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Visit summary has been saved and sent to:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pet: ${_selectedBooking['pet']?['name'] ?? 'Unknown'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Owner: ${_selectedBooking['user']?['name'] ?? 'Unknown'}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close sheet
              },
              child: const Text(
                'Done',
                style: TextStyle(color: Color(0xFFF57C00)),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving summary: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookings = widget.bookings;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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

          // TITLE
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Visit Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (_isSaved)
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ PET SELECTION (REAL DATA)
                  const Text(
                    'Select Pet',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 10,
                    children: bookings.map((b) {
                      final petName = b['pet_name'] ?? 'Unknown Pet';
                      return ChoiceChip(
                        label: Text(petName),
                        selected: _selectedBooking == b,
                        onSelected: (_) {
                          setState(() {
                            _selectedBooking = b;
                            _isSaved = false;
                          });
                        },
                        selectedColor: const Color(0xFFF57C00),
                        backgroundColor: Colors.white.withOpacity(0.1),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // ✅ OWNER INFO (REAL)
                  if (_selectedBooking != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: Colors.blue),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Owner: ${_selectedBooking['owner_name'] ?? 'Unknown'}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                _selectedBooking['owner_phone'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // DIAGNOSIS
                  const Text(
                    'Diagnosis *',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _diagnosisController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Enter diagnosis...'),
                  ),

                  const SizedBox(height: 20),

                  // PRESCRIPTION
                  const Text(
                    'Prescription *',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _prescriptionController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Enter prescription...'),
                  ),

                  const SizedBox(height: 20),

                  // NOTES
                  const Text(
                    'Additional Notes',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Any notes...'),
                  ),

                  const SizedBox(height: 20),

                  // FOLLOW-UP
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(
                          const Duration(days: 7),
                        ),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (date != null) {
                        setState(() => _followUpDate = date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _followUpDate != null
                            ? _followUpDate.toString()
                            : 'Select follow-up date...',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveAndSendToOwner,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF57C00),
                      ),
                      child: const Text('Save & Send'),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _PetDetailsSheet extends StatelessWidget {
  final List<dynamic> bookings;
  const _PetDetailsSheet({required this.bookings});

  @override
  Widget build(BuildContext context) {
    // derive unique pets from bookings
    List<Map<String, dynamic>> pets = [];
    final Set<String> seenPetNames = {};
    for (var b in bookings) {
      if (b['pet'] != null) {
        final name = b['pet']['name'];
        if (name != null && !seenPetNames.contains(name)) {
          seenPetNames.add(name);
          pets.add({
            'name': name,
            'type': b['pet']['type'] ?? 'Unknown',
            'owner': b['user']?['name'] ?? 'Unknown',
            'phone': b['user']?['phone'] ?? 'N/A',
            'condition': b['pet']['condition'] ?? 'Healthy',
            'lastVisit': b['date']?.toString().split('T')[0] ?? 'N/A',
          });
        }
      }
    }

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
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Pet Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: pets.isEmpty
                ? const Center(
                    child: Text(
                      "No pets related to your bookings yet",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: pets.length,
                    itemBuilder: (context, index) {
                      final pet = pets[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFF57C00,
                                    ).withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.pets,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pet['name']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        pet['type']!,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: pet['condition'] == 'Healthy'
                                        ? Colors.green.withOpacity(0.2)
                                        : Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    pet['condition']!.toString(),
                                    style: TextStyle(
                                      color: pet['condition'] == 'Healthy'
                                          ? Colors.green
                                          : Colors.orange,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _DetailRow(
                              icon: Icons.person,
                              label: 'Owner',
                              value: pet['owner']!,
                            ),
                            _DetailRow(
                              icon: Icons.phone,
                              label: 'Phone',
                              value: pet['phone']!,
                            ),
                            _DetailRow(
                              icon: Icons.calendar_today,
                              label: 'Last Booking Date',
                              value: pet['lastVisit']!,
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
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white54),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.white54)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _AvailabilitySheet extends StatefulWidget {
  final int vetId;
  final DateTime weekStart;
  const _AvailabilitySheet({required this.vetId, required this.weekStart});

  @override
  State<_AvailabilitySheet> createState() => _AvailabilitySheetState();
}

class _AvailabilitySheetState extends State<_AvailabilitySheet> {
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);

  Future<void> _saveAvailability() async {
    try {
      final weekEnd = widget.weekStart.add(const Duration(days: 6));
      
      await ApiService.saveAvailability({
        "vetId": widget.vetId,
        "startTime": _startTime.format(context),
        "endTime": _endTime.format(context),
        "weekStart": widget.weekStart.toIso8601String(),
        "weekEnd": weekEnd.toIso8601String(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Availability saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
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
            child: Column(
              children: [
                const Text(
                  'Set Availability',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Week: ${DateFormat('MMM d').format(widget.weekStart)} - ${DateFormat('MMM d').format(widget.weekStart.add(const Duration(days: 6)))}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Working Hours',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _TimeSelector(
                          label: 'Start Time',
                          time: _startTime,
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _startTime,
                            );
                            if (time != null) {
                              setState(() => _startTime = time);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _TimeSelector(
                          label: 'End Time',
                          time: _endTime,
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _endTime,
                            );
                            if (time != null) {
                              setState(() => _endTime = time);
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveAvailability, // ✅ FIXED
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF57C00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Availability',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;
  const _TimeSelector({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              time.format(context),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayAppointmentsSection extends StatelessWidget {
  final List<dynamic> bookings;

  const _TodayAppointmentsSection({required this.bookings});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayBookings = bookings.where((b) {
      if (b['date'] == null) return false;
      final bookingDate = DateTime.parse(b['date'].toString());
      return (b['status'] == 'accepted' || b['status'] == 'confirmed') &&
          bookingDate.year == today.year &&
          bookingDate.month == today.month &&
          bookingDate.day == today.day;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Appointments",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        if (todayBookings.isEmpty)
          const Text(
            "No appointments today",
            style: TextStyle(color: Colors.white70),
          ),
        ...todayBookings.map((booking) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NeumorphicGlassContainer(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${booking['pet']?['name'] ?? 'Pet'} - ${booking['serviceType'] ?? 'General Checkup'}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${booking['time'] ?? 'N/A'} • ${booking['careLevel'] ?? 'Standard'} Care",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

class _TrustScoreSection extends StatelessWidget {
  final Map<String, dynamic>? trustData;
  const _TrustScoreSection({required this.trustData});
  @override
  Widget build(BuildContext context) {
    final int trustScore = trustData?['score'] ?? 0;
    final int totalAssignments = trustData?['totalAssignments'] ?? 0;
    final int completedAssignments = trustData?['completedAssignments'] ?? 0;
    final int onTimeCount = trustData?['onTimeCount'] ?? 0;
    final int frequentClientCount = trustData?['frequentClientCount'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Trust Score",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _getTrustScoreColor(trustScore),
                          width: 5,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$trustScore',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _getTrustScoreColor(trustScore),
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
                            value: completedAssignments,
                            total: totalAssignments,
                            maxPoints: 25,
                          ),
                          const SizedBox(height: 8),
                          _ScoreBreakdownItem(
                            label: "On Time Service",
                            value: onTimeCount,
                            total: completedAssignments,
                            maxPoints: 25,
                          ),
                          const SizedBox(height: 8),
                          _ScoreBreakdownItem(
                            label: "Frequent Clients",
                            value: frequentClientCount,
                            total: 30,
                            maxPoints: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        label: "Total Jobs",
                        value: "$totalAssignments",
                      ),
                      _StatItem(
                        label: "Completed",
                        value: "$completedAssignments",
                      ),
                      _StatItem(label: "On Time", value: "$onTimeCount"),
                      _StatItem(
                        label: "Frequent",
                        value: "$frequentClientCount",
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
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
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
              percentage >= 0.9
                  ? Colors.green
                  : percentage >= 0.7
                  ? Colors.blue
                  : Colors.orange,
            ),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}

class _BookingRequestsSection extends StatelessWidget {
  final List<dynamic> bookings;
  final VoidCallback onStatusUpdated;

  const _BookingRequestsSection({
    required this.bookings,
    required this.onStatusUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final pendingBookings = bookings.where((b) => b['status'] == 'PENDING').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Booking Requests",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        if (pendingBookings.isEmpty)
          const Text(
            "No pending requests",
            style: TextStyle(color: Colors.white70),
          ),
        ...pendingBookings.map((booking) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NeumorphicGlassContainer(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${booking['pet_name'] ?? 'Pet'} - ${booking['owner_name'] ?? 'Owner'}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          booking['booking_date']?.toString().split('T')[0] ?? '',
                          style: const TextStyle(color: Color(0xFFF57C00), fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Time: ${booking['booking_time'] ?? 'N/A'}",
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    if (booking['details'] != null && booking['details'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          "Note: ${booking['details']}",
                          style: const TextStyle(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _updateStatus(context, booking['booking_id'], 'ACCEPTED'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Accept"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _updateStatus(context, booking['booking_id'], 'REJECTED'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Reject"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Future<void> _updateStatus(BuildContext context, int bookingId, String status) async {
    try {
      await ApiService.updateBookingStatus(bookingId, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking $status")),
      );
      onStatusUpdated();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
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
          style: const TextStyle(fontSize: 10, color: Colors.white54),
        ),
      ],
    );
  }
}
