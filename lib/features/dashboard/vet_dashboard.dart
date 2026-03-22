import 'package:flutter/material.dart';
import 'package:frontend/shared/widgets/action_card.dart';
import 'package:frontend/shared/widgets/glassy_components.dart';
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
        child: GlassyAppBar(logout: () => logoutUser(context), showEmergency: false),
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
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 8),
        Text("You have 4 appointments today.", style: TextStyle(color: Colors.white70)),
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
        ActionCard(icon: Icons.schedule, iconColor: Colors.blue, title: "Schedule", subtitle: "Manage your availability", onTap: () => _showScheduleDialog(context)),
        ActionCard(icon: Icons.calendar_month, iconColor: Colors.purple, title: "Bookings", subtitle: "View all appointments", onTap: () => _showBookingsPage(context)),
        ActionCard(icon: Icons.note_alt, iconColor: Colors.green, title: "Visit Summary", subtitle: "Write treatment notes", onTap: () => _showVisitSummaryDialog(context)),
        ActionCard(icon: Icons.pets, iconColor: Colors.orange, title: "Pet Details", subtitle: "View pet information", onTap: () => _showPetDetailsPage(context)),
        ActionCard(icon: Icons.event_available, iconColor: Colors.teal, title: "Availability", subtitle: "Set working hours", onTap: () => _showAvailabilityDialog(context)),
        ActionCard(icon: Icons.attach_money, iconColor: Colors.purple, title: "Earnings", subtitle: "Track income", onTap: () => _showEarningsSheet(context)),
      ],
    );
  }

  void _showScheduleDialog(BuildContext context) {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (context) => _ScheduleSheet());
  }

  void _showBookingsPage(BuildContext context) {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (context) => _AllBookingsSheet());
  }

  void _showVisitSummaryDialog(BuildContext context) {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (context) => _VisitSummarySheet());
  }

  void _showPetDetailsPage(BuildContext context) {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (context) => _PetDetailsSheet());
  }

  void _showEarningsSheet(BuildContext context) {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (context) => _EarningsSheet());
  }

  void _showAvailabilityDialog(BuildContext context) {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (context) => _AvailabilitySheet());
  }
}

class _EarningsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final earnings = [
      {'month': 'January', 'amount': '\₹1200', 'jobs': 15},
      {'month': 'February', 'amount': '\₹1350', 'jobs': 18},
      {'month': 'March', 'amount': '\₹1100', 'jobs': 14},
    ];
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(color: Color(0xFF2B2A2A), borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: Column(children: [
        Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2))),
        const Padding(padding: EdgeInsets.all(20), child: Text('Earnings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
        Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 20), itemCount: earnings.length, itemBuilder: (context, index) {
          final earning = earnings[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(earning['month']! as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${earning['jobs']} jobs', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
              Text(earning['amount']! as String, style: const TextStyle(color: Color(0xFFF57C00), fontWeight: FontWeight.bold, fontSize: 18)),
            ]),
          );
        })),
      ]),
    );
  }
}

class _ScheduleSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(color: Color(0xFF2B2A2A), borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: Column(children: [
        Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2))),
        const Padding(padding: EdgeInsets.all(20), child: Text('Your Schedule', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
        Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: const [
          _ScheduleItem(day: 'Monday', time: '9:00 AM - 5:00 PM', isAvailable: true),
          _ScheduleItem(day: 'Tuesday', time: '9:00 AM - 5:00 PM', isAvailable: true),
          _ScheduleItem(day: 'Wednesday', time: '9:00 AM - 5:00 PM', isAvailable: true),
          _ScheduleItem(day: 'Thursday', time: '9:00 AM - 5:00 PM', isAvailable: true),
          _ScheduleItem(day: 'Friday', time: '9:00 AM - 3:00 PM', isAvailable: true),
          _ScheduleItem(day: 'Saturday', time: '10:00 AM - 2:00 PM', isAvailable: false),
          _ScheduleItem(day: 'Sunday', time: 'Off', isAvailable: false),
        ])),
      ]),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final String day;
  final String time;
  final bool isAvailable;
  const _ScheduleItem({required this.day, required this.time, required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        SizedBox(width: 100, child: Text(day, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        Expanded(child: Text(time, style: TextStyle(color: isAvailable ? Colors.white70 : Colors.red))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: isAvailable ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: Text(isAvailable ? 'Available' : 'Off', style: TextStyle(color: isAvailable ? Colors.green : Colors.red, fontSize: 12)),
        ),
      ]),
    );
  }
}

