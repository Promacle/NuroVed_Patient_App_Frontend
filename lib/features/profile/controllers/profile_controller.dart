import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/failures.dart';
import '../../../core/models/care_access_grant.dart';
import '../../../core/models/family_member.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/repositories/fake/fake_profile_repository.dart';
import '../../../core/repositories/profile_repository.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/platform_file.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/validators.dart';
import '../screens/edit_profile_screen.dart';

class ProfileController extends ChangeNotifier {
  // Singleton pattern with dependency injection and testing reset support
  static ProfileController _instance = ProfileController._internal();

  factory ProfileController({ProfileRepository? repository}) {
    if (repository != null) {
      _instance._repository = repository;
    }
    return _instance;
  }

  static ProfileController get instance => _instance;

  static void resetForTesting({
    ProfileRepository? repository,
    UserProfile? initialProfile,
    List<FamilyMember>? initialFamily,
    CareAccessGrant? initialCaregiver,
  }) {
    _instance.dispose();
    _instance = ProfileController._internal(
      repository:
          repository ??
          FakeProfileRepository(
            initialProfile: initialProfile,
            initialFamily: initialFamily,
            initialCaregiver: initialCaregiver,
          ),
      initialProfile: initialProfile,
      initialFamily: initialFamily,
    );
  }

  ProfileRepository _repository;
  UserProfile _profile;
  final List<FamilyMember> _familyMemberList = [];
  CareAccessGrant? _caregiverGrant;
  AppPlatformFile? _selectedImage;

  // Single source of truth for active subject
  late String _activeSubjectId;

  bool _isLoading = false;
  bool _isOffline = false;
  String? _errorMessage;

  ProfileController._internal({
    ProfileRepository? repository,
    UserProfile? initialProfile,
    List<FamilyMember>? initialFamily,
  }) : _repository = repository ?? FakeProfileRepository(),
       _profile = initialProfile ?? UserProfile.empty() {
    _activeSubjectId = _profile.id;
    if (initialFamily != null) {
      _familyMemberList.addAll(initialFamily);
    }
  }

  // Getters
  UserProfile get profile => _profile;
  List<FamilyMember> get familyMembersList =>
      List.unmodifiable(_familyMemberList);
  CareAccessGrant? get caregiverGrant => _caregiverGrant;
  String get activeSubjectId => _activeSubjectId;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  String? get errorMessage => _errorMessage;
  AppPlatformFile? get selectedImage => _selectedImage;

  bool get isMainPatientActive => _activeSubjectId == _profile.id;

  String get activeProfileName {
    if (isMainPatientActive) {
      return _profile.name.isEmpty || _profile.name == 'Not provided'
          ? 'Self'
          : _profile.name;
    }
    final member = _familyMemberList.firstWhere(
      (m) => m.id == _activeSubjectId,
      orElse: () => FamilyMember(
        id: _activeSubjectId,
        name: 'Family Member',
        relation: 'Relative',
      ),
    );
    return member.name;
  }

  set activeProfileName(String name) => switchSubjectByName(name);

  dynamic get activeSubjectImage {
    if (isMainPatientActive) {
      return _selectedImage;
    }
    final member = _familyMemberList.firstWhere(
      (m) => m.id == _activeSubjectId,
      orElse: () => FamilyMember(
        id: _activeSubjectId,
        name: 'Family Member',
        relation: 'Relative',
      ),
    );
    return member.photoUrl;
  }

  /// Backward-compatible map accessor for existing UI widgets
  Map<String, dynamic> get userData {
    return {
      'id': _profile.id,
      'name': _profile.name,
      'email': _profile.email,
      'phone': _profile.phone,
      'dob': _profile.dateOfBirth,
      'height': _profile.height,
      'weight': _profile.weight,
      'gender': _profile.gender,
      'blood': _profile.bloodGroup,
      'imageFile': _selectedImage,
      'allergies': _profile.allergies,
      'chronicConditions': _profile.chronicConditions,
      'photo_url': _profile.photoUrl,
    };
  }

  /// Backward-compatible family member map list with stable IDs
  List<Map<String, dynamic>> get familyMembers {
    final List<Map<String, dynamic>> list = [
      {
        'id': _profile.id,
        'name': _profile.name.isEmpty || _profile.name == 'Not provided'
            ? 'Self'
            : _profile.name,
        'relation': 'Self',
        'isMain': true,
        'imageFile': _selectedImage,
        'records': <dynamic>[],
      },
    ];

    for (final member in _familyMemberList) {
      list.add({
        'id': member.id,
        'name': member.name,
        'relation': member.relation,
        'isMain': member.isMain,
        'is_emergency_contact': member.isEmergencyContact,
        'phone': member.phone,
        'blood': member.bloodGroup,
        'photo_url': member.photoUrl,
        'imageFile': null,
        'records': <dynamic>[],
      });
    }

    return list;
  }

