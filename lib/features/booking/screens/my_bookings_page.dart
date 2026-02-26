import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/features/dashboard/owner_dashboard.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  _MyBookingsPageState createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text(
          'My Bookings',
          style: TextStyle(
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
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
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
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(_upcomingBookings, 'upcoming'),
                _buildBookingList(_completedBookings, 'completed'),
                _buildBookingList(_cancelledBookings, 'cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList(List<Map<String, dynamic>> bookings, String type) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'upcoming' ? Icons.calendar_today : 
              type == 'completed' ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: 64,
              color: Colors.white30,
            ),
            const SizedBox(height: 16),
            Text(
              type == 'upcoming' ? 'No upcoming bookings' :
              type == 'completed' ? 'No completed bookings' : 'No cancelled bookings',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _BookingCard(booking: booking, type: type);
      },
    );
  }

  final List<Map<String, dynamic>> _upcomingBookings = [
    {
      'id': '1',
      'providerName': 'Dr. Sarah Chen',
      'providerType': 'Vet',
      'specialization': 'General Medicine',
      'petName': 'Max',
      'date': 'Feb 15, 2026',
      'time': '10:00 AM',
      'status': 'confirmed',
      'price': 80,
      'image': 'assets/images/dog_and_cat.jpg',
      'trustScore': 98,
      'address': '123 Pet Clinic, Downtown',
      'notes': 'Annual checkup',
    },
    {
      'id': '2',
      'providerName': 'James Wilson',
      'providerType': 'Caretaker',
      'specialization': 'Dog Walking',
      'petName': 'Max',
      'date': 'Feb 18, 2026',
      'time': '2:00 PM',
      'status': 'confirmed',
      'price': 30,
      'image': 'assets/images/dog_and_cat.jpg',
      'trustScore': 94,
      'address': 'Home Service',
      'notes': 'Morning and evening walk',
    },
    {
      'id': '3',
      'providerName': 'Maria Garcia',
      'providerType': 'Caretaker',
      'specialization': 'Pet Grooming',
      'petName': 'Luna',
      'date': 'Feb 20, 2026',
      'time': '11:00 AM',
      'status': 'pending',
      'price': 45,
      'image': 'assets/images/dog_and_cat.jpg',
      'trustScore': 97,
      'address': '456 Grooming Salon, West Side',
      'notes': 'Full grooming package',
    },
  ];

  final List<Map<String, dynamic>> _completedBookings = [
    {
      'id': '4',
      'providerName': 'Dr. Emily Watson',
      'providerType': 'Vet',
      'specialization': 'Dental Care',
      'petName': 'Luna',
      'date': 'Jan 28, 2026',
      'time': '3:00 PM',
      'status': 'completed',
      'price': 90,
      'image': 'assets/images/dog_and_cat.jpg',
      'trustScore': 92,
      'address': '789 Pet Dental Center',
      'notes': 'Teeth cleaning completed',
      'reviewGiven': true,
    },
    {
      'id': '5',
      'providerName': 'James Wilson',
      'providerType': 'Caretaker',
      'specialization': 'Overnight Care',
      'petName': 'Max',
      'date': 'Jan 20-22, 2026',
      'time': 'Full Weekend',
      'status': 'completed',
      'price': 150,
      'image': 'assets/images/dog_and_cat.jpg',
      'trustScore': 94,
      'address': 'Home Service',
      'notes': 'Weekend pet sitting',
      'reviewGiven': false,
    },
  ];

  final List<Map<String, dynamic>> _cancelledBookings = [
    {
      'id': '6',
      'providerName': 'David Brown',
      'providerType': 'Caretaker',
      'specialization': 'Overnight Care',
      'petName': 'Max',
      'date': 'Feb 10, 2026',
      'time': '5:00 PM',
      'status': 'cancelled',
      'price': 50,
      'image': 'assets/images/dog_and_cat.jpg',
      'trustScore': 89,
      'address': 'Home Service',
      'notes': 'Cancelled due to schedule conflict',
      'cancelledBy': 'You',
    },
  ];
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final String type;

  const _BookingCard({required this.booking, required this.type});

  @override
  Widget build(BuildContext context) {
    final bool isUpcoming = type == 'upcoming';
    final bool isCompleted = type == 'completed';
    
    Color statusColor;
    String statusText;
    switch (booking['status']) {
      case 'confirmed':
        statusColor = Colors.green;
        statusText = 'Confirmed';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusText = 'Completed';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Cancelled';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
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
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: AssetImage(booking['image']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking['providerName'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${booking['providerType']} • ${booking['specialization']}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Pet Info with Trust Score
                Row(
                  children: [
                    const Icon(Icons.pets, size: 16, color: Colors.white70),
                    const SizedBox(width: 8),
                    Text(
                      'Pet: ${booking['petName']}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTrustScoreColor(booking['trustScore']).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user,
                            size: 12,
                            color: _getTrustScoreColor(booking['trustScore']),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${booking['trustScore']}',
                            style: TextStyle(
                              color: _getTrustScoreColor(booking['trustScore']),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Date & Time
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
                    const SizedBox(width: 8),
                    Text(
                      booking['date'],
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, size: 16, color: Colors.white70),
                    const SizedBox(width: 8),
                    Text(
                      booking['time'],
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Address
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.white70),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking['address'],
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Notes
                Row(
                  children: [
                    const Icon(Icons.note, size: 16, color: Colors.white70),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking['notes'],
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${booking['price']}',
                      style: const TextStyle(
                        color: Color(0xFFF57C00),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isUpcoming) ...[
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.2),
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF57C00),
                        ),
                        child: const Text('Reschedule'),
                      ),
                    ],
                    if (isCompleted && booking['reviewGiven'] == false)
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF57C00),
                        ),
                        child: const Text('Leave Review'),
                      ),
                    if (booking['reviewGiven'] == true)
                      const Row(
                        children: [
                          Icon(Icons.verified_user, color: Colors.green, size: 18),
                          SizedBox(width: 4),
                          Text('Review Given', style: TextStyle(color: Colors.green)),
                        ],
                      ),
                  ],
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
