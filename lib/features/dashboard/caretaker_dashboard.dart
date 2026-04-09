import 'package:flutter/material.dart';
import 'package:frontend/features/dashboard/vet_dashboard.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/shared/widgets/action_card.dart';
import 'package:frontend/shared/widgets/glassy_components.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/features/auth/screens/login_screen.dart';
import 'package:intl/intl.dart';

class CaretakerDashboard extends StatefulWidget {
  const CaretakerDashboard({super.key});

  @override
  State<CaretakerDashboard> createState() => _CaretakerDashboardState();
}

class _CaretakerDashboardState extends State<CaretakerDashboard> {
  String userName = "Caretaker";
  int caretakerId = 0;
  bool isLoading = true;
  int todayTasksCount = 0;

  List<dynamic> bookings = [];
  List<dynamic> todayTasks = [];
  List<Map<String, String>> earningsHistory = [];
  Map<String, dynamic>? trustData;
  Map<String, dynamic>? dashboardData;
  DateTime _selectedWeekStart = DateTime.now().subtract(
    Duration(days: DateTime.now().weekday - 1),
  );

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
      caretakerId = prefs.getInt("user_id") ?? 0;
      userName = prefs.getString("name") ?? "Caretaker";

      final dashData = await ApiService.getCaretakerDashboard(caretakerId);
      final bksData = await ApiService.getBookingsByProvider(
        caretakerId,
      ); // ✅ Use new unified booking fetcher

      final now = DateTime.now();

      final todayList = bksData.where((b) {
        if (b['date'] == null) return false;
        final date = DateTime.parse(b['date'].toString());
        return date.day == now.day &&
            date.month == now.month &&
            date.year == now.year;
      }).toList();

      setState(() {
        dashboardData = dashData;
        bookings = bksData;
        todayTasks = todayList.take(3).toList();
        todayTasksCount = todayList.length;

        DateFormat format = DateFormat("h:mm a");
        String startStr = dashData['availability']['availability_start'] ?? '9:00 AM';
        String endStr = dashData['availability']['availability_end'] ?? '5:00 PM';

        Availability.startTime = format.parse(startStr);
        Availability.endTime = format.parse(endStr);
        print("startTime ${Availability.startTime}");
        print("endTime ${Availability.endTime}");



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
      print("Error loading caretaker dashboard: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> logout(BuildContext context) async {
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
                fit: BoxFit.cover,
                opacity: 0.5,
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
                  _CaretakerHeader(
                    userName: userName,
                    todayCount: todayTasksCount,
                  ),
                  const SizedBox(height: 30),
                  _CaretakerActionGrid(
                    bookings: bookings,
                    caretakerId: caretakerId,
                    earningsHistory: earningsHistory,
                    dashboardData: dashboardData,
                    selectedWeekStart: _selectedWeekStart,
                    onWeekChanged: (newDate) {
                      setState(() => _selectedWeekStart = newDate);
                    },
                    onRefresh: loadData,
                  ),
                  const SizedBox(height: 30),
                  _TodayTasksSection(tasks: todayTasks),
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
                      onPressed: () => logout(context),
                      child: const Text("Logout"),
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

class _CaretakerHeader extends StatelessWidget {
  final String userName;
  final int todayCount;

  const _CaretakerHeader({required this.userName, required this.todayCount});

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
                  "Good morning, $userName",
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
          "You have $todayCount tasks today",
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}

class _CaretakerActionGrid extends StatefulWidget {
  final List<dynamic> bookings;
  final int caretakerId;
  final List<dynamic> earningsHistory;
  final Map<String, dynamic>? dashboardData;
  final DateTime selectedWeekStart;
  final Function(DateTime) onWeekChanged;
  final VoidCallback onRefresh;

  const _CaretakerActionGrid({
    required this.bookings,
    required this.caretakerId,
    required this.earningsHistory,
    this.dashboardData,
    required this.selectedWeekStart,
    required this.onWeekChanged,
    required this.onRefresh,
  });

  @override
  State<_CaretakerActionGrid> createState() => _CaretakerActionGridState();
}

class _CaretakerActionGridState extends State<_CaretakerActionGrid> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      children: [
        // ActionCard(
        //   icon: Icons.schedule,
        //   iconColor: Colors.blue,
        //   title: "Schedule",
        //   subtitle: "Manage your availability",
        //   onTap: () => _showScheduleDialog(context),
        // ),
        ActionCard(
          icon: Icons.calendar_month,
          iconColor: Colors.purple,
          title: "Bookings",
          subtitle: "View all tasks",
          onTap: () => _showBookingsPage(context),
        ),
        ActionCard(
          icon: Icons.note_alt,
          iconColor: Colors.green,
          title: "Visit Summary",
          subtitle: "Write care notes",
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
          iconColor: Colors.greenAccent,
          title: "Earnings",
          subtitle: "Track income",
          onTap: () => _showEarningsSheet(context),
        ),
        ActionCard(
          icon: Icons.person,
          iconColor: Colors.orangeAccent,
          title: "Edit Profile",
          subtitle: "Update experience & info",
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
            availability: widget.dashboardData?['availability'],
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

  void _showBookingsPage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AllBookingsSheet(
        bookings: widget.bookings,
        onStatusUpdated: widget.onRefresh,
      ),
    );
  }

  void _showVisitSummaryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _VisitSummarySheet(
        bookings: widget.bookings,
        providerId: widget.caretakerId,
      ),
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
      builder: (context) => _ProfileSheet(
        caretakerId: widget.caretakerId,
        onRefresh: widget.onRefresh,
      ),
    );
  }

  void _showAvailabilityDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AvailabilitySheet(
        caretakerId: widget.caretakerId,
        weekStart: widget.selectedWeekStart,
      ),
    ).then((result) {
      if (result != null) {
        widget.onRefresh();
      }
    });
  }
}

