import 'package:flutter/material.dart';
import 'package:nuroved_patient/features/diet/screens/ai_diet_planner_screen.dart';
import 'package:nuroved_patient/features/diet/screens/diet_output_screen.dart';
import 'package:nuroved_patient/features/diet/screens/diet_preference_screen.dart';
import 'package:nuroved_patient/features/diet/screens/edit_meal_screen.dart';
import 'package:nuroved_patient/features/diet/screens/food_scanner_history_screen.dart';
import 'package:nuroved_patient/features/diet/screens/food_scanner_screen.dart';
import 'package:nuroved_patient/features/diet/screens/meal_routine_history_screen.dart';
import 'package:nuroved_patient/features/diet/screens/scanned_product_result_screen.dart';
import 'package:nuroved_patient/features/home/screens/main_layout.dart';
import 'package:nuroved_patient/features/settings/screens/customer_support_screen.dart';

// 1. Core and Wrapper Imports
import '../core/repositories/auth_repository.dart';
import '../core/utils/skeleton_wrapper.dart';
import '../features/access/screens/access_screen.dart';
// 2. Feature Screen Imports
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/loading_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/diet/screens/calorie_success_screen.dart';
import '../features/diet/screens/diet_screen.dart';
import '../features/diet/screens/diet_success_screen.dart';
import '../features/diet/screens/health_goal_screen.dart';
import '../features/diet/screens/time_and_context_screen.dart';
import '../features/family/screens/family_profile_screen.dart';
import '../features/notifications/screens/notification_screen.dart';
import '../features/premium/screens/premium_screen.dart';
import '../features/premium/screens/premium_status_screen.dart';
import '../features/premium/screens/purchase_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/records/screens/records_screen.dart';
import '../features/routine/screens/add_medicine_screen.dart';
import '../features/routine/screens/routine_screen.dart';
import '../features/settings/screens/app_settings_screen.dart';
import '../features/settings/screens/change_email_screen.dart';
import '../features/settings/screens/change_password_screen.dart';
import '../features/settings/screens/data_privacy_screen.dart';
import '../features/settings/screens/report_problem_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../core/models/diet/diet_preferences.dart';
import '../core/models/diet/meal_recipe.dart';
import '../core/models/medical_record.dart';
import '../core/models/scanned_food_product.dart';
import '../core/models/visit.dart';
import '../features/records/screens/add_record_screen.dart';
import '../features/records/screens/record_details_screen.dart';
import '../features/records/screens/record_success_screen.dart';
import '../features/routine/screens/routine_success_screen.dart';
import '../features/visits/screens/add_visit_screen.dart';
import '../features/visits/screens/visit_details_screen.dart';
import '../features/visits/screens/visits_screen.dart';

class AppRouter {
  // Route Name Constants
  static const String loading = '/';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String records = '/records';
  static const String visits = '/visits';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String access = '/access';
  static const String diet = '/diet';
  static const String routine = '/routine';
  static const String premium = '/premium'; // Added premium route
  static const String purchase = '/purchase'; // Added this missing constant
  static const String settingsRoute = '/settings';
  static const String addVisit = '/add-visit';
  static const String addMedicine = '/add-medicine';
  static const String addRecord = '/add-record';
  static const String aiDietPlanner = '/ai-diet-planner';
  static const String dietPreference = '/diet-preference';
  static const String healthGoal = '/health-goal';
  static const String familyProfiles = '/family-profiles';
  static const String timeAndContext = '/time-and-context';
  static const String dietOutput = '/diet-output';
  static const String mealRoutineHistory = '/meal-routine-history';
  static const String foodScanner = '/food-scanner';
  static const String foodScannerHistory = '/food-scanner-history';
  static const String scannedProductResult = '/scanned-product-result';
  static const String calorieSuccess = '/calorie-success';
  static const String dietSuccess = '/diet-success';
  static const String recordSuccess = '/record-success';
  static const String routineSuccess = '/routine-success';
  static const String editMeal = '/edit-meal';
  static const String premiumStatus = '/premium-status';
  static const String appSettings = '/app-settings';
  static const String dataPrivacy = '/data-privacy';
  static const String customerSupport = '/customer-support';
  static const String changeEmail = '/change-email';
  static const String changePassword = '/change-password';
  static const String reportProblem = '/report-problem';
  static const String visitDetails = '/visit-details';
  static const String recordDetails = '/record-details';

