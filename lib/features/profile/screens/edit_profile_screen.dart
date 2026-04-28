import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;
  const EditProfileScreen({super.key, required this.initialData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController,
      _emailController,
      _dobController,
      _heightController,
      _weightController,
      _phoneController;

  final List<TextEditingController> _allergyControllers = [];
  final List<TextEditingController> _chronicControllers = [];
  String _selectedGender = "male", _selectedBloodGroup = "B+";
  File? _selectedImage;
  String _completePhoneNumber = "";

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Handle error silently or show user-friendly message
    }
  }

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _nameController = TextEditingController(text: data['name']);
    _emailController = TextEditingController(text: data['email']);
    _phoneController = TextEditingController(text: data['phone'] ?? "");
    _dobController = TextEditingController(text: data['dob'] ?? "02/05/2007");
    _heightController = TextEditingController(text: data['height']);
    _weightController = TextEditingController(text: data['weight']);
    _selectedGender = data['gender'] ?? "male";
    _selectedBloodGroup = data['blood'] ?? "B+";
    _selectedImage = data['imageFile'];

    for (var a in (data['allergies'] ?? [])) {
      _allergyControllers.add(TextEditingController(text: a));
    }
    for (var c in (data['chronicConditions'] ?? [])) {
      _chronicControllers.add(TextEditingController(text: c));
    }
  }

  // FIXED NAVIGATION: Clears stack and pushes to a specific route (Home/Dashboard)
  // to ensure user lands on the Profile tab correctly.
  void _finalSaveAndNavigate() {
    final updatedData = {
      'name': _nameController.text,
      'email': _emailController.text,
      // If _completePhoneNumber is empty (field not touched), use the existing phone
      'phone': _completePhoneNumber.isNotEmpty
          ? _completePhoneNumber
          : _phoneController.text,
      'dob': _dobController.text, // Added this to reflect DOB changes
      'height': _heightController.text,
      'weight': _weightController.text,
      'gender': _selectedGender,
      'blood': _selectedBloodGroup,
      'imageFile': _selectedImage,
      'allergies': _allergyControllers
          .map((e) => e.text)
          .where((t) => t.isNotEmpty)
          .toList(),
      'chronicConditions': _chronicControllers
          .map((e) => e.text)
          .where((t) => t.isNotEmpty)
          .toList(),
    };

    // This returns the Map back to the ProfileController/ProfileScreen
    Navigator.of(context).pop(updatedData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBeautifulHeader(),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F1ED),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: _buildAvatarPicker()),
                  const SizedBox(height: 25),
                  _buildSharpField(_nameController, "Name"),
                  _buildSharpField(_emailController, "Email"),

                  // NEW: Phone Number with Country Code
                  _buildPhoneField(),

                  _buildDateField(),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          _selectedGender,
                          ["male", "female", "other"],
                          (val) => setState(() => _selectedGender = val!),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildDropdown(
                          _selectedBloodGroup,
                          ["A+", "B+", "O+", "AB+", "A-", "B-", "O-", "AB-"],
                          (val) => setState(() => _selectedBloodGroup = val!),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSharpField(
                          _heightController,
                          "Height",
                          suffix: "Cm",
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildSharpField(
                          _weightController,
                          "Weight",
                          suffix: "Kg",
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    "Known Allergies",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF2C4E4E),
                    ),
                  ),
                  ..._buildDynamicFields(_allergyControllers),
                  _buildAddButton(
                    () => setState(
                      () => _allergyControllers.add(TextEditingController()),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Chronic Condition",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF2C4E4E),
                    ),
                  ),
                  ..._buildDynamicFields(_chronicControllers),
                  _buildAddButton(
                    () => setState(
                      () => _chronicControllers.add(TextEditingController()),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildSaveButton(),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: IntlPhoneField(
        controller: _phoneController,
        decoration: InputDecoration(
          hintText: 'Phone Number',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        initialCountryCode: 'IN', // Default to India, change as needed
        onChanged: (phone) {
          _completePhoneNumber = phone.completeNumber;
        },
      ),
    );
  }

  Widget _buildBeautifulHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        color: Color(0xFFE1ECE7),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF2C4E4E),
              size: 22,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 10),
          const Text(
            "Edit Profile",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C4E4E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPicker() {
    return Stack(
      children: [
        Container(
          height: 110,
          width: 110,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: _selectedImage != null
                ? Image.file(_selectedImage!, fit: BoxFit.cover)
                : Icon(Icons.person, size: 60, color: Colors.grey.shade400),
          ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: GestureDetector(
            onTap: _pickImage,
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF81C7AD),
              child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSharpField(
    TextEditingController c,
    String hint, {
    String? suffix,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          hintText: hint,
          suffixText: suffix,
          suffixIcon: icon != null
              ? Icon(icon, color: const Color(0xFF2C4E4E), size: 20)
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime(2007, 5, 2),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(
            () => _dobController.text = DateFormat('dd/MM/yyyy').format(picked),
          );
        }
      },
      child: AbsorbPointer(
        child: _buildSharpField(
          _dobController,
          "DOB",
          icon: Icons.calendar_today_outlined,
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF2C4E4E),
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  List<Widget> _buildDynamicFields(List<TextEditingController> controllers) {
    return controllers.asMap().entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: TextField(
          controller: entry.value,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            suffixIcon: IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFF1E4D4D)),
              onPressed: () => setState(() => controllers.removeAt(entry.key)),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildAddButton(VoidCallback onTap) {
    return Center(
      child: TextButton(
        onPressed: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Text(
            "+ Add New",
            style: TextStyle(
              color: Color(0xFF81C7AD),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed:
            _finalSaveAndNavigate, // This calls the function that pops the data
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF81C7AD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Save Changes",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
