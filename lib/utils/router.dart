import 'package:go_router/go_router.dart';
import '../models/anak_model.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard/bottomnav_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/anak/form_anak_screen.dart';
import '../screens/anak/detail_produk_screen.dart';
import '../screens/anak/edit_produk_screen.dart';
import '../screens/anak/anak_screen.dart';
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

    // GoRoute(
    //   path: '/produk-detail',
    //   builder: (context, state) {
    //     final produk = state.extra as ProdukModel;
    //     return DetailProdukScreen(produk: produk);
    //   },
    // ),
    // GoRoute(
    //   path: '/editProduk',
    //   builder: (context, state) {
    //     final produk = state.extra as ProdukModel;
    //     return EditProdukScreen(produk: produk);
    //   },
    // ),
  ],
);
