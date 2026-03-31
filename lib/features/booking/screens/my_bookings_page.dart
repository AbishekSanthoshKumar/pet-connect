import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/features/dashboard/owner_dashboard.dart';
import 'package:frontend/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  _MyBookingsPageState createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadBookings();
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
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
              type == 'upcoming'
                  ? Icons.calendar_today
                  : type == 'completed'
                  ? Icons.check_circle_outline
                  : Icons.cancel_outlined,
              size: 64,
              color: Colors.white30,
            ),
            const SizedBox(height: 16),
            Text(
              type == 'upcoming'
                  ? 'No upcoming bookings'
                  : type == 'completed'
                  ? 'No completed bookings'
                  : 'No cancelled bookings',
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
        return _BookingCard(
          booking: booking,
          type: type,
          onCancel: () => _cancelBooking(context, booking['id']),
        );
      },
    );
  }

  List<Map<String, dynamic>> _upcomingBookings = [];
  List<Map<String, dynamic>> _completedBookings = [];
  List<Map<String, dynamic>> _cancelledBookings = [];

  bool isLoading = true;

  Future<void> loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");

    if (userId == null) return;

    try {
      final data = await ApiService.getBookingsByOwner(userId);

      List<Map<String, dynamic>> upcoming = [];
      List<Map<String, dynamic>> completed = [];
      List<Map<String, dynamic>> cancelled = [];

      print("data ${data.length}");

      for (var b in data) {
        // Handle potential null or different date formats
        String formattedDate = "N/A";
        String formattedTime = "N/A";

        print("b $b");

        if (b["booking_date"] != null) {
          DateTime parsedDate = DateTime.parse(b["booking_date"]);
          formattedDate = DateFormat("MMM dd, yyyy").format(parsedDate);
        }

        formattedTime = b["booking_time"] ?? "N/A";

        final booking = {
          "id": b["booking_id"].toString(),
          "providerName": b["provider_name"] ?? "Unknown",
          "providerType": b["role"]?.toString().toUpperCase() ?? "Provider",
          "specialization": b["specialization"] ?? "",
          "petName": b["pet_name"] ?? "",
          "date": b["date"],
          "time": b["time"],
          "status": b["status"]?.toString().toLowerCase() ?? "pending",
          "price": b["service_fee"]?.toString() ?? "0",
          "image": "assets/images/dog_and_cat.jpg",
          "trustScore": b["trust_score"] ?? 0,
          "address":b["address"],
          "notes": b["details"] ?? "",
          "paymentStatus": "pending",
          "reviewGiven": false,
        };

        if (booking["status"] == "pending" ||
            booking["status"] == "accepted" ||
            booking["status"] == "confirmed" ||
            booking["status"] == "emergency") {
          upcoming.add(booking);
        } else if (booking["status"] == "completed" ||
            booking["status"] == "finished") {
          completed.add(booking);
        } else if (booking["status"] == "cancelled" ||
            booking["status"] == "rejected") {
          cancelled.add(booking);
        }
      }

      setState(() {
        _upcomingBookings = upcoming;
        _completedBookings = completed;
        _cancelledBookings = cancelled;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _cancelBooking(BuildContext context, String bookingId) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2B2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cancel Booking',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure? This will decrease the provider\'s trust score.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldCancel != true) return;

    try {
      await ApiService.cancelBooking(int.parse(bookingId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled! Provider Trust Score -5 📉'),
            backgroundColor: Colors.redAccent,
          ),
        );
        loadBookings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Cancel failed: $e')));
      }
    }
  }

  Future<void> _togglePayment(
    BuildContext context,
    String bookingId,
    String currentStatus,
  ) async {
    final newStatus = currentStatus == 'pending' ? 'paid' : 'pending';
    try {
      await ApiService.updatePaymentStatus(int.parse(bookingId), newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment status updated to ${newStatus.toUpperCase()}',
            ),
          ),
        );
        loadBookings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    }
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final String type;
  final VoidCallback? onCancel;

  const _BookingCard({
    required this.booking,
    required this.type,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUpcoming = type == 'upcoming';
    final bool isCompleted = type == 'completed';

    Color statusColor;
    String statusText;
    switch (booking['status']) {
      case 'emergency':
        statusColor = Colors.redAccent;
        statusText = 'Emergency';
        break;
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
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
                    if (booking['trustScore'] > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getTrustScoreColor(
                            booking['trustScore'],
                          ).withOpacity(0.2),
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
                                color: _getTrustScoreColor(
                                  booking['trustScore'],
                                ),
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
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      booking['date'],
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.white70,
                    ),
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
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking['address'],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
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
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Price
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    if ((double.tryParse(booking['price'].toString()) ?? 0) > 0)
                      Text(
                        'Amount: ₹${booking['price']}',
                        style: const TextStyle(
                          color: Color(0xFFF57C00),
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      const Text(
                        'Amount: TBD',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(width: 16),
                    if (isUpcoming) ...[
                      ElevatedButton(
                        onPressed: () {
                          // Say not possible now
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Sorry"),
                                content: const Text(
                                  "This action is restricted at the moment!.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.2),
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Say not possible now
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Sorry"),
                                content: const Text(
                                  "This action is restricted at the moment!.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF57C00),
                        ),
                        child: const Text('Reschedule'),
                      ),
                      SizedBox(width: 16),
                    ],
                    if (isCompleted && booking['reviewGiven'] == false) ...[
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF57C00),
                        ),
                        child: const Text('Leave Review'),
                      ),
                      SizedBox(width: 16),
                    ],
                    if (booking['reviewGiven'] == true) ...[
                      const Row(
                        children: [
                          Icon(
                            Icons.verified_user,
                            color: Colors.green,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Review Given',
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                      SizedBox(width: 16),
                    ],
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
