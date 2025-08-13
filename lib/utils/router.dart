import 'package:go_router/go_router.dart';
import '../models/produk_model.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard/bottomnav_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/produk/add_produk_screen.dart';
import '../screens/produk/detail_produk_screen.dart';
import '../screens/produk/edit_produk_screen.dart';
import '../screens/produk/produk_screen.dart';
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
    GoRoute(path: '/produk', builder: (context, state) => const ProdukScreen()),
    GoRoute(
      path: '/addProduk',
      builder: (context, state) => const AddProductScreen(),
    ),
    GoRoute(
      path: '/produk-detail',
      builder: (context, state) {
        final produk = state.extra as ProdukModel;
        return DetailProdukScreen(produk: produk);
      },
    ),
    GoRoute(
      path: '/editProduk',
      builder: (context, state) {
        final produk = state.extra as ProdukModel;
        return EditProdukScreen(produk: produk);
      },
    ),
  ],
);
