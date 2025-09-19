import 'package:go_router/go_router.dart';
import 'package:sapa/models/hasil_model.dart';
import 'package:sapa/screens/admin/form_admin_screen.dart';
import '../models/anak_model.dart';
import '../models/user_profile_model.dart';
import '../screens/admin/admin_screen.dart';
import '../screens/admin/detail_admin_screen.dart';
import '../screens/hasil/detail_hasil_screen.dart';
import '../screens/hasil/pilih_hasil_anak_screen.dart';
import '../screens/stppa/penilaian_screen.dart';
import '../screens/stppa/pilih_anak_screen.dart';
import '../screens/stppa/stppa_screen.dart';
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
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => DashboardScreen(),
      routes: [
      
    ]),
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
    GoRoute(path: '/admin', builder: (context, state) => const AdminScreen()),
    GoRoute(
      path: '/formAdmin',
      builder: (context, state) {
        final admin = state.extra as UserProfile?;
        return FormAdminScreen(admin: admin);
      },
    ),
    GoRoute(
      path: '/detailAdmin',
      builder: (context, state) {
        final admin = state.extra as UserProfile;
        return DetailAdminScreen(admin: admin);
      },
    ),
    GoRoute(path: '/stppa', builder: (context, state) => const StppaScreen()),
    GoRoute(
      path: '/pilihAnak',
      builder: (context, state) => const PilihAnakScreen(),
    ),
    GoRoute(
      path: '/penilaian',
      builder: (context, state) {
        final anak = state.extra as AnakModel;
        return PenilaianScreen(anak: anak);
      },
    ),
    GoRoute(
      path: '/hasil',
      builder: (context, state) => const PilihHasilAnakScreen(),
    ),
    GoRoute(
      path: '/detailHasil',
      builder: (context, state) {
        final hasil = state.extra as List<HasilModel>;
        return DetailHasilScreen(hasilList: hasil);
      },
    ),
  ],
);
