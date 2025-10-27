import 'package:event_management_app1/core/services/profile_service.dart';
import 'package:event_management_app1/core/services/auth_storage_service.dart';
import 'package:event_management_app1/features/user/widgets/user_profile_widgets/logout_button.dart';
import 'package:event_management_app1/features/user/widgets/user_profile_widgets/profile_header.dart';
import 'package:event_management_app1/features/user/widgets/user_profile_widgets/profile_info_card.dart';
import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final profileData = await ProfileService.getUserProfile();
      
      setState(() {
        _userData = profileData;
        _isLoading = false;
        _error = '';
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _logout() async {
    await AuthStorageService.clear();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _loginAgain() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _error,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _error.contains('not authenticated') 
                          ? _loginAgain 
                          : _loadUserData,
                      child: Text(
                        _error.contains('not authenticated') 
                            ? 'Login Again' 
                            : 'Retry'
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ProfileHeader(
                      name: _userData?['name'] ?? 'User',
                      email: _userData?['email'] ?? '',
                      isOrganizer: _userData?['isOrganizer'] == true,
                    ),
                    const SizedBox(height: 24),
                    ProfileInfoCard(
                      name: _userData?['name'] ?? 'Not set',
                      email: _userData?['email'] ?? 'Not set',
                      role: (_userData?['isOrganizer'] == true) ? 'Organizer' : 'User',
                      memberSince: _formatDate(_userData?['createdAt']),
                    ),
                    const SizedBox(height: 24),
                    LogoutButton(onLogout: _logout),
                  ],
                ),
              ),
    );
  }
}