  /// Injected active auth repository for route guard evaluation.
  static AuthRepository? authRepository;

  static bool get isAuthenticated => authRepository?.currentUser != null;

  static const List<String> _publicRoutes = [
    loading,
    splash,
    login,
    signup,
    forgotPassword,
  ];

  static const List<String> _authOnlyWhenUnauthenticatedRoutes = [
    splash,
    login,
    signup,
  ];

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name ?? loading;

    // Route Guard 1: Unauthenticated user attempting to access protected route -> redirect to login
    if (!isAuthenticated && !_publicRoutes.contains(routeName)) {
      return MaterialPageRoute(
        settings: const RouteSettings(name: login),
        builder: (_) => const LoginScreen(),
      );
    }

    // Route Guard 2: Authenticated user attempting to access entry/auth screens -> redirect to home
    if (isAuthenticated &&
        _authOnlyWhenUnauthenticatedRoutes.contains(routeName)) {
      return PageRouteBuilder(
        settings: const RouteSettings(name: home),
        maintainState: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainLayout(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
    }

    // Helper function to create an animated route that triggers the skeleton
    Route createAnimatedRoute(Widget child) {
      return PageRouteBuilder(
        settings: settings, // <--- THIS IS THE CRITICAL FIX
        // Setting maintainState to false forces the skeleton to re-run on 'back'
        maintainState: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            SkeletonWrapper(child: child),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      );
    }

    switch (settings.name) {
      case loading:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoadingScreen(),
        );

      case splash:
        return createAnimatedRoute(const SplashScreen());

      case login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );

      case signup:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SignUpScreen(),
        );

