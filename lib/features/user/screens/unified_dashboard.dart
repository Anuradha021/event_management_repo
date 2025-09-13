import 'package:event_management_app1/features/organizer/screens/events/Event_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/config/app_theme.dart';
import 'home_screen.dart'; 
import 'tickets/user_tickets_overview_screen.dart';
import 'user_profile_screen.dart';
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
  final GlobalKey<HomeScreenState> _homeScreenKey = GlobalKey<HomeScreenState>();

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  void _refreshHomeScreen() {
    _homeScreenKey.currentState?.loadEvents();
  }

  Future<void> _checkUserRole() async {
    final result = await UserPermissionService.checkPermissions();
    
    setState(() {
      _isSystemAdmin = result['isSystemAdmin'] ?? false;
      _isRegularAdmin = result['isRegularAdmin'] ?? false;
      _isLoading = false;
      
      
    
      if (_isSystemAdmin || _isRegularAdmin) {
        _pages = [
          const AdminDashboard(), 
          
        ];
      } else {
        _pages = [
          HomeScreen(key: _homeScreenKey), 
          EventScreen(onEventPublished: _refreshHomeScreen),
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

    if (_isSystemAdmin || _isRegularAdmin) {
      return const AdminDashboard();
    }

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