import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/config/app_theme.dart';
import 'home_screen.dart'; 
import 'user_events_tab_screen.dart';
import 'tickets/user_tickets_overview_screen.dart';
import 'userProfile/user_profile_screen.dart';
import '../../admin/screens/admin_dashboard.dart';
import '../../admin/screens/user_permission.dart';

class UnifiedDashboard extends StatefulWidget {
  const UnifiedDashboard({super.key});

  @override
  State<UnifiedDashboard> createState() => _UnifiedDashboardState();
}

class _UnifiedDashboardState extends State<UnifiedDashboard> {
  int _currentIndex = 0;
  late List<Widget> _pages;
  bool _isSystemAdmin = false;
  bool _isRegularAdmin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final result = await UserPermissionService.checkPermissions();
    
    setState(() {
      _isSystemAdmin = result['isSystemAdmin'] ?? false;
      _isRegularAdmin = result['isRegularAdmin'] ?? false;
      _isLoading = false;
      
      // Debug output
      print('UnifiedDashboard - isSystemAdmin: $_isSystemAdmin');
      print('UnifiedDashboard - isRegularAdmin: $_isRegularAdmin');
      
      // Set up pages based on user role
      if (_isSystemAdmin || _isRegularAdmin) {
        // Admin users see admin dashboard as home screen
        _pages = [
          const AdminDashboard(), // Admin dashboard as home
          const UserEventsTabScreen(),
          const UserTicketsOverviewScreen(),
          const UserProfileScreen(),
        ];
      } else {
        // Regular users see regular home screen
        _pages = [
          const UnifiedHomeScreen(), 
          const UserEventsTabScreen(),
          const UserTicketsOverviewScreen(),
          const UserProfileScreen(),
        ];
      }
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // For admin users, show the admin dashboard without bottom navigation
    if (_isSystemAdmin || _isRegularAdmin) {
      return const AdminDashboard();
    }

    // For regular users, show the bottom navigation with regular pages
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}