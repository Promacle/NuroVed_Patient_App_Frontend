enum DietaryPattern { vegetarian, nonVegetarian, both }

enum ActivityLevel { sedentary, moderate, heavyAthlete }

enum HealthGoal { loseWeight, maintainWeight, muscleGain }

enum BudgetTier { budgetFriendly, standard, flexible }

/// Structured user dietary preferences and practical lifestyle constraints.
class DietPreferences {
  final String? profileName;
  final int? age;
  final String? gender;
  final double? weightKg;
  final double? heightCm;
  final DietaryPattern dietaryPattern;
  final Set<String> nonVegDays;
  final List<String> allergiesAndExclusions;
  final String? medicalConditionNotes;
  final ActivityLevel activityLevel;
  final HealthGoal primaryGoal;
  final String? mealTiming;
  final BudgetTier budgetTier;
  final String? practicalContext;

  const DietPreferences({
    this.profileName,
    this.age,
    this.gender,
    this.weightKg,
    this.heightCm,
    this.dietaryPattern = DietaryPattern.vegetarian,
    this.nonVegDays = const {},
    this.allergiesAndExclusions = const [],
    this.medicalConditionNotes,
    this.activityLevel = ActivityLevel.moderate,
    this.primaryGoal = HealthGoal.maintainWeight,
    this.mealTiming,
    this.budgetTier = BudgetTier.standard,
    this.practicalContext,
  });

  DietPreferences copyWith({
    String? profileName,
    int? age,
    String? gender,
    double? weightKg,
    double? heightCm,
    DietaryPattern? dietaryPattern,
    Set<String>? nonVegDays,
    List<String>? allergiesAndExclusions,
    String? medicalConditionNotes,
    ActivityLevel? activityLevel,
    HealthGoal? primaryGoal,
    String? mealTiming,
    BudgetTier? budgetTier,
    String? practicalContext,
  }) {
    return DietPreferences(
      profileName: profileName ?? this.profileName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      dietaryPattern: dietaryPattern ?? this.dietaryPattern,
      nonVegDays: nonVegDays ?? this.nonVegDays,
      allergiesAndExclusions:
          allergiesAndExclusions ?? this.allergiesAndExclusions,
      medicalConditionNotes:
          medicalConditionNotes ?? this.medicalConditionNotes,
      activityLevel: activityLevel ?? this.activityLevel,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      mealTiming: mealTiming ?? this.mealTiming,
      budgetTier: budgetTier ?? this.budgetTier,
      practicalContext: practicalContext ?? this.practicalContext,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileName': profileName,
      'age': age,
      'gender': gender,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'dietaryPattern': dietaryPattern.name,
      'nonVegDays': nonVegDays.toList(),
      'allergiesAndExclusions': allergiesAndExclusions,
      'medicalConditionNotes': medicalConditionNotes,
      'activityLevel': activityLevel.name,
      'primaryGoal': primaryGoal.name,
      'mealTiming': mealTiming,
      'budgetTier': budgetTier.name,
      'practicalContext': practicalContext,
    };
  }

  factory DietPreferences.fromJson(Map<String, dynamic> json) {
    return DietPreferences(
      profileName: json['profileName'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      dietaryPattern: DietaryPattern.values.firstWhere(
        (e) => e.name == json['dietaryPattern'],
        orElse: () => DietaryPattern.vegetarian,
      ),
      nonVegDays:
          (json['nonVegDays'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          const {},
      allergiesAndExclusions:
          (json['allergiesAndExclusions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      medicalConditionNotes: json['medicalConditionNotes'] as String?,
      activityLevel: ActivityLevel.values.firstWhere(
        (e) => e.name == json['activityLevel'],
        orElse: () => ActivityLevel.moderate,
      ),
      primaryGoal: HealthGoal.values.firstWhere(
        (e) => e.name == json['primaryGoal'],
        orElse: () => HealthGoal.maintainWeight,
      ),
      mealTiming: json['mealTiming'] as String?,
      budgetTier: BudgetTier.values.firstWhere(
        (e) => e.name == json['budgetTier'],
        orElse: () => BudgetTier.standard,
      ),
      practicalContext: json['practicalContext'] as String?,
    );
  }
}