  // --- SINGLE SOURCE OF TRUTH: PROFILE / SUBJECT SWITCHING ---

  /// Switches active subject with stable UUID. Never mixes data between subjects.
  void switchSubject(String subjectId) {
    if (_activeSubjectId == subjectId) return;

    _activeSubjectId = subjectId;
    AppLogger.info('Switched active health subject to ID: $subjectId');
    _persistActiveSubject(subjectId);
    notifyListeners();
  }

  /// Switches active subject back to primary user ('Self')
  void switchSubjectToSelf() => switchSubject(_profile.id);

  void switchSubjectByName(String name) {
    if (name == 'Self' || name == _profile.name) {
      switchSubject(_profile.id);
      return;
    }
    final match = _familyMemberList.firstWhere(
      (m) => m.name.toLowerCase() == name.toLowerCase(),
      orElse: () => FamilyMember(id: '', name: '', relation: ''),
    );
    if (match.id.isNotEmpty) {
      switchSubject(match.id);
    }
  }

  // --- DATA LOADING & PERSISTENCE ---

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // 1. Load cached profile if available
    await _loadFromCache();

    // 2. Fetch remote profile
    final profileResult = await _repository.getProfile();
    profileResult.when(
      success: (p) {
        _profile = p;
        _isOffline = false;
        _saveToCache(p);
      },
      failure: (f) {
        _isOffline = true;
        _errorMessage = f.message;
        AppLogger.warning('Offline mode active for Profile: ${f.message}');
      },
    );

    // 3. Fetch family members
    final familyResult = await _repository.getFamilyMembers();
    familyResult.when(
      success: (members) {
        _familyMemberList.clear();
        _familyMemberList.addAll(members);
      },
      failure: (f) {
        AppLogger.warning('Failed to load family members: ${f.message}');
      },
    );

