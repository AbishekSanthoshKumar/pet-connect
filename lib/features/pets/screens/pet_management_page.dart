import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
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

  Future<void> updatePetInBackend(int id, Map<String, dynamic> pet) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      await ApiService.updatePet(id, {...pet, "ownerId": userId});

      fetchPets();
    } catch (e) {
      print("Error updating pet: $e");
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
                        onEdit: () =>
                            _showAddPetDialog(petToEdit: _pets[index]),
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

  void _showAddPetDialog({Map<String, dynamic>? petToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PetFormSheet(
        initialPet: petToEdit,
        onSave: (pet) {
          final parsedPet = {
            "name": pet['name'],
            "breed": pet['breed'],
            "type": pet['type'],
            "age": int.tryParse(pet['age'].toString()) ?? 0,
            "weight": double.tryParse(pet['weight'].toString()) ?? 0.0,
            if (pet['medicalDetails'] != null)
              "medicalDetails": pet['medicalDetails'],
          };

          if (petToEdit == null) {
            addPetToBackend(parsedPet);
          } else {
            updatePetInBackend(petToEdit['id'], parsedPet);
          }
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
    String imagePath = (pet['type'] ?? 'dog').toString().toLowerCase() == 'cat'
        ? 'assets/images/pet-cat.jpg'
        : 'assets/images/pet-dog.jpg';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.6),
            BlendMode.darken,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          pet['name'] ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              pet['breed'] ?? '',
              style: const TextStyle(color: Colors.white70),
            ),
            if (pet['medicalDetails'] != null &&
                pet['medicalDetails'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "Docs: ${pet['medicalDetails'].toString().split('/').last}",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= FORM ================= */

class _PetFormSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialPet;

  const _PetFormSheet({required this.onSave, this.initialPet});

  @override
  State<_PetFormSheet> createState() => _PetFormSheetState();
}

class _PetFormSheetState extends State<_PetFormSheet> {
  final nameController = TextEditingController();
  final breedController = TextEditingController();
  final ageController = TextEditingController();
  final weightController = TextEditingController();

  String selectedType = "Dog";
  String? medicalDetailsFile;

  @override
  void initState() {
    super.initState();
    if (widget.initialPet != null) {
      nameController.text = widget.initialPet!['name'] ?? '';
      breedController.text = widget.initialPet!['breed'] ?? '';
      ageController.text = widget.initialPet!['age']?.toString() ?? '';
      weightController.text = widget.initialPet!['weight']?.toString() ?? '';
      selectedType = widget.initialPet!['type'] ?? 'Dog';
      medicalDetailsFile = widget.initialPet!['medicalDetails'];
      // Ensure the selectedType is one of the valid options
      if (!["Dog", "Cat"].contains(selectedType)) {
        selectedType = "Dog";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF2B2A2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.initialPet == null ? "Add New Pet" : "Edit Pet",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Pet Name"),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: breedController,
              decoration: const InputDecoration(labelText: "Breed"),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: "Age"),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 2,
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: weightController,
              decoration: const InputDecoration(labelText: "Weight (kg)"),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 3,
              style: const TextStyle(color: Colors.white),
            ),
            DropdownButtonFormField<String>(
              initialValue: selectedType,
              dropdownColor: const Color(0xFF2B2A2A),
              style: const TextStyle(color: Colors.white),
              items: ["Dog", "Cat"].map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (val) {
                setState(() => selectedType = val!);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    medicalDetailsFile != null
                        ? "Doc: ${medicalDetailsFile!.split('/').last}"
                        : "No medical document selected",
                    style: const TextStyle(color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles();
                    if (result != null) {
                      setState(() {
                        medicalDetailsFile = result.files.single.path;
                      });
                    }
                  },
                  icon: const Icon(Icons.upload_file, color: Colors.orange),
                  label: const Text(
                    "Upload",
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
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
                  "medicalDetails": medicalDetailsFile,
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
