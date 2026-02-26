import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/features/dashboard/owner_dashboard.dart';

class BookingPage extends StatefulWidget {
  final bool isEmergencyMode;
  
  const BookingPage({super.key, this.isEmergencyMode = false});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _startInEmergency = false;

  @override
  void initState() {
    super.initState();
    _startInEmergency = widget.isEmergencyMode;
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 2) {
        setState(() {
          _startInEmergency = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const OwnerDashboard()),
            );
          },
        ),
        title: Text(
          _startInEmergency ? 'Emergency Booking' : 'Book Service',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF57C00),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Veterinarian', icon: Icon(Icons.medical_services)),
            Tab(text: 'Caretaker', icon: Icon(Icons.pets)),
            Tab(
              text: '🚨 Emergency',
              icon: Icon(Icons.emergency, color: Colors.red),
            ),
          ],
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
            child: Column(
              children: [
                const SizedBox(height: 60),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProviderList('vet'),
                      _buildProviderList('caretaker'),
                      _buildEmergencyList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderList(String serviceType) {
    final List<Map<String, dynamic>> providers = serviceType == 'vet'
        ? _vetProviders
        : _caretakers;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: providers.length,
      itemBuilder: (context, index) {
        final provider = providers[index];
        return _ProviderCard(
          provider: provider,
          serviceType: serviceType,
          onBook: () => _showBookingDialog(provider, serviceType, false),
          onShowTrustScore: () => _showTrustScoreDialog(provider),
        );
      },
    );
  }

  Widget _buildEmergencyList() {
    final List<Map<String, dynamic>> emergencyCaretakers = 
        _caretakers.where((c) => c['emergencyAvailable'] == true).toList();

    if (emergencyCaretakers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emergency_outlined,
              size: 64,
              color: Colors.red.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No emergency caretakers available',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check regular caretaker booking',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: emergencyCaretakers.length,
      itemBuilder: (context, index) {
        final provider = emergencyCaretakers[index];
        return _ProviderCard(
          provider: provider,
          serviceType: 'caretaker',
          isEmergency: true,
          onBook: () => _showBookingDialog(provider, 'caretaker', true),
          onShowTrustScore: () => _showTrustScoreDialog(provider),
        );
      },
    );
  }

  void _showTrustScoreDialog(Map<String, dynamic> provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _TrustScoreSheet(provider: provider),
    );
  }

  void _showBookingDialog(
      Map<String, dynamic> provider, String serviceType, bool isEmergency) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _BookingFormSheet(
        provider: provider,
        serviceType: serviceType,
        isEmergency: isEmergency,
      ),
    );
  }

  final List<Map<String, dynamic>> _vetProviders = [
    {
      'name': 'Dr. Sarah Chen',
      'specialization': 'General Medicine',
      'experience': '12 years',
      'image': 'assets/images/dog_and_cat.jpg',
      'availability': 'Mon-Sat',
      'price': 400,
      'trustScore': 98,
      'totalAssignments': 156,
      'completedAssignments': 152,
      'onTimeCount': 148,
      'frequentClientCount': 45,
    },
    {
      'name': 'Dr. Michael Roberts',
      'specialization': 'Surgery',
      'experience': '15 years',
      'image': 'assets/images/dog_and_cat.jpg',
      'availability': 'Mon-Fri',
      'price': 600,
      'trustScore': 95,
      'totalAssignments': 203,
      'completedAssignments': 195,
      'onTimeCount': 190,
      'frequentClientCount': 62,
    },
    {
      'name': 'Dr. Emily Watson',
      'specialization': 'Dental Care',
      'experience': '8 years',
      'image': 'assets/images/dog_and_cat.jpg',
      'availability': 'Tue-Sat',
      'price': 550,
      'trustScore': 92,
      'totalAssignments': 89,
      'completedAssignments': 84,
      'onTimeCount': 82,
      'frequentClientCount': 28,
    },
  ];

  final List<Map<String, dynamic>> _caretakers = [
    {
      'name': 'James Wilson',
      'specialization': 'Dog Walking & Sitting',
      'experience': '5 years',
      'image': 'assets/images/dog_and_cat.jpg',
      'availability': 'Daily',
      'price': 750,
      'trustScore': 94,
      'totalAssignments': 312,
      'completedAssignments': 298,
      'onTimeCount': 295,
      'frequentClientCount': 78,
      'emergencyAvailable': true,
    },
    {
      'name': 'Maria Garcia',
      'specialization': 'Pet Grooming',
      'experience': '7 years',
      'image': 'assets/images/dog_and_cat.jpg',
      'availability': 'Mon-Sat',
      'price': 360,
      'trustScore': 97,
      'totalAssignments': 425,
      'completedAssignments': 418,
      'onTimeCount': 415,
      'frequentClientCount': 95,
      'emergencyAvailable': true,
    },
    {
      'name': 'David Brown',
      'specialization': 'Overnight Care',
      'experience': '3 years',
      'image': 'assets/images/dog_and_cat.jpg',
      'availability': 'Daily',
      'price': 499,
      'trustScore': 89,
      'totalAssignments': 124,
      'completedAssignments': 115,
      'onTimeCount': 110,
      'frequentClientCount': 32,
      'emergencyAvailable': false,
    },
  ];
}