    // 4. Fetch caregiver grant
    final grantResult = await _repository.getCaregiverGrant();
    grantResult.when(
      success: (grant) {
        _caregiverGrant = grant;
      },
      failure: (f) {
        AppLogger.warning('Failed to load caregiver grant: ${f.message}');
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> retry() async {
    await loadProfile();
  }

  // --- PATIENT PROFILE EDITING & OPTIMISTIC ROLLBACK ---

  /// Optimistically updates patient profile with automatic rollback on repository failure.
  Future<Result<UserProfile>> updateProfile(
    UserProfile newProfile, {
    AppPlatformFile? imageFile,
  }) async {
    final previousProfile = _profile;
    final previousImage = _selectedImage;

    // 1. Optimistic UI update
    _profile = newProfile;
    if (imageFile != null) {
      _selectedImage = imageFile;
    }
    _errorMessage = null;
    notifyListeners();

    // 2. Persist to repository
    final result = await _repository.updateProfile(newProfile);

    return result.when(
      success: (saved) {
        _profile = saved;
        _saveToCache(saved);
        notifyListeners();
        return Result.success(saved);
      },
      failure: (failure) {
        // Rollback optimistic changes on failure
        _profile = previousProfile;
        _selectedImage = previousImage;
        _errorMessage = failure.message;
        notifyListeners();
        AppLogger.error(
          'Profile update failed. Rolled back to previous state.',
          failure.message,
        );
        return Result.failure(failure);
      },
    );
  }

  /// Adds an allergy with optimistic update and rollback on failure.
  Future<Result<UserProfile>> addAllergy(String allergy) async {
    final trimmed = allergy.trim();
    if (trimmed.isEmpty || _profile.allergies.contains(trimmed)) {
      return Result.success(_profile);
    }
    final updatedList = List<String>.from(_profile.allergies)..add(trimmed);
    return updateProfile(_profile.copyWith(allergies: updatedList));
  }

  /// Removes an allergy with optimistic update and rollback on failure.
  Future<Result<UserProfile>> removeAllergy(String allergy) async {
    if (!_profile.allergies.contains(allergy)) {
      return Result.success(_profile);
    }
    final updatedList = _profile.allergies.where((a) => a != allergy).toList();
    return updateProfile(_profile.copyWith(allergies: updatedList));
  }

  /// Adds a chronic condition with optimistic update and rollback on failure.
  Future<Result<UserProfile>> addChronicCondition(String condition) async {
    final trimmed = condition.trim();
    if (trimmed.isEmpty || _profile.chronicConditions.contains(trimmed)) {
      return Result.success(_profile);
    }
    final updatedList = List<String>.from(_profile.chronicConditions)
      ..add(trimmed);
    return updateProfile(_profile.copyWith(chronicConditions: updatedList));
  }

  /// Removes a chronic condition with optimistic update and rollback on failure.
  Future<Result<UserProfile>> removeChronicCondition(String condition) async {
    if (!_profile.chronicConditions.contains(condition)) {
      return Result.success(_profile);
    }
    final updatedList = _profile.chronicConditions
        .where((c) => c != condition)
        .toList();
    return updateProfile(_profile.copyWith(chronicConditions: updatedList));
  }

  /// Validates profile photo size (<= 10MB) and allowed extensions (jpg, jpeg, png).
  Result<AppPlatformFile> validateProfilePhoto(AppPlatformFile file) {
    final typeCheck = Validators.validateFileType(file.name, [
      'jpg',
      'jpeg',
      'png',
    ]);
    if (typeCheck != null) {
      return Result.failure(ValidationFailure(message: typeCheck));
    }

    if (file.bytes != null) {
      final sizeCheck = Validators.validateFileSize(
        file.bytes!.length,
        10 * 1024 * 1024,
      );
      if (sizeCheck != null) {
        return Result.failure(ValidationFailure(message: sizeCheck));
      }
    }

    return Result.success(file);
  }

  // --- FAMILY MANAGEMENT WITH STABLE IDS ---

  Future<Result<FamilyMember>> addFamilyMember(FamilyMember member) async {
    final nameError = Validators.validateFullName(member.name);
    if (nameError != null) {
      return Result.failure(ValidationFailure(message: nameError));
    }

    final result = await _repository.addFamilyMember(member);
    return result.when(
      success: (created) {
        _familyMemberList.add(created);
        notifyListeners();
        return Result.success(created);
      },
      failure: (failure) {
        return Result.failure(failure);
      },
    );
  }

  Future<Result<FamilyMember>> updateFamilyMember(FamilyMember member) async {
    final result = await _repository.updateFamilyMember(member);
    return result.when(
      success: (updated) {
        final index = _familyMemberList.indexWhere((m) => m.id == updated.id);
        if (index != -1) {
          _familyMemberList[index] = updated;
          notifyListeners();
        }
        return Result.success(updated);
      },
      failure: (failure) {
        return Result.failure(failure);
      },
    );
  }

  Future<Result<void>> removeFamilyMember(String memberId) async {
    final result = await _repository.deleteFamilyMember(memberId);
    return result.when(
      success: (_) {
        _familyMemberList.removeWhere((m) => m.id == memberId);
        // If the removed member was the active subject, switch back to main profile
        if (_activeSubjectId == memberId) {
          _activeSubjectId = _profile.id;
        }
        notifyListeners();
        return const Result.success(null);
      },
      failure: (failure) {
        return Result.failure(failure);
      },
    );
  }

  // --- CAREGIVER RELATIONSHIP & SCOPES ---

  Future<Result<CareAccessGrant>> inviteCaregiver({
    required String email,
    required String name,
    required List<String> scopes,
    String accessType = 'view_only',
    String purpose = 'Continuity of diabetes care',
    Duration duration = const Duration(days: 30),
  }) async {
    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      return Result.failure(ValidationFailure(message: emailError));
    }
    if (name.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Caregiver name cannot be empty'),
      );
    }
    if (scopes.isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'At least one resource scope is required'),
      );
    }

    final result = await _repository.inviteCaregiver(
      email: email,
      name: name,
      scopes: scopes,
      accessType: accessType,
      purpose: purpose,
      duration: duration,
    );

    return result.when(
      success: (grant) {
        _caregiverGrant = grant;
        notifyListeners();
        return Result.success(grant);
      },
      failure: (f) => Result.failure(f),
    );
  }

  Future<Result<CareAccessGrant>> acceptCaregiverInvite(String grantId) async {
    final result = await _repository.acceptCaregiverInvite(grantId);
    return result.when(
      success: (grant) {
        _caregiverGrant = grant;
        notifyListeners();
        return Result.success(grant);
      },
      failure: (f) => Result.failure(f),
    );
  }

  Future<Result<CareAccessGrant>> updateCaregiverScopes(
    String grantId,
    List<String> scopes,
  ) async {
    if (scopes.isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'At least one resource scope is required'),
      );
    }
    final result = await _repository.updateCaregiverScopes(grantId, scopes);
    return result.when(
      success: (grant) {
        _caregiverGrant = grant;
        notifyListeners();
        return Result.success(grant);
      },
      failure: (f) => Result.failure(f),
    );
  }

  Future<Result<void>> revokeCaregiver(String grantId) async {
    final result = await _repository.revokeCaregiver(grantId);
    return result.when(
      success: (_) {
        if (_caregiverGrant != null && _caregiverGrant!.id == grantId) {
          _caregiverGrant = _caregiverGrant!.copyWith(
            status: 'revoked',
            revokedAt: DateTime.now(),
          );
        }
        notifyListeners();
        return const Result.success(null);
      },
      failure: (f) => Result.failure(f),
    );
  }

  // --- HELPERS & COMPATIBILITY METHODS ---

  Future<void> navigateToEdit(
    BuildContext context,
    VoidCallback onUpdate,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(initialData: userData),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      final updatedProfile = UserProfile(
        id: _profile.id,
        name: result['name'] ?? _profile.name,
        email: result['email'] ?? _profile.email,
        phone: result['phone'] ?? _profile.phone,
        dateOfBirth: result['dob'] ?? _profile.dateOfBirth,
        height: result['height'] ?? _profile.height,
        weight: result['weight'] ?? _profile.weight,
        gender: result['gender'] ?? _profile.gender,
        bloodGroup: result['blood'] ?? _profile.bloodGroup,
        allergies: List<String>.from(result['allergies'] ?? _profile.allergies),
        chronicConditions: List<String>.from(
          result['chronicConditions'] ?? _profile.chronicConditions,
        ),
        photoUrl: _profile.photoUrl,
        createdAt: _profile.createdAt,
        updatedAt: DateTime.now(),
      );

      final img = result['imageFile'] is AppPlatformFile
          ? result['imageFile'] as AppPlatformFile
          : null;

      await updateProfile(updatedProfile, imageFile: img);
      onUpdate();
    }
  }

  void addRecordToProfile(String name, Map<String, dynamic> record) {
    AppLogger.info('Record added to profile: $name');
  }

  void logout() {
    AppLogger.info('User logged out from profile');
    _selectedImage = null;
    _profile = UserProfile.empty();
    _familyMemberList.clear();
    _caregiverGrant = null;
    _activeSubjectId = _profile.id;
    notifyListeners();
  }

  String calculateAge() {
    try {
      String dobStr = _profile.dateOfBirth;
      if (dobStr.isEmpty || dobStr == 'Not provided') return 'N/A';

      List<String> parts = dobStr.split('/');
      if (parts.length != 3) return 'N/A';

      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      DateTime birthDate = DateTime(year, month, day);
      DateTime today = DateTime.now();
      int age = today.year - birthDate.year;

      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return '$age years';
    } catch (e) {
      return 'N/A';
    }
  }

  // --- INTERNAL CACHE HELPERS ---

  Future<void> _saveToCache(UserProfile p) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_profile_id', p.id);
      await prefs.setString('cached_profile_name', p.name);
      await prefs.setString('cached_profile_email', p.email);
      await prefs.setString('cached_profile_phone', p.phone);
      await prefs.setString('cached_profile_dob', p.dateOfBirth);
      await prefs.setString('cached_profile_blood', p.bloodGroup);
      await prefs.setString('cached_profile_height', p.height);
      await prefs.setString('cached_profile_weight', p.weight);
      await prefs.setString('cached_profile_gender', p.gender);
      await prefs.setStringList('cached_profile_allergies', p.allergies);
      await prefs.setStringList('cached_profile_chronic', p.chronicConditions);
    } catch (e) {
      AppLogger.warning('Failed to write profile cache: $e');
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('cached_profile_id');
      if (id != null && id.isNotEmpty) {
        _profile = UserProfile(
          id: id,
          name: prefs.getString('cached_profile_name') ?? _profile.name,
          email: prefs.getString('cached_profile_email') ?? _profile.email,
          phone: prefs.getString('cached_profile_phone') ?? _profile.phone,
          dateOfBirth:
              prefs.getString('cached_profile_dob') ?? _profile.dateOfBirth,
          bloodGroup:
              prefs.getString('cached_profile_blood') ?? _profile.bloodGroup,
          height: prefs.getString('cached_profile_height') ?? _profile.height,
          weight: prefs.getString('cached_profile_weight') ?? _profile.weight,
          gender: prefs.getString('cached_profile_gender') ?? _profile.gender,
          allergies:
              prefs.getStringList('cached_profile_allergies') ??
              _profile.allergies,
          chronicConditions:
              prefs.getStringList('cached_profile_chronic') ??
              _profile.chronicConditions,
        );
        final lastSubject = prefs.getString('last_active_subject_id');
        if (lastSubject != null && lastSubject.isNotEmpty) {
          _activeSubjectId = lastSubject;
        } else {
          _activeSubjectId = _profile.id;
        }
      }
    } catch (e) {
      AppLogger.warning('Failed to load profile cache: $e');
    }
  }

  Future<void> _persistActiveSubject(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_active_subject_id', id);
    } catch (e) {
      AppLogger.warning('Failed to persist active subject: $e');
    }
  }
}