class _ProfileSheet extends StatefulWidget {
  final int caretakerId;
  final VoidCallback onRefresh;

  const _ProfileSheet({required this.caretakerId, required this.onRefresh});

  @override
  State<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<_ProfileSheet> {
  final _experienceController = TextEditingController();
  final _specialistController = TextEditingController();
  bool emergencyAvailable = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _experienceController.text = prefs.getString("experience") ?? "";
      _specialistController.text = prefs.getString("specialist") ?? "";
      emergencyAvailable = prefs.getBool("emergency_available") ?? false;
    });
  }

  void _saveProfile() async {
    // setState(() => isSaving = true);
    // try {
    //   final res = await ApiService.updateProfile(widget.caretakerId, {
    //     "experience": _experienceController.text.trim(),
    //     "specialist": _specialistController.text.trim(),
    //     "emergency_available": emergencyAvailable,
    //   });
    //
    //   if (res["status"] == 200) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("experience", _experienceController.text.trim());
    await prefs.setString("specialist", _specialistController.text.trim());
    await prefs.setBool("emergency_available", emergencyAvailable);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile updated")));
    widget.onRefresh();
    Navigator.pop(context);
    //   }
    // } catch (e) {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text("Error: $e")));
    // } finally {
    //   setState(() => isSaving = false);
    // }
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
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _experienceController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Experience (Years)",
                labelStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.access_time, color: Colors.white70),
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
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text(
                "Emergency Available",
                style: TextStyle(color: Colors.white70),
              ),
              value: emergencyAvailable,
              onChanged: (val) => setState(() => emergencyAvailable = val),
              activeColor: const Color(0xFFF57C00),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF57C00),
                ),
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Save Changes",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Colors.white70,
                      ),
                      onPressed: () => onWeekChanged(
                        weekStart.subtract(const Duration(days: 7)),
                      ),
                    ),
                    Text(
                      DateFormat('MMM d').format(weekStart),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.white70,
                      ),
                      onPressed: () =>
                          onWeekChanged(weekStart.add(const Duration(days: 7))),
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
  final VoidCallback onStatusUpdated;

  const _AllBookingsSheet({
    required this.bookings,
    required this.onStatusUpdated,
  });

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
                      final date = booking['date'] != null
                          ? booking['date'].toString().split('T')[0]
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
                            const SizedBox(height: 4),
                            //   Complete Booking Button
                            if(status == 'pending')
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _updateStatus(
                                      context,
                                      booking['id'],
                                      'COMPLETED',
                                    ).then((value) => Navigator.pop(context)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text("Complete"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _updateStatus(
                                      context,
                                      booking['id'],
                                      'REJECTED',
                                    ).then((value) => Navigator.pop(context),),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(color: Colors.red),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text("Reject"),
                                  ),
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

  Future<void> _updateStatus(
    BuildContext context,
    int bookingId,
    String status,
  ) async {
    try {
      await ApiService.updateBookingStatus(bookingId, status);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Booking $status")));
      onStatusUpdated();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
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
  String? _selectedPet;
  String _selectedOwner = '';
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _reportController = TextEditingController();
  bool _isSaved = false;
  List<Map<String, String>> _petOwners = [];

  @override
  void initState() {
    super.initState();
    // Parse owners and pets from bookings
    final Set<String> seenPetNames = {};
    for (var b in widget.bookings) {
      if (b['pet_name'] != null) {
        final petName = b['pet_name'];
        if (petName != null && !seenPetNames.contains(petName)) {
          seenPetNames.add(petName);
          _petOwners.add({
            'pet': petName,
            'owner': b['owner_name'] ?? 'Unknown Owner',
            'phone': b['owner_phone'] ?? '+91 XXXXXXXXXX',
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _reportController.dispose();
    super.dispose();
  }

  void _saveAndSendToOwner() {
    if (_reportController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in care notes'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Care summary saved! Trust Score +5 🌟'),
        backgroundColor: Colors.green,
      ),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2B2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              'Care summary has been saved and sent to:',
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
                    'Pet: $_selectedPet',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Owner: $_selectedOwner',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.message, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Text(
                  'Notification sent!',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Done',
              style: TextStyle(color: Color(0xFFF57C00)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check, color: Colors.green, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Sent',
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _petOwners.isEmpty
                ? const Center(
                    child: Text(
                      "No assignments yet to report on.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          children: _petOwners
                              .map(
                                (petData) => ChoiceChip(
                                  label: Text(petData['pet']!),
                                  selected: _selectedPet == petData['pet'],
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedPet = petData['pet']!;
                                      _selectedOwner = petData['owner']!;
                                      _isSaved = false;
                                    });
                                  },
                                  selectedColor: const Color(0xFFF57C00),
                                  backgroundColor: Colors.white.withOpacity(
                                    0.1,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        if (_selectedPet != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.person, color: Colors.blue),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Owner: $_selectedOwner',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _petOwners.firstWhere(
                                        (p) => p['pet'] == _selectedPet,
                                      )['phone']!,
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
                        const Text(
                          'Care Report *',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _reportController,
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Enter care report...',
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Additional Notes',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _notesController,
                          maxLines: 2,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Any additional instructions...',
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _reportController.clear();
                                    _notesController.clear();
                                    setState(() {
                                      _isSaved = false;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[800],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Clear',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _selectedPet == null
                                      ? null
                                      : _saveAndSendToOwner,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF57C00),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Save & Send to Owner',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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

class _PetDetailsSheet extends StatelessWidget {
  final List<dynamic> bookings;

  const _PetDetailsSheet({required this.bookings});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> pets = [];
    final Set<String> seenPetNames = {};
    for (var b in bookings) {
      if (b['pet_name'] != null) {
        final name = b['pet_name'];
        if (name != null && !seenPetNames.contains(name)) {
          seenPetNames.add(name);
          pets.add({
            'name': name,
            'type': b['type'] ?? 'Unknown',
            'owner': b['owner_name'] ?? 'Unknown',
            'phone': b['owner_phone'] ?? 'N/A',
            'condition': 'Healthy',
            'lastVisit': b['booking_date']?.toString().split('T')[0] ?? 'N/A',
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
  final int caretakerId;
  final DateTime weekStart;

  const _AvailabilitySheet({
    required this.caretakerId,
    required this.weekStart,
  });

  @override
  State<_AvailabilitySheet> createState() => _AvailabilitySheetState();
}

class _AvailabilitySheetState extends State<_AvailabilitySheet> {
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);

  @override
  void initState() {
// TODO: implement initState
    super.initState();

// Use Availability.startTime to set the initial time
    _startTime = TimeOfDay.fromDateTime(Availability.startTime);
    _endTime = TimeOfDay.fromDateTime(Availability.endTime);
  }

  Future<void> _saveAvailability() async {
    try {

      await ApiService.saveAvailability({
        "vetId": widget.caretakerId,
        "startTime": _startTime.format(context),
        "endTime": _endTime.format(context),
      });

      // Step 2: Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saved for ${_getWeekLabel(widget.weekStart)}: ${_startTime.format(context)} - ${_endTime.format(context)}',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Step 3: Send data back (IMPORTANT)
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Save failed: $e"), backgroundColor: Colors.red),
      );
    }
  }

  String _getWeekLabel(DateTime start) {
    final end = start.add(const Duration(days: 6));
    final format = DateFormat('MMM d');
    return "${format.format(start)} - ${format.format(end)}";
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
                      onPressed: _saveAvailability,
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

class _TodayTasksSection extends StatelessWidget {
  final List tasks;

  const _TodayTasksSection({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Tasks",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        if (tasks.isEmpty)
          const Text(
            "No tasks scheduled for today.",
            style: TextStyle(color: Colors.white70),
          )
        else
          ...tasks.map((task) {
            final petName = task['pet']?['name'] ?? 'Unknown Pet';
            final time = task['time'] ?? 'TBD';
            return NeumorphicGlassContainer(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "$petName at $time",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _TrustScoreSection extends StatelessWidget {
  final Map<String, dynamic>? trustData;

  const _TrustScoreSection({this.trustData});

  static const int _trustScore = 98;
  static const int _totalAssignments = 156;
  static const int _completedAssignments = 152;
  static const int _onTimeCount = 148;
  static const int _frequentClientCount = 45;

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
                        value: "$_totalAssignments",
                      ),
                      _StatItem(
                        label: "Completed",
                        value: "$_completedAssignments",
                      ),
                      _StatItem(label: "On Time", value: "$_onTimeCount"),
                      _StatItem(
                        label: "Frequent",
                        value: "$_frequentClientCount",
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
    final pendingBookings = bookings
        .where((b) => b['status'] == 'PENDING')
        .toList();

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
                          booking['booking_date']?.toString().split('T')[0] ??
                              '',
                          style: const TextStyle(
                            color: Color(0xFFF57C00),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Time: ${booking['booking_time'] ?? 'N/A'}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    if (booking['details'] != null &&
                        booking['details'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          "Note: ${booking['details']}",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _updateStatus(
                              context,
                              booking['booking_id'],
                              'ACCEPTED',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Accept"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _updateStatus(
                              context,
                              booking['booking_id'],
                              'REJECTED',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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

  Future<void> _updateStatus(
    BuildContext context,
    int bookingId,
    String status,
  ) async {
    try {
      await ApiService.updateBookingStatus(bookingId, status);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Booking $status")));
      onStatusUpdated();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white54),
        ),
      ],
    );
  }
}

//lucy
//robin
//rai
