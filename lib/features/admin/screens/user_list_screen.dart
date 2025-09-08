import 'package:event_management_app1/core/services/admin_service.dart';
import 'package:event_management_app1/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:event_management_app1/core/services/auth_storage_service.dart';
import 'package:event_management_app1/features/admin/widgets/user_list_item.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  bool _isLoading = true;
  bool _isSystemAdmin = false;
  List<dynamic> _users = [];

  @override
  void initState() {
    super.initState();
    _checkSystemAdminStatus();
    _loadUsers();
  }

  Future<void> _checkSystemAdminStatus() async {
    final token = await AuthStorageService.getToken();
    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    final meResult = await AuthService().meWithToken(token);
    if (meResult.isSuccess && meResult.user != null) {
      final isSystemAdmin = meResult.user!.email == 'admin21@event.com';
      setState(() {
        _isSystemAdmin = isSystemAdmin;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUsers() async {
    final result = await AdminService.getUsers();
    if (result['success']) {
      setState(() => _users = result['data']['users'] ?? []);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading users: ${result['message']}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isSystemAdmin) {
      return const Scaffold(
        body: Center(
          child: Text("Access Denied. Only System Admin can manage users."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Users"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Refresh Users',
          ),
        ],
      ),
      body:
          _users.isEmpty
              ? const Center(child: Text("No users found"))
              : ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return UserListItem(user: user, onUserUpdated: _loadUsers);
                },
              ),
    );
  }
}
