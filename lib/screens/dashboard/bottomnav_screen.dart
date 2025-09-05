import 'package:flutter/material.dart';
import 'package:sapa/screens/dashboard/dashboard_screen.dart';
import 'package:sapa/screens/profile/profile_screen.dart';
import 'package:sapa/widgets/app_colors.dart';
import '../../widgets/my_double_tap_exit.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;

  final List<Widget> _pages = [DashboardScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return MyDoubleTapExit(
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() => _currentIndex = index);
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
              backgroundColor: AppColors.primary,
              selectedItemColor: Colors.brown[800],
              unselectedItemColor: Colors.brown[300],
            ),
          ),
        ),
      ),
    );
  }
}