      case forgotPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ForgotPasswordScreen(),
        );

      // Change the home case to this:
      case home:
        final initialIndex = settings.arguments is int
            ? settings.arguments as int
            : 0;
        return PageRouteBuilder(
          settings: settings, // <--- THIS IS THE CRITICAL FIX
          maintainState: false, // Important for "Back" button re-animation
          pageBuilder: (context, animation, secondaryAnimation) =>
              MainLayout(initialIndex: initialIndex),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );

      case records:
        return createAnimatedRoute(const RecordsScreen());

      case visits:
        return createAnimatedRoute(const VisitsScreen());

      case profile:
        return createAnimatedRoute(const ProfileScreen());

      case notifications:
        return createAnimatedRoute(const NotificationsScreen());

      case access:
        return createAnimatedRoute(const AccessScreen());

      case diet:
        return createAnimatedRoute(const DietScreen());

      case routine:
        return createAnimatedRoute(const RoutineScreen());
      case premium: // Handle premium route
        return createAnimatedRoute(const PremiumScreen());

      case aiDietPlanner:
        return createAnimatedRoute(
          AiDietPlannerScreen(
            initialPreferences: settings.arguments as DietPreferences?,
          ),
        );
      // Inside generateRoute switch:
      case dietPreference:
        return createAnimatedRoute(
          DietPreferenceScreen(
            initialPreferences: settings.arguments as DietPreferences?,
          ),
        );
      case addVisit:
        return MaterialPageRoute(builder: (_) => const AddVisitScreen());
      case addMedicine:
        return createAnimatedRoute(const AddMedicineScreen());
      case addRecord:
        return createAnimatedRoute(const AddRecordScreen());
      case visitDetails:
        if (settings.arguments is Visit) {
          return createAnimatedRoute(
            VisitDetailsScreen(visit: settings.arguments as Visit),
          );
        } else if (settings.arguments is String) {
          return createAnimatedRoute(
            VisitDetailsScreen(visitId: settings.arguments as String),
          );
        }
        return createAnimatedRoute(const VisitDetailsScreen());
      case recordDetails:
        if (settings.arguments is MedicalRecord) {
          return createAnimatedRoute(
            RecordDetailsScreen(record: settings.arguments as MedicalRecord),
          );
        } else if (settings.arguments is String) {
          return createAnimatedRoute(
            RecordDetailsScreen(recordId: settings.arguments as String),
          );
        }
        return createAnimatedRoute(const RecordDetailsScreen());
      case healthGoal:
        return createAnimatedRoute(
          HealthGoalScreen(
            initialPreferences: settings.arguments as DietPreferences?,
          ),
        );
      case familyProfiles:
        return createAnimatedRoute(const FamilyProfilesScreen());
      case timeAndContext:
        return createAnimatedRoute(
          TimeAndContextScreen(
            initialPreferences: settings.arguments as DietPreferences?,
          ),
        );
      case dietOutput:
        WeeklyDietPlan? plan;
        DietPreferences? preferences;
        if (settings.arguments is Map<String, dynamic>) {
          final map = settings.arguments as Map<String, dynamic>;
          plan = map['plan'] as WeeklyDietPlan?;
          preferences = map['preferences'] as DietPreferences?;
        } else if (settings.arguments is WeeklyDietPlan) {
          plan = settings.arguments as WeeklyDietPlan;
        }
        return createAnimatedRoute(
          DietOutputScreen(initialPlan: plan, preferences: preferences),
        );
      case foodScanner:
        return createAnimatedRoute(const FoodScannerScreen());
      case foodScannerHistory:
        return createAnimatedRoute(const FoodScannerHistoryScreen());
      case scannedProductResult:
        final product = settings.arguments as ScannedFoodProduct?;
        if (product != null) {
          return createAnimatedRoute(
            ScannedProductResultScreen(product: product),
          );
        }
        return createAnimatedRoute(const FoodScannerScreen());
      case editMeal:
        return createAnimatedRoute(const EditMealScreen());
      case settingsRoute:
        return createAnimatedRoute(const SettingsScreen());
      case appSettings:
        return createAnimatedRoute(const AppSettingsScreen());
      case dataPrivacy:
        return createAnimatedRoute(const DataPrivacyScreen());
      case customerSupport:
        return createAnimatedRoute(const CustomerSupportScreen());
      case changeEmail:
        return createAnimatedRoute(const ChangeEmailScreen());
      case changePassword:
        return createAnimatedRoute(const ChangePasswordScreen());
      case calorieSuccess:
        final timestamp = (settings.arguments is DateTime)
            ? settings.arguments as DateTime
            : DateTime.now();
        return createAnimatedRoute(CalorieSuccessScreen(timestamp: timestamp));
      case reportProblem:
        return createAnimatedRoute(const ReportProblemScreen());
      case dietSuccess:
        final timestamp = (settings.arguments is DateTime)
            ? settings.arguments as DateTime
            : DateTime.now();
        return createAnimatedRoute(DietSuccessScreen(timestamp: timestamp));
      case recordSuccess:
        final args = settings.arguments as Map<String, dynamic>?;
        final profileName = args?['profileName'] as String? ?? '';
        final date = args?['date'] as DateTime? ?? DateTime.now();
        return createAnimatedRoute(
          RecordSuccessScreen(profileName: profileName, date: date),
        );
      case routineSuccess:
        return createAnimatedRoute(const RoutineSuccessScreen());
      // In app_router.dart

      case purchase:
        final args = settings.arguments as Map<String, dynamic>;
        return createAnimatedRoute(
          PurchaseScreen(
            planName: args['planName'],
            price: args['price'],
            period: args['period'],
          ),
        );
      case premiumStatus:
        final args = settings.arguments as Map<String, dynamic>;
        return createAnimatedRoute(
          PremiumStatusScreen(
            status: args['status'],
            amount: args['amount'],
            planName: args['planName'],
            serviceCharge: args['serviceCharge'],
            discount: args['discount'],
            gst: args['gst'],
          ),
        );
      case mealRoutineHistory:
        return createAnimatedRoute(const MealRoutineHistoryScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
