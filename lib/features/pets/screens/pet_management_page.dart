import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/features/dashboard/owner_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/services/api_service.dart';

class PetManagementPage extends StatefulWidget {
  const PetManagementPage({super.key});

  @override
  _PetManagementPageState createState() => _PetManagementPageState();
}

class _PetManagementPageState extends State<PetManagementPage> {
  List<dynamic> _pets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPets();
  }

  Future<void> fetchPets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      final pets = await ApiService.getPets(userId!);

      setState(() {
        _pets = pets;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching pets: $e");
    }
  }

  Future<void> addPetToBackend(Map<String, dynamic> pet) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      await ApiService.addPet({...pet, "ownerId": userId});

      fetchPets();
    } catch (e) {
      print("Error adding pet: $e");
    }
  }

  Future<void> deletePetFromBackend(int id) async {
    try {
      await ApiService.deletePet(id);
      fetchPets();
    } catch (e) {
      print("Error deleting pet: $e");
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
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const OwnerDashboard()),
            );
          },
        ),
        title: const Text(
          'My Pets',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _pets.isEmpty
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
                        onEdit: () {}, // keep UI, backend later
                        onDelete: () =>
                            deletePetFromBackend(_pets[index]['id']),
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
          Icon(Icons.pets, size: 80, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'No pets added yet',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first pet to get started',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddPetDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Pet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF57C00),
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
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          children: const [
            Icon(Icons.add, size: 32, color: Colors.white70),
            SizedBox(height: 12),
            Text(
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
          addPetToBackend({
            "name": pet['name'],
            "breed": pet['breed'],
            "type": pet['type'],
            "age": int.parse(pet['age']),
            "weight": double.parse(pet['weight']),
          });
        },
      ),
    );
  }
}

/* ================= PET CARD ================= */

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
    return ListTile(
      title: Text(
        pet['name'] ?? '',
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        pet['breed'] ?? '',
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: onDelete,
      ),
    );
  }
}

/* ================= FORM ================= */

class _PetFormSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const _PetFormSheet({required this.onSave});

  @override
  State<_PetFormSheet> createState() => _PetFormSheetState();
}

class _PetFormSheetState extends State<_PetFormSheet> {
  final nameController = TextEditingController();
  final breedController = TextEditingController();
  final ageController = TextEditingController();
  final weightController = TextEditingController();

  String selectedType = "dog";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF2B2A2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Pet Name"),
          ),
          TextField(
            controller: breedController,
            decoration: const InputDecoration(labelText: "Breed"),
          ),
          TextField(
            controller: ageController,
            decoration: const InputDecoration(labelText: "Age"),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 2,
          ),
          TextField(
            controller: weightController,
            decoration: const InputDecoration(labelText: "Weight (kg)"),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 3,
          ),
          DropdownButtonFormField<String>(
            value: selectedType,
            items: ["dog", "cat"].map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (val) {
              setState(() => selectedType = val!);
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              widget.onSave({
                "name": nameController.text,
                "breed": breedController.text,
                "age": ageController.text,
                "type": selectedType,
                "weight": weightController.text,
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