class _AllBookingsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bookings = [
      {'petName': 'Max', 'ownerName': 'Alex Johnson', 'time': '9:00 AM', 'service': 'Vaccination', 'status': 'confirmed'},
      {'petName': 'Luna', 'ownerName': 'Sarah Miller', 'time': '11:00 AM', 'service': 'Dental Checkup', 'status': 'confirmed'},
      {'petName': 'Charlie', 'ownerName': 'Mike Davis', 'time': '2:00 PM', 'service': 'General Checkup', 'status': 'pending'},
      {'petName': 'Buddy', 'ownerName': 'Emily Brown', 'time': '4:00 PM', 'service': 'Follow-up', 'status': 'confirmed'},
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(color: Color(0xFF2B2A2A), borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: Column(children: [
        Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2))),
        const Padding(padding: EdgeInsets.all(20), child: Text('All Bookings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
        Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 20), itemCount: bookings.length, itemBuilder: (context, index) {
          final booking = bookings[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(booking['petName']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: booking['status'] == 'confirmed' ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text(booking['status'] == 'confirmed' ? 'Confirmed' : 'Pending', style: TextStyle(color: booking['status'] == 'confirmed' ? Colors.green : Colors.orange, fontSize: 12)),
                ),
              ]),
              const SizedBox(height: 8),
              Text('Owner: ${booking['ownerName']!}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.access_time, size: 14, color: Colors.white54),
                const SizedBox(width: 4),
                Text(booking['time']!, style: const TextStyle(color: Colors.white54)),
                const SizedBox(width: 16),
                const Icon(Icons.medical_services, size: 14, color: Colors.white54),
                const SizedBox(width: 4),
                Text(booking['service']!, style: const TextStyle(color: Colors.white54)),
              ]),
            ]),
          );
        })),
      ]),
    );
  }
}

class _VisitSummarySheet extends StatefulWidget {
  @override
  State<_VisitSummarySheet> createState() => _VisitSummarySheetState();
}

class _VisitSummarySheetState extends State<_VisitSummarySheet> {
  String _selectedPet = 'Max';
  String _selectedOwner = 'Alex Johnson';
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _prescriptionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _followUpDate;
  bool _isSaved = false;

  final List<Map<String, String>> _petOwners = [
    {'pet': 'Max', 'owner': 'Alex Johnson', 'phone': '+91 98765 43210'},
    {'pet': 'Luna', 'owner': 'Sarah Miller', 'phone': '+91 98765 43211'},
    {'pet': 'Charlie', 'owner': 'Mike Davis', 'phone': '+91 98765 43212'},
  ];

