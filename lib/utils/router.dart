import 'package:go_router/go_router.dart';
import '../models/anak_model.dart';
import '../models/user_profile_model.dart';
import '../screens/STPPA/stppa_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard/bottomnav_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/anak/form_anak_screen.dart';
import '../screens/anak/detail_anak_screen.dart';
import '../screens/anak/anak_screen.dart';
import '../screens/guru/detail_guru_screen.dart';
import '../screens/guru/form_guru_screen.dart';
import '../screens/guru/guru_screen.dart';
import '../screens/profile/profile_screen.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(path: '/bottomNav', builder: (context, state) => const BottomNav()),
    GoRoute(path: '/dashboard', builder: (context, state) => DashboardScreen()),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(path: '/anak', builder: (context, state) => const AnakScreen()),
    GoRoute(
      path: '/formAnak',
      builder: (context, state) {
        final anak = state.extra as AnakModel?;
        return FormAnakScreen(anak: anak);
      },
    ),
    GoRoute(
      path: '/detailAnak',
      builder: (context, state) {
        final anak = state.extra as AnakModel;
        return DetailAnakScreen(anak: anak);
      },
    ),
    GoRoute(path: '/guru', builder: (context, state) => const GuruScreen()),
    GoRoute(
      path: '/formGuru',
      builder: (context, state) {
        final guru = state.extra as UserProfile?;
        return FormGuruScreen(guru: guru);
      },
    ),
    GoRoute(
      path: '/detailGuru',
      builder: (context, state) {
        final guru = state.extra as UserProfile;
        return DetailGuruScreen(guru: guru);
      },
    ),
    GoRoute(path: '/stppa', builder: (context, state) => const StppaScreen()),
  ],
);
