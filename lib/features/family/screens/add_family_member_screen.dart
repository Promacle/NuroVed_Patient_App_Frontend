import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

import '../controllers/family_controller.dart';
import '../widgets/family_form_fields.dart';

class AddFamilyMemberScreen extends StatefulWidget {
  const AddFamilyMemberScreen({super.key});

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  final FamilyController _controller = FamilyController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final List<TextEditingController> _allergyControllers = [];
  final List<TextEditingController> _chronicControllers = [];

  String _selectedGender = "Female";
  String _selectedBloodGroup = "B+";
  File? _selectedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildMainCard(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
      decoration: const BoxDecoration(
        color: AppColors.mintBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.sageGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              const Text(
                "Add Family Profile",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C4E4E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(left: 48),
            child: Text(
              "Manage Your And Your Families Personal Information",
              style: TextStyle(
                color: Color(0xFF5A6A6A),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.mintBackground.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(35),
      ),
      child: Column(
        children: [
          _buildAvatarSection(),
          const SizedBox(height: 25),
          FamilyFormFields.buildTextField(
            controller: _nameController,
            hint: "Enter family member name",
          ),
          _buildRelationRow(),
          FamilyFormFields.buildDatePicker(
            context: context,
            controller: _dobController,
            enabled: true,
            onDateSelected: () => setState(() {}),
          ),
          Row(
            children: [
              Expanded(
                child: FamilyFormFields.buildDropdown(
                  value: _selectedGender,
                  items: ["Male", "Female", "Other"],
                  onChanged: (val) => setState(() => _selectedGender = val!),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: FamilyFormFields.buildDropdown(
                  value: _selectedBloodGroup,
                  items: ["A+", "B+", "O+", "AB+", "A-", "B-", "O-", "AB-"],
                  onChanged: (val) =>
                      setState(() => _selectedBloodGroup = val!),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FamilyFormFields.buildTextField(
                  controller: _heightController,
                  hint: "Height",
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: FamilyFormFields.buildTextField(
                  controller: _weightController,
                  hint: "Weight",
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildDynamicList("Known Allergies", _allergyControllers),
          const SizedBox(height: 15),
          _buildDynamicList("Chronic Condition", _chronicControllers),
          const SizedBox(height: 30),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Stack(
      children: [
        Container(
          height: 90,
          width: 90,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: _selectedImage != null
                ? Image.file(_selectedImage!, fit: BoxFit.cover)
                : Icon(Icons.person, size: 50, color: Colors.grey.shade400),
          ),
        ),
        Positioned(
          right: 2,
          bottom: 2,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: AppColors.sageGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_note,
                color: AppColors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRelationRow() {
    return Row(
      children: [
        const Text(
          "Relation: ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C4E4E),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FamilyFormFields.buildTextField(
            controller: _relationController,
            hint: "Enter relation with family member",
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicList(
    String title,
    List<TextEditingController> controllers,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C4E4E),
          ),
        ),
        const SizedBox(height: 10),
        ...controllers.asMap().entries.map(
          (entry) => FamilyFormFields.buildTextField(
            controller: entry.value,
            hint: "",
            suffixIcon: IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFF1E4D4D)),
              onPressed: () => setState(() => controllers.removeAt(entry.key)),
            ),
          ),
        ),
        Center(
          child: GestureDetector(
            onTap: () =>
                setState(() => controllers.add(TextEditingController())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "+ Add New",
                style: TextStyle(
                  color: AppColors.sageGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          if (_nameController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please enter a name")),
            );
            return;
          }
          _controller.addFamilyMember({
            'name': _nameController.text,
            'relation': _relationController.text,
            'dob': _dobController.text,
            'gender': _selectedGender,
            'blood': _selectedBloodGroup,
            'height': _heightController.text,
            'weight': _weightController.text,
            'allergies': _allergyControllers.map((c) => c.text).toList(),
            'chronicConditions': _chronicControllers
                .map((c) => c.text)
                .toList(),
            'image': null,
          });
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sageGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          "Add New Profile",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