  @override
  void dispose() {
    _diagnosisController.dispose();
    _prescriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveAndSendToOwner() {
    if (_diagnosisController.text.isEmpty || _prescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in diagnosis and prescription'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSaved = true;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2B2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [Icon(Icons.check_circle, color: Colors.green, size: 28), SizedBox(width: 8), Text('Sent to Owner!', style: TextStyle(color: Colors.white))]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Visit summary has been saved and sent to:', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Pet: $_selectedPet', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('Owner: $_selectedOwner', style: const TextStyle(color: Colors.white)),
                Text('Phone: ${_petOwners.firstWhere((p) => p['pet'] == _selectedPet)['phone']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 12),
            const Row(children: [Icon(Icons.email, color: Colors.green, size: 16), SizedBox(width: 8), Text('Email sent successfully!', style: TextStyle(color: Colors.green, fontSize: 12))]),
            const Row(children: [Icon(Icons.message, color: Colors.green, size: 16), SizedBox(width: 8), Text('SMS notification sent!', style: TextStyle(color: Colors.green, fontSize: 12))]),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done', style: TextStyle(color: Color(0xFFF57C00))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(color: Color(0xFF2B2A2A), borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: Column(children: [
        Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2))),
        Padding(padding: const EdgeInsets.all(20), child: Row(children: [
          const Expanded(child: Text('Visit Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
          if (_isSaved) Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.check, color: Colors.green, size: 16), SizedBox(width: 4), Text('Sent', style: TextStyle(color: Colors.green, fontSize: 12))])),
        ])),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Select Pet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(spacing: 10, children: _petOwners.map((petData) => ChoiceChip(
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
            backgroundColor: Colors.white.withOpacity(0.1),
          )).toList()),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withOpacity(0.3))), child: Row(children: [const Icon(Icons.person, color: Colors.blue), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Owner: $_selectedOwner', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text(_petOwners.firstWhere((p) => p['pet'] == _selectedPet)['phone']!, style: const TextStyle(color: Colors.white70, fontSize: 12))])])),
          const SizedBox(height: 20),
          const Text('Diagnosis *', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(controller: _diagnosisController, maxLines: 3, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Enter diagnosis...', hintStyle: const TextStyle(color: Colors.white38), filled: true, fillColor: Colors.white.withOpacity(0.1), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
          const SizedBox(height: 20),
          const Text('Prescription *', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(controller: _prescriptionController, maxLines: 3, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Enter prescription...', hintStyle: const TextStyle(color: Colors.white38), filled: true, fillColor: Colors.white.withOpacity(0.1), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
          const SizedBox(height: 20),
          const Text('Additional Notes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(controller: _notesController, maxLines: 2, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Any additional instructions...', hintStyle: const TextStyle(color: Colors.white38), filled: true, fillColor: Colors.white.withOpacity(0.1), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
          const SizedBox(height: 20),
          const Text('Follow-up Date', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 7)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)), builder: (context, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: Color(0xFFF57C00))), child: child!));
              if (date != null) setState(() => _followUpDate = date);
            },
            child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.calendar_today, color: Colors.white70), const SizedBox(width: 12), Text(_followUpDate != null ? '${_followUpDate!.day}/${_followUpDate!.month}/${_followUpDate!.year}' : 'Select follow-up date...', style: TextStyle(color: _followUpDate != null ? Colors.white : Colors.white70))])),
          ),
          const SizedBox(height: 20),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.withOpacity(0.3))), child: const Row(children: [Icon(Icons.info_outline, color: Colors.orange, size: 20), SizedBox(width: 12), Expanded(child: Text('Summary will be sent to pet owner via email and SMS after saving.', style: TextStyle(color: Colors.orange, fontSize: 12)))])),
          const SizedBox(height: 30),
          Row(children: [
            Expanded(child: SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () { _diagnosisController.clear(); _prescriptionController.clear(); _notesController.clear(); setState(() { _followUpDate = null; _isSaved = false; }); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Clear', style: TextStyle(fontWeight: FontWeight.bold))))),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _saveAndSendToOwner, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF57C00), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Save & Send to Owner', style: TextStyle(fontWeight: FontWeight.bold))))),
          ]),
          const SizedBox(height: 20),
        ]))),
      ]),
    );
  }
}

class _PetDetailsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pets = [
      {'name': 'Max', 'type': 'Golden Retriever', 'age': '4 years', 'owner': 'Alex Johnson', 'phone': '+1 234 567 8901', 'lastVisit': 'Jan 28, 2026', 'condition': 'Healthy', 'vaccinations': 'Up to date'},
      {'name': 'Luna', 'type': 'Persian Cat', 'age': '2 years', 'owner': 'Sarah Miller', 'phone': '+1 234 567 8902', 'lastVisit': 'Jan 15, 2026', 'condition': 'Healthy', 'vaccinations': 'Up to date'},
      {'name': 'Charlie', 'type': 'Labrador', 'age': '6 years', 'owner': 'Mike Davis', 'phone': '+1 234 567 8903', 'lastVisit': 'Dec 20, 2025', 'condition': 'Arthritis', 'vaccinations': 'Due soon'},
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(color: Color(0xFF2B2A2A), borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: Column(children: [
        Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2))),
        const Padding(padding: EdgeInsets.all(20), child: Text('Pet Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
        Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 20), itemCount: pets.length, itemBuilder: (context, index) {
          final pet = pets[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 50, height: 50, decoration: BoxDecoration(color: const Color(0xFFF57C00).withOpacity(0.3), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.pets, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(pet['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), Text(pet['type']!, style: const TextStyle(color: Colors.white70))])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: pet['condition'] == 'Healthy' ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Text(pet['condition']!, style: TextStyle(color: pet['condition'] == 'Healthy' ? Colors.green : Colors.orange, fontSize: 12))),
              ]),
              const SizedBox(height: 16),
              _DetailRow(icon: Icons.person, label: 'Owner', value: pet['owner']!),
              _DetailRow(icon: Icons.phone, label: 'Phone', value: pet['phone']!),
              _DetailRow(icon: Icons.cake, label: 'Age', value: pet['age']!),
              _DetailRow(icon: Icons.calendar_today, label: 'Last Visit', value: pet['lastVisit']!),
              _DetailRow(icon: Icons.vaccines, label: 'Vaccinations', value: pet['vaccinations']!),
            ]),
          );
        })),
      ]),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Icon(icon, size: 16, color: Colors.white54), const SizedBox(width: 8), Text('$label: ', style: const TextStyle(color: Colors.white54)), Text(value, style: const TextStyle(color: Colors.white))]));
  }
}

