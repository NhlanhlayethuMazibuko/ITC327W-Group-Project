import 'package:go_router/go_router.dart';
import '../../views/auth/splash_screen.dart';
import '../../views/auth/welcome_screen.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/profile/profile_screen.dart';
import '../../views/home/home_screen.dart';
import '../../views/applications/application_step1_screen.dart';
import '../../views/applications/application_step2_screen.dart';
import '../../views/applications/application_step3_screen.dart';
import '../../views/applications/application_step4_screen.dart';
import '../../views/applications/application_tracker_screen.dart';
import '../../views/applications/application_submitted_screen.dart';
import '../../views/auth/forgot_password_screen.dart';
import 'package:bigbrother/views/rooms/available_rooms_screen.dart';
import '../../views/rooms/room_details_screen.dart';
import '../../views/maintenance/maintenance_request_screen.dart';
import '../../views/maintenance/new_maintenance_request_screen.dart';
import '../../views/maintenance/maintenance_details_screen.dart';
import '../../views/viewings/book_viewing_screen.dart';
import '../../views/viewings/booking_details_screen.dart';
import '../../views/viewings/scheduled_viewings_screen.dart';
import '../../views/viewings/viewing_details_screen.dart';
import '../../views/viewings/viewing_submitted_screen.dart';

class RouteNames {
  static const splash = '/';

  static const welcome = '/welcome';

  static const login = '/login';

  static const register = '/register';

  static const forgotPassword = '/forgot-password';

  static const verifyEmail = '/verify-email';

  static const resetPassword = '/reset-password';

  static const home = '/home';

  static const rooms = '/rooms';

  static const application = '/application';

  static const profile = '/profile';

  // VIEWINGS

  static const scheduledViewings = '/scheduled-viewings';

  static const bookViewing = '/book-viewing';

  static const bookingDetails = '/booking-details';

  static const viewingSubmitted = '/viewing-submitted';

  static const viewingDetails = '/viewing-details';

  /*static const applicationStep1 =
    '/application-step-1';*/

  static const applicationStep2 = '/application-step-2';

  static const applicationStep3 = '/application-step-3';

  static const applicationStep4 = '/application-step-4';

  static const applicationTracker = '/application-tracker-screen';

  static const applicationSubmitted = '/application-submitted-screen';

  static const roomDetails = '/room-details';

  static const maintenanceRequests = '/maintenance-requests';

  static const newMaintenanceRequest = '/new-maintenance-request';

  static const maintenanceDetail = '/maintenance-detail';
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: RouteNames.splash,

    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: RouteNames.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),

      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),

      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: RouteNames.application,
        builder: (context, state) => const ApplicationStep1Screen(),
      ),

      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) {
          return const ProfileScreen();
        },
      ),

      GoRoute(
        path: '/application-step-2',
        builder: (context, state) => const ApplicationStep2Screen(),
      ),

      GoRoute(
        path: '/application-step-3',
        builder: (context, state) => const ApplicationStep3Screen(),
      ),

      GoRoute(
        path: '/application-step-4',
        builder: (context, state) => const ApplicationStep4Screen(),
      ),

      GoRoute(
        path: '/application-submitted-screen',
        builder: (context, state) => const ApplicationSubmittedScreen(),
      ),

      GoRoute(
        path: '/application-tracker-screen',
        builder: (context, state) => const ApplicationTrackerScreen(),
      ),

      GoRoute(
        path: '/rooms',

        builder: (context, state) => const AvailableRoomsScreen(),
      ),

      GoRoute(
        path: RouteNames.roomDetails,
        builder: (context, state) => const RoomDetailsScreen(),
      ),

      GoRoute(
        path: '/maintenance-requests',
        builder: (context, state) {
          return const MaintenanceRequestsScreen();
        },
      ),

      GoRoute(
        path: '/new-maintenance-request',
        builder: (context, state) {
          return const NewMaintenanceRequestScreen();
        },
      ),

      GoRoute(
        path: '/maintenance-detail',
        builder: (context, state) {
          return const MaintenanceDetailScreen();
        },
      ),

      GoRoute(
        path: '/scheduled-viewings',
        builder: (context, state) {
          return const ScheduledViewingsScreen();
        },
      ),

      GoRoute(
        path: '/book-viewing',
        builder: (context, state) {
          return const BookViewingScreen();
        },
      ),

      GoRoute(
        path: '/booking-details',
        builder: (context, state) {
          return const BookingDetailsScreen();
        },
      ),

      GoRoute(
        path: '/viewing-submitted',
        builder: (context, state) {
          return const ViewingSubmittedScreen();
        },
      ),

      GoRoute(
        path: '/viewing-details',
        builder: (context, state) {
          return const ViewingDetailsScreen();
        },
      ),
    ],
  );
}
