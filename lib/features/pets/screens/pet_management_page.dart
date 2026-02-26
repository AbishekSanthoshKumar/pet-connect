import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/features/dashboard/owner_dashboard.dart';

class PetManagementPage extends StatefulWidget {
  const PetManagementPage({super.key});

  @override
  _PetManagementPageState createState() => _PetManagementPageState();
}

class _PetManagementPageState extends State<PetManagementPage> {
  final List<Map<String, dynamic>> _pets = [
    {
      'name': 'Max',
      'type': 'Dog',
      'breed': 'Golden Retriever',
      'age': '4 years',
      'weight': '30 kg',
      'image': 'assets/images/pet-dog.jpg',
      'status': 'Healthy',
      'vaccinations': 'Up to date',
      'allergies': 'None',
      'careLevel': 'Medium',
    },
    {
      'name': 'Luna',
      'type': 'Cat',
      'breed': 'Persian',
      'age': '2 years',
      'weight': '4 kg',
      'image': 'assets/images/pet-cat.jpg',
      'status': 'Healthy',
      'vaccinations': 'Up to date',
      'allergies': 'Fish',
      'careLevel': 'Low',
    },
  ];

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
          'My Pets',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: () => _showAddPetDialog(),
          ),
        ],
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
            child: _pets.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pets.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _pets.length) {
                        return _buildAddPetCard();
                      }
                      return _PetCard(
                        pet: _pets[index],
                        onEdit: () => _showEditPetDialog(_pets[index]),
                        onDelete: () => _deletePet(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No pets added yet',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first pet to get started',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddPetDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Pet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF57C00),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPetCard() {
    return GestureDetector(
      onTap: () => _showAddPetDialog(),
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.add,
                size: 32,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Add New Pet',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPetDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PetFormSheet(
        onSave: (pet) {
          setState(() {
            _pets.add(pet);
          });
        },
      ),
    );
  }

  void _showEditPetDialog(Map<String, dynamic> pet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PetFormSheet(
        pet: pet,
        onSave: (updatedPet) {
          setState(() {
            final index = _pets.indexOf(pet);
            if (index != -1) {
              _pets[index] = updatedPet;
            }
          });
        },
      ),
    );
  }

  void _deletePet(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2B2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Pet?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to remove ${_pets[index]['name']}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _pets.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final Map<String, dynamic> pet;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PetCard({
    required this.pet,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet Image Header
              Container(
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(pet['image']),
                    fit: BoxFit.cover,
                    colorFilter:
                        ColorFilter.mode(Colors.black38, BlendMode.darken),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Row(
                        children: [
                          _ActionButton(
                            icon: Icons.edit,
                            onTap: onEdit,
                          ),
                          const SizedBox(width: 8),
                          _ActionButton(
                            icon: Icons.delete,
                            onTap: onDelete,
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(pet['status']).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.health_and_safety,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              pet['status'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Pet Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pet['name'],
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${pet['breed']} • ${pet['age']}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF57C00).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${pet['careLevel']} Care',
                            style: const TextStyle(
                              color: Color(0xFFF57C00),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _InfoItem(icon: Icons.monitor_weight, value: pet['weight']),
                        const SizedBox(width: 24),
                        _InfoItem(
                            icon: Icons.vaccines, value: pet['vaccinations']),
                      ],
                    ),
                    if (pet['allergies'] != 'None') ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.warning_amber,
                              size: 16, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            'Allergies: ${pet["allergies"]}',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Healthy':
        return Colors.green;
      case 'Under Treatment':
        return Colors.orange;
      case 'Critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color ?? Colors.white),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String value;

  const _InfoItem({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white54),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}

class _PetFormSheet extends StatefulWidget {
  final Map<String, dynamic>? pet;
  final Function(Map<String, dynamic>) onSave;

  const _PetFormSheet({
    this.pet,
    required this.onSave,
  });

  @override
  _PetFormSheetState createState() => _PetFormSheetState();
}

class _PetFormSheetState extends State<_PetFormSheet> {
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _allergiesController;
  String _selectedType = 'Dog';
  String _selectedCareLevel = 'Medium';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet?['name'] ?? '');
    _breedController = TextEditingController(text: widget.pet?['breed'] ?? '');
    _ageController = TextEditingController(text: widget.pet?['age'] ?? '');
    _weightController = TextEditingController(text: widget.pet?['weight'] ?? '');
    _allergiesController =
        TextEditingController(text: widget.pet?['allergies'] ?? 'None');
    _selectedType = widget.pet?['type'] ?? 'Dog';
    _selectedCareLevel = widget.pet?['careLevel'] ?? 'Medium';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF2B2A2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  widget.pet == null ? 'Add New Pet' : 'Edit Pet',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pet Type
                  const Text(
                    'Pet Type',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _TypeChip(
                        label: '🐕 Dog',
                        isSelected: _selectedType == 'Dog',
                        onTap: () => setState(() => _selectedType = 'Dog'),
                      ),
                      const SizedBox(width: 10),
                      _TypeChip(
                        label: '🐈 Cat',
                        isSelected: _selectedType == 'Cat',
                        onTap: () => setState(() => _selectedType = 'Cat'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Name
                  _buildTextField('Pet Name', _nameController),
                  const SizedBox(height: 16),

                  // Breed
                  _buildTextField('Breed', _breedController),
                  const SizedBox(height: 16),

                  // Age & Weight Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField('Age', _ageController,
                            hint: 'e.g., 3 years'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField('Weight', _weightController,
                            hint: 'e.g., 15 kg'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Care Level
                  const Text(
                    'Care Level',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: ['Low', 'Medium', 'High'].map((level) {
                      return ChoiceChip(
                        label: Text(level),
                        selected: _selectedCareLevel == level,
                        onSelected: (selected) {
                          setState(() => _selectedCareLevel = level);
                        },
                        selectedColor: const Color(0xFFF57C00),
                        backgroundColor: Colors.white.withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: _selectedCareLevel == level
                              ? Colors.white
                              : Colors.white70,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Allergies
                  _buildTextField('Allergies', _allergiesController,
                      hint: 'e.g., Chicken, Fish'),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          // Save Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _savePet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF57C00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  widget.pet == null ? 'Add Pet' : 'Save Changes',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  void _savePet() {
    final pet = {
      'name': _nameController.text,
      'type': _selectedType,
      'breed': _breedController.text,
      'age': _ageController.text,
      'weight': _weightController.text,
      'image': _selectedType == 'Dog'
          ? 'assets/images/pet-dog.jpg'
          : 'assets/images/pet-cat.jpg',
      'status': 'Healthy',
      'vaccinations': 'Up to date',
      'allergies': _allergiesController.text.isEmpty
          ? 'None'
          : _allergiesController.text,
      'careLevel': _selectedCareLevel,
    };
    widget.onSave(pet);
    Navigator.pop(context);
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF57C00).withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFF57C00) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
