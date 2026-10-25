import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/core/utils/platform_file.dart';

import '../controllers/family_controller.dart';
import '../widgets/family_form_fields.dart';

class EditFamilyMemberScreen extends StatefulWidget {
  final Map<String, dynamic> memberData;
  final int index;

  const EditFamilyMemberScreen({
    super.key,
    required this.memberData,
    required this.index,
  });

  @override
  State<EditFamilyMemberScreen> createState() => _EditFamilyMemberScreenState();
}

class _EditFamilyMemberScreenState extends State<EditFamilyMemberScreen> {
  final FamilyController _controller = FamilyController();
  bool _isSubmitting = false;

  late TextEditingController _nameController;
  late TextEditingController _relationController;
  late TextEditingController _dobController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  final List<TextEditingController> _allergyControllers = [];
  final List<TextEditingController> _chronicControllers = [];

  String _selectedGender = "Female";
  String _selectedBloodGroup = "B+";
  AppPlatformFile? _selectedImage;
  bool isSelf = false;

  @override
  void initState() {
    super.initState();
    final data = widget.memberData;
    isSelf = data['relation'] == "Self";

    _nameController = TextEditingController(text: data['name'] ?? "");
    _relationController = TextEditingController(text: data['relation'] ?? "");
    _dobController = TextEditingController(text: data['dob'] ?? "");
    _heightController = TextEditingController(text: data['height'] ?? "");
    _weightController = TextEditingController(text: data['weight'] ?? "");
    _selectedGender = data['gender'] ?? "Female";
    _selectedBloodGroup = data['blood'] ?? "B+";

    if (data['allergies'] != null) {
      for (var a in data['allergies']) {
        _allergyControllers.add(TextEditingController(text: a.toString()));
      }
    }
    if (data['chronicConditions'] != null) {
      for (var c in data['chronicConditions']) {
        _chronicControllers.add(TextEditingController(text: c.toString()));
      }
    }
  }

  Future<void> _pickImage() async {
    if (isSelf) return;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final platformFile = await AppPlatformFile.fromXFile(image);
      setState(() => _selectedImage = platformFile);
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
            const SizedBox(height: 150),
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
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Back',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(context),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: Center(
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
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              isSelf ? "Family Profile" : "Edit Family Profile",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C4E4E),
              ),
              overflow: TextOverflow.ellipsis,
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
            hint: "Name",
            enabled: !isSelf,
          ),
          _buildRelationRow(),
          FamilyFormFields.buildDatePicker(
            context: context,
            controller: _dobController,
            enabled: !isSelf,
            onDateSelected: () => setState(() {}),
          ),
          Row(
            children: [
              Expanded(
                child: FamilyFormFields.buildDropdown(
                  value: _selectedGender,
                  items: ["Male", "Female", "Other"],
                  onChanged: (val) => setState(() => _selectedGender = val!),
                  enabled: !isSelf,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: FamilyFormFields.buildDropdown(
                  value: _selectedBloodGroup,
                  items: ["A+", "B+", "O+", "AB+", "A-", "B-", "O-", "AB-"],
                  onChanged: (val) =>
                      setState(() => _selectedBloodGroup = val!),
                  enabled: !isSelf,
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
                  suffixText: "Cm",
                  enabled: !isSelf,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: FamilyFormFields.buildTextField(
                  controller: _weightController,
                  hint: "Weight",
                  suffixText: "Kg",
                  enabled: !isSelf,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildDynamicList("Known Allergies", _allergyControllers),
          const SizedBox(height: 15),
          _buildDynamicList("Chronic Condition", _chronicControllers),
          const SizedBox(height: 30),
          if (!isSelf) _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
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
                child: _selectedImage != null && _selectedImage!.bytes != null
                    ? Image.memory(_selectedImage!.bytes!, fit: BoxFit.cover)
                    : Icon(Icons.person, size: 50, color: Colors.grey.shade400),
              ),
            ),
            if (!isSelf)
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
        ),
        const SizedBox(height: 8),
        const Text(
          "User id: 24900031276",
          style: TextStyle(color: Colors.grey, fontSize: 11),
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
            hint: "Relation",
            enabled: !isSelf,
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
            enabled: !isSelf,
            suffixIcon: isSelf
                ? null
                : IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFF1E4D4D),
                    ),
                    onPressed: () =>
                        setState(() => controllers.removeAt(entry.key)),
                  ),
          ),
        ),
        if (!isSelf)
          GestureDetector(
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
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSubmitting
            ? null
            : () async {
                if (_nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Name cannot be empty")),
                  );
                  return;
                }

                setState(() => _isSubmitting = true);

                final result = await _controller.updateFamilyMember(
                  widget.memberData['id'] ?? widget.index,
                  {
                    'name': _nameController.text.trim(),
                    'relation': _relationController.text.trim(),
                    'dob': _dobController.text.trim(),
                    'gender': _selectedGender,
                    'blood': _selectedBloodGroup,
                    'height': _heightController.text.trim(),
                    'weight': _weightController.text.trim(),
                    'imageFile':
                        _selectedImage, // ADD THIS: Save the selected image
                    'allergies': _allergyControllers
                        .map((c) => c.text.trim())
                        .where((t) => t.isNotEmpty)
                        .toList(),
                    'chronicConditions': _chronicControllers
                        .map((c) => c.text.trim())
                        .where((t) => t.isNotEmpty)
                        .toList(),
                  },
                );

                if (!mounted) return;

                if (result.isSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Family member updated successfully!"),
                      backgroundColor: AppColors.primaryTeal,
                    ),
                  );
                  Navigator.pop(context);
                } else {
                  setState(() => _isSubmitting = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result.failureOrNull?.message ??
                            "Failed to update family member",
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sageGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "Save",
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
