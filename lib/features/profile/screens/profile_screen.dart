import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/features/dashboard/owner_dashboard.dart';
import 'package:frontend/features/profile/screens/trust_score_page.dart';
import 'package:frontend/shared/widgets/glassy_components.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// --- Colors ---
const Color _primaryTextColor = Colors.white;
const Color _secondaryTextColor = Colors.white70;
const MaterialColor _accentColor = Colors.orange;
const Color _containerColor = Color.fromARGB(255, 43, 42, 42);
const Color _lightShadowColor = Color.fromARGB(255, 61, 60, 60);
const Color _darkShadowColor = Color.fromARGB(255, 23, 23, 23);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _nameController.text = prefs.getString('name') ?? '';
    _emailController.text = prefs.getString('email') ?? '';
    _phoneController.text = prefs.getString('phone') ?? '';
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('phone', _phoneController.text);

    // TODO: Update via API
    // final response = await http.put(
    //   Uri.parse('http://10.0.2.2:3000/api/users/${prefs.getString('id')}'),
    //   body: jsonEncode({
    //     'name': _nameController.text,
    //     'email': _emailController.text,
    //     'phone': _phoneController.text,
    //   }),
    // );

    if (mounted) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      // Reload dashboard to show updated name
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OwnerDashboard()),
      );
    }
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Profile',
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
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Profile Avatar
                  NeumorphicGlassContainer(
                    child: Stack(
                      children: [
                        const CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage('assets/images/dog_and_cat.jpg'),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: NeumorphicGlassContainer(
                            child: Icon(
                              Icons.camera_alt,
                              color: _accentColor,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Edit Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Profile Information',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _primaryTextColor,
                            ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _isEditing = !_isEditing;
                          });
                        },
                        icon: Icon(_isEditing ? Icons.close : Icons.edit, color: _accentColor),
                        label: Text(_isEditing ? 'Cancel' : 'Edit', style: TextStyle(color: _accentColor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Name Field
                  _buildProfileField(
                    label: 'Full Name',
                    controller: _nameController,
                    icon: Icons.person_outline,
                    isEditing: _isEditing,
                  ),
                  const SizedBox(height: 16),
                  // Email Field
                  _buildProfileField(
                    label: 'Email',
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    isEditing: _isEditing,
                  ),
                  const SizedBox(height: 16),
                  // Phone Field
                  _buildProfileField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    isEditing: _isEditing,
                  ),
                  const SizedBox(height: 32),
                  // Save Button
                  if (_isEditing)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Trust Score Section
                  NeumorphicGlassContainer(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.verified_user, color: Colors.blue, size: 28),
                              const SizedBox(width: 12),
                              const Text(
                                'Trust Score',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _primaryTextColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '92',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    'Excellent',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(Icons.arrow_forward, color: _secondaryTextColor),
                              Column(
                                children: [
                                  Text(
                                    '156',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: _primaryTextColor,
                                    ),
                                  ),
                                  Text(
                                    'Total Bookings',
                                    style: TextStyle(color: _secondaryTextColor),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TrustScorePage(userType: 'owner'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.analytics_outlined),
                            label: const Text('View Details'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: _primaryTextColor,
                              side: BorderSide(color: _lightShadowColor.withOpacity(0.5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    bool isEditing = false,
  }) {
    return NeumorphicGlassContainer(
      child: TextField(
        controller: controller,
        enabled: isEditing,
        keyboardType: keyboardType,
        style: const TextStyle(color: _primaryTextColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _secondaryTextColor),
          prefixIcon: Icon(icon, color: _secondaryTextColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _lightShadowColor.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _accentColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.transparent,
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _lightShadowColor.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