class _ProviderCard extends StatelessWidget {
  final Map<String, dynamic> provider;
  final String serviceType;
  final bool isEmergency;
  final VoidCallback onBook;
  final VoidCallback onShowTrustScore;

  const _ProviderCard({
    required this.provider,
    required this.serviceType,
    this.isEmergency = false,
    required this.onBook,
    required this.onShowTrustScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isEmergency 
            ? Colors.red.withOpacity(0.15)
            : Colors.white.withOpacity(0.1),
        border: Border.all(
          color: isEmergency 
              ? Colors.red.withOpacity(0.5)
              : Colors.white.withOpacity(0.2),
          width: isEmergency ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isEmergency 
                ? Colors.red.withOpacity(0.3)
                : Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: AssetImage(provider['image']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  provider['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (isEmergency)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.emergency,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'EMERGENCY',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            provider['specialization'],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: onShowTrustScore,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getTrustScoreColor(provider['trustScore'])
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.verified_user,
                                        color: _getTrustScoreColor(provider['trustScore']),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        ' Trust: ${provider['trustScore']}/100',
                                        style: TextStyle(
                                          color: _getTrustScoreColor(provider['trustScore']),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.info_outline,
                                  color: Colors.white54,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _InfoChip(icon: Icons.work_history, label: provider['experience']),
                    const SizedBox(width: 12),
                    _InfoChip(icon: Icons.schedule, label: provider['availability']),
                    if (provider['emergencyAvailable'] == true) ...[
                      const SizedBox(width: 12),
                      _InfoChip(icon: Icons.emergency, label: '24/7', color: Colors.red),
                    ],
                    const Spacer(),
                    Text(
                      '₹${provider['price']}/visit',
                      style: const TextStyle(
                        color: Color(0xFFF57C00),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: onBook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEmergency ? Colors.red : const Color(0xFFF57C00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isEmergency ? 'Book Emergency Now' : 'Book Now',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTrustScoreColor(int score) {
    if (score >= 95) return Colors.green;
    if (score >= 85) return Colors.blue;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? Colors.white70),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color ?? Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _TrustScoreSheet extends StatelessWidget {
  final Map<String, dynamic> provider;

  const _TrustScoreSheet({required this.provider});

  @override
  Widget build(BuildContext context) {
    final int trustScore = provider['trustScore'];
    final int totalAssignments = provider['totalAssignments'] ?? 0;
    final int completedAssignments = provider['completedAssignments'] ?? 0;
    final int onTimeCount = provider['onTimeCount'] ?? 0;
    final int frequentClientCount = provider['frequentClientCount'] ?? 0;

    final double assignmentCompletion = totalAssignments > 0 
        ? (completedAssignments / totalAssignments) * 25 : 0;
    final double onTimeScore = completedAssignments > 0 
        ? (onTimeCount / completedAssignments) * 25 : 0;
    final double frequentVisits = frequentClientCount >= 30 
        ? 20.0 : (frequentClientCount / 30) * 20;
    final double reliability = trustScore - assignmentCompletion - onTimeScore - frequentVisits;
    final double communication = reliability > 0 ? reliability * 0.5 : 0;
    final double professionalism = reliability > 0 ? reliability * 0.5 : 0;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2B2A2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(provider['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider['name'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        provider['specialization'],
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getTrustScoreColor(trustScore),
                        width: 6,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$trustScore',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: _getTrustScoreColor(trustScore),
                            ),
                          ),
                          Text(
                            'out of 100',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Trust Score',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getTrustScoreColor(trustScore),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Score Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _ScoreRow(icon: Icons.check_circle, label: 'Assignment Completion', value: assignmentCompletion, maxValue: 25, totalAssignments: totalAssignments, completedAssignments: completedAssignments),
            const SizedBox(height: 12),
            _ScoreRow(icon: Icons.access_time, label: 'On Time Service', value: onTimeScore, maxValue: 25, totalAssignments: completedAssignments, completedAssignments: onTimeCount),
            const SizedBox(height: 12),
            _ScoreRow(icon: Icons.replay, label: 'Frequent Clients', value: frequentVisits, maxValue: 20, totalAssignments: 30, completedAssignments: frequentClientCount),
            const SizedBox(height: 12),
            _ScoreRow(icon: Icons.chat_bubble, label: 'Communication', value: communication, maxValue: 15),
            const SizedBox(height: 12),
            _ScoreRow(icon: Icons.star, label: 'Professionalism', value: professionalism, maxValue: 15),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Statistics', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(label: 'Total Jobs', value: '$totalAssignments'),
                      _StatItem(label: 'Completed', value: '$completedAssignments'),
                      _StatItem(label: 'On Time', value: '$onTimeCount'),
                      _StatItem(label: 'Frequent', value: '$frequentClientCount'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Color _getTrustScoreColor(int score) {
    if (score >= 95) return Colors.green;
    if (score >= 85) return Colors.blue;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }
}

class _ScoreRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final double maxValue;
  final int? totalAssignments;
  final int? completedAssignments;

  const _ScoreRow({required this.icon, required this.label, required this.value, required this.maxValue, this.totalAssignments, this.completedAssignments});

  @override
  Widget build(BuildContext context) {
    final double percentage = maxValue > 0 ? (value / maxValue) : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.white70),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white70))),
            Text('${value.toStringAsFixed(1)}/$maxValue', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(percentage >= 0.8 ? Colors.green : percentage >= 0.6 ? Colors.blue : Colors.orange),
            minHeight: 6,
          ),
        ),
        if (totalAssignments != null && completedAssignments != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text('$completedAssignments / $totalAssignments', style: const TextStyle(color: Colors.white54, fontSize: 11)),
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
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF57C00))),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
      ],
    );
  }
}

class _BookingFormSheet extends StatefulWidget {
  final Map<String, dynamic> provider;
  final String serviceType;
  final bool isEmergency;

  const _BookingFormSheet({required this.provider, required this.serviceType, this.isEmergency = false});

  @override
  _BookingFormSheetState createState() => _BookingFormSheetState();
}

class _BookingFormSheetState extends State<_BookingFormSheet> {
  late DateTime _selectedDate;
  late String _selectedTime;
  String _petName = 'Max';
  String _careLevel = 'Medium';
  String _notes = 'Vaccination Done.';
  String _selectedPayment = 'Pay at Clinic';

  final List<String> _times = ['9:00 AM', '10:00 AM', '11:00 AM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM'];
  final List<String> _emergencyTimes = ['Immediate', 'Within 1 hour', 'Within 2 hours', 'Within 4 hours'];
  final List<String> _pets = ['Max', 'Luna', 'Charlie'];
  final List<String> _careLevels = ['Low', 'Medium', 'High'];
  final List<String> _paymentOptions = [ 'Cash', 'UPI', 'Card Payment' ];

  @override
  void initState() {
    super.initState();
    if (widget.isEmergency) {
      _selectedDate = DateTime.now();
      _selectedTime = 'Immediate';
    } else {
      _selectedDate = DateTime.now().add(const Duration(days: 1));
      _selectedTime = '10:00 AM';
    }
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
              color: widget.isEmergency ? Colors.red : Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (widget.isEmergency) const Icon(Icons.emergency, color: Colors.red, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.isEmergency ? 'Emergency Booking - ${widget.provider['name']}' : 'Book ${widget.provider['name']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: widget.isEmergency ? Colors.red : Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
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
                  if (widget.isEmergency) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.5)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.red),
                          SizedBox(width: 12),
                          Expanded(child: Text('This is an emergency booking. The caretaker has been notified and will respond immediately.', style: TextStyle(color: Colors.red, fontSize: 14))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  const Text('Select Pet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildPetSelector(),
                  const SizedBox(height: 20),
                  if (!widget.isEmergency) ...[
                    const Text('Select Date', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildDateSelector(),
                    const SizedBox(height: 20),
                  ],
                  Text(widget.isEmergency ? 'Response Time Needed' : 'Select Time', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildTimeSelector(),
                  const SizedBox(height: 20),
                  const Text('Care Level', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildCareLevelSelector(),
                  const SizedBox(height: 20),
                  Text(widget.isEmergency ? 'Emergency Notes / Situation' : 'Additional Notes', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                    maxLines: widget.isEmergency ? 4 : 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: widget.isEmergency ? 'Describe the emergency situation...' : 'Any special instructions...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onChanged: (value) => _notes = value,
                  ),
                  const SizedBox(height: 20),
                  const Text('Payment Option', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildPaymentSelector(),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('₹${widget.provider['price']}', style: const TextStyle(color: Color(0xFFF57C00), fontWeight: FontWeight.bold, fontSize: 24)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isEmergency ? Colors.red : const Color(0xFFF57C00),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  widget.isEmergency ? 'Confirm Emergency Booking' : 'Confirm Booking',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetSelector() {
    return Wrap(
      spacing: 10,
      children: _pets.map((pet) => ChoiceChip(
        label: Text(pet),
        selected: _petName == pet,
        onSelected: (selected) => setState(() => _petName = pet),
        selectedColor: const Color(0xFFF57C00),
        backgroundColor: Colors.white.withOpacity(0.1),
        labelStyle: TextStyle(color: _petName == pet ? Colors.white : Colors.white70),
      )).toList(),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 60)),
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: Color(0xFFF57C00))),
            child: child!,
          ),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.white70),
            const SizedBox(width: 12),
            Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: const TextStyle(color: Colors.white, fontSize: 16)),
            const Spacer(),
            const Icon(Icons.arrow_drop_down, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    final times = widget.isEmergency ? _emergencyTimes : _times;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: times.map((time) => ChoiceChip(
        label: Text(time),
        selected: _selectedTime == time,
        onSelected: (selected) => setState(() => _selectedTime = time),
        selectedColor: widget.isEmergency ? Colors.red : const Color(0xFFF57C00),
        backgroundColor: Colors.white.withOpacity(0.1),
        labelStyle: TextStyle(color: _selectedTime == time ? Colors.white : Colors.white70),
      )).toList(),
    );
  }

  Widget _buildCareLevelSelector() {
    return Wrap(
      spacing: 10,
      children: _careLevels.map((level) => ChoiceChip(
        label: Text(level),
        selected: _careLevel == level,
        onSelected: (selected) => setState(() => _careLevel = level),
        selectedColor: const Color(0xFFF57C00),
        backgroundColor: Colors.white.withOpacity(0.1),
        labelStyle: TextStyle(color: _careLevel == level ? Colors.white : Colors.white70),
      )).toList(),
    );
  }

  Widget _buildPaymentSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _paymentOptions.map((option) => ChoiceChip(
        label: Text(option),
        selected: _selectedPayment == option,
        onSelected: (selected) => setState(() => _selectedPayment = option),
        selectedColor: const Color(0xFFF57C00),
        backgroundColor: Colors.white.withOpacity(0.1),
        labelStyle: TextStyle(color: _selectedPayment == option ? Colors.white : Colors.white70),
      )).toList(),
    );
  }

  void _confirmBooking() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2B2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            if (widget.isEmergency) const Icon(Icons.check_circle, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text(widget.isEmergency ? 'Emergency Booked!' : 'Booking Confirmed!', style: TextStyle(color: widget.isEmergency ? Colors.red : Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEmergency ? 'Emergency request sent to ${widget.provider['name']}. They will contact you immediately!' : 'Your booking with ${widget.provider['name']} has been confirmed.',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            if (!widget.isEmergency) Text('Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: const TextStyle(color: Colors.white)),
            Text(widget.isEmergency ? 'Response: $_selectedTime' : 'Time: $_selectedTime', style: const TextStyle(color: Colors.white)),
            Text('Pet: $_petName', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text('Payment: $_selectedPayment', style: const TextStyle(color: Colors.white)),
            Text('Amount: ₹${widget.provider['price']}', style: const TextStyle(color: Color(0xFFF57C00), fontWeight: FontWeight.bold)),
            if (widget.isEmergency) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.phone, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Text('Keep your phone nearby!', style: TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OwnerDashboard()));
            },
            child: Text('Done', style: TextStyle(color: widget.isEmergency ? Colors.red : const Color(0xFFF57C00))),
          ),
        ],
      ),
    );
  }
}