class _AvailabilitySheet extends StatefulWidget {
  @override
  State<_AvailabilitySheet> createState() => _AvailabilitySheetState();
}

class _AvailabilitySheetState extends State<_AvailabilitySheet> {
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(color: Color(0xFF2B2A2A), borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: Column(children: [
        Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2))),
        const Padding(padding: EdgeInsets.all(20), child: Text('Set Availability', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Working Hours', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _TimeSelector(label: 'Start Time', time: _startTime, onTap: () async {
              final time = await showTimePicker(context: context, initialTime: _startTime);
              if (time != null) setState(() => _startTime = time);
            })),
            const SizedBox(width: 16),
            Expanded(child: _TimeSelector(label: 'End Time', time: _endTime, onTap: () async {
              final time = await showTimePicker(context: context, initialTime: _endTime);
              if (time != null) setState(() => _endTime = time);
            })),
          ]),
          const SizedBox(height: 30),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF57C00), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Save Availability', style: TextStyle(fontWeight: FontWeight.bold)))),
          const SizedBox(height: 20),
        ]))),
      ]),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;
  const _TimeSelector({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)), const SizedBox(height: 8), Text(time.format(context), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))])),
    );
  }
}

class _TodayAppointmentsSection extends StatelessWidget {
  const _TodayAppointmentsSection();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Today's Appointments", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 20),
      NeumorphicGlassContainer(child: const Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Max - Vaccination", style: TextStyle(color: Colors.white)), SizedBox(height: 5), Text("9:00 AM • Medium Care", style: TextStyle(color: Colors.white70))]))),
    ]);
  }
}

class _TrustScoreSection extends StatelessWidget {
  const _TrustScoreSection();

  static const int _trustScore = 98;
  static const int _totalAssignments = 156;
  static const int _completedAssignments = 152;
  static const int _onTimeCount = 148;
  static const int _frequentClientCount = 45;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Your Trust Score", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 20),
      NeumorphicGlassContainer(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _getTrustScoreColor(_trustScore), width: 5)), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('$_trustScore', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _getTrustScoreColor(_trustScore))), Text('out of 100', style: TextStyle(fontSize: 8, color: Colors.white.withOpacity(0.6)))]))),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Score Breakdown", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), const SizedBox(height: 12), _ScoreBreakdownItem(label: "Assignment Completion", value: _completedAssignments, total: _totalAssignments, maxPoints: 25), const SizedBox(height: 8), _ScoreBreakdownItem(label: "On Time Service", value: _onTimeCount, total: _completedAssignments, maxPoints: 25), const SizedBox(height: 8), _ScoreBreakdownItem(label: "Frequent Clients", value: _frequentClientCount, total: 30, maxPoints: 20)])),
        ]),
        const SizedBox(height: 20),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_StatItem(label: "Total Jobs", value: "$_totalAssignments"), _StatItem(label: "Completed", value: "$_completedAssignments"), _StatItem(label: "On Time", value: "$_onTimeCount"), _StatItem(label: "Frequent", value: "$_frequentClientCount")])),
      ]))),
    ]);
  }

  Color _getTrustScoreColor(int score) { if (score >= 95) return Colors.green; if (score >= 85) return Colors.blue; if (score >= 70) return Colors.orange; return Colors.red; }
}

class _ScoreBreakdownItem extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final double maxPoints;
  const _ScoreBreakdownItem({required this.label, required this.value, required this.total, required this.maxPoints});

  @override
  Widget build(BuildContext context) {
    final double percentage = total > 0 ? value / total : 0;
    final double points = percentage * maxPoints;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)), Text('${points.toStringAsFixed(1)}/$maxPoints', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))]),
      const SizedBox(height: 4),
      ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: percentage, backgroundColor: Colors.white.withOpacity(0.1), valueColor: AlwaysStoppedAnimation(percentage >= 0.9 ? Colors.green : percentage >= 0.7 ? Colors.blue : Colors.orange), minHeight: 4)),
    ]);
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF57C00))), Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54))]);
  }
}
