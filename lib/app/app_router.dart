import 'package:flutter/material.dart';
import 'package:nuroved_patient/features/diet/screens/ai_diet_planner_screen.dart';
import 'package:nuroved_patient/features/diet/screens/diet_output_screen.dart';
import 'package:nuroved_patient/features/diet/screens/diet_preference_screen.dart';
import 'package:nuroved_patient/features/diet/screens/edit_meal_screen.dart';
import 'package:nuroved_patient/features/diet/screens/food_scanner_history_screen.dart';
import 'package:nuroved_patient/features/diet/screens/meal_routine_history_screen.dart';
import 'package:nuroved_patient/features/home/screens/main_layout.dart';
import 'package:nuroved_patient/features/settings/screens/customer_support_screen.dart';

// 1. Core and Wrapper Imports
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
import '../features/routine/screens/routine_screen.dart';
import '../features/settings/screens/app_settings_screen.dart';
import '../features/settings/screens/change_email_screen.dart';
import '../features/settings/screens/change_password_screen.dart';
import '../features/settings/screens/data_privacy_screen.dart';
import '../features/settings/screens/report_problem_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/visits/screens/add_visit_screen.dart';
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
  static const String aiDietPlanner = '/ai-diet-planner';
  static const String dietPreference = '/diet-preference';
  static const String healthGoal = '/health-goal';
  static const String familyProfiles = '/family-profiles';
  static const String timeAndContext = '/time-and-context';
  static const String dietOutput = '/diet-output';
  static const String mealRoutineHistory = '/meal-routine-history';
  static const String foodScannerHistory = '/food-scanner-history';
  static const String calorieSuccess = '/calorie-success';
  static const String editMeal = '/edit-meal';
  static const String premiumStatus = '/premium-status';
  static const String appSettings = '/app-settings';
  static const String dataPrivacy = '/data-privacy';
  static const String customerSupport = '/customer-support';
  static const String changeEmail = '/change-email';
  static const String changePassword = '/change-password';
  static const String reportProblem = '/report-problem';
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Helper function to create an animated route that triggers the skeleton
    Route _createAnimatedRoute(Widget child) {
      return PageRouteBuilder(
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
        return MaterialPageRoute(builder: (_) => const LoadingScreen());

      case splash:
        return _createAnimatedRoute(const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      // Change the home case to this:
      case home:
        return PageRouteBuilder(
          maintainState: false, // Important for "Back" button re-animation
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainLayout(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );

      case records:
        return _createAnimatedRoute(const RecordsScreen());

      case visits:
        return _createAnimatedRoute(const VisitsScreen());

      case profile:
        return _createAnimatedRoute(const ProfileScreen());

      case notifications:
        return _createAnimatedRoute(const NotificationsScreen());

      case access:
        return _createAnimatedRoute(const AccessScreen());

      case diet:
        return _createAnimatedRoute(const DietScreen());

      case routine:
        return _createAnimatedRoute(const RoutineScreen());
      case premium: // Handle premium route
        return _createAnimatedRoute(const PremiumScreen());

      case aiDietPlanner:
        return _createAnimatedRoute(const AiDietPlannerScreen());
      // Inside generateRoute switch:
      case dietPreference:
        return _createAnimatedRoute(const DietPreferenceScreen());
      case addVisit:
        return MaterialPageRoute(builder: (_) => const AddVisitScreen());
      case healthGoal:
        return _createAnimatedRoute(const HealthGoalScreen());
      case familyProfiles:
        return _createAnimatedRoute(const FamilyProfilesScreen());
      case timeAndContext:
        return _createAnimatedRoute(const TimeAndContextScreen());
      case dietOutput:
        return _createAnimatedRoute(const DietOutputScreen());
      case foodScannerHistory:
        return _createAnimatedRoute(const FoodScannerHistoryScreen());
      case editMeal:
        return _createAnimatedRoute(const EditMealScreen());
      case settingsRoute:
        return _createAnimatedRoute(const SettingsScreen());
      case appSettings:
        return _createAnimatedRoute(const AppSettingsScreen());
      case dataPrivacy:
        return _createAnimatedRoute(const DataPrivacyScreen());
      case customerSupport:
        return _createAnimatedRoute(const CustomerSupportScreen());
      case changeEmail:
        return _createAnimatedRoute(const ChangeEmailScreen());
      case changePassword:
        return _createAnimatedRoute(const ChangePasswordScreen());
      case calorieSuccess:
        final timestamp = settings.arguments as DateTime;
        return _createAnimatedRoute(CalorieSuccessScreen(timestamp: timestamp));
      case reportProblem:
        return _createAnimatedRoute(const ReportProblemScreen());
      case '/diet-success':
        final timestamp = settings.arguments as DateTime;
        return MaterialPageRoute(
          builder: (_) => DietSuccessScreen(timestamp: timestamp),
        );
      // In app_router.dart

      case purchase:
        final args = settings.arguments as Map<String, dynamic>;
        return _createAnimatedRoute(
          PurchaseScreen(
            planName: args['planName'],
            price: args['price'],
            period: args['period'],
          ),
        );
      case premiumStatus:
        final args = settings.arguments as Map<String, dynamic>;
        return _createAnimatedRoute(
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
        return _createAnimatedRoute(const MealRoutineHistoryScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
