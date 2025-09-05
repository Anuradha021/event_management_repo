import 'package:event_management_app1/core/services/auth_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:event_management_app1/core/services/admin_service.dart';
import 'package:event_management_app1/core/services/auth_service.dart';

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
      setState(() {
        _isSystemAdmin = meResult.user!.role == 'SYSTEM_ADMIN';
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

  Future<void> _promoteToAdmin(BuildContext context, String userId) async {
    final result = await AdminService.updateUserRole(userId, role: 'admin');
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User promoted to Admin")),
      );
      _loadUsers(); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${result['message']}")),
      );
    }
  }

  Future<void> _demoteFromAdmin(BuildContext context, String userId) async {
    final result = await AdminService.updateUserRole(userId, role: 'user');
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Admin demoted to User")),
      );
      _loadUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${result['message']}")),
      );
    }
  }

  Future<void> _promoteToOrganizer(BuildContext context, String userId, String userName) async {
   
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Assign as Organizer'),
          content: Text('Are you sure you want to assign $userName as an Organizer?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Confirm', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final result = await AdminService.updateUserRole(userId, isOrganizer: true);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$userName has been assigned as Organizer')),
        );
        _loadUsers(); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['message']}')),
        );
      }
    }
  }

  Future<void> _demoteFromOrganizer(BuildContext context, String userId, String userName) async {
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Organizer Role'),
          content: Text('Are you sure you want to remove $userName from Organizer role?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Remove', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final result = await AdminService.updateUserRole(userId, isOrganizer: false);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$userName has been removed from Organizer role')),
        );
        _loadUsers();  
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['message']}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthStorageService.getCurrentUserId();

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isSystemAdmin) {
      return const Scaffold(
        body: Center(child: Text("Access Denied. Only System Admin can manage users.")),
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
      body: _users.isEmpty
          ? const Center(child: Text("No users found"))
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                final userId = user['id'] ?? '';
                final userName = user['name'] ?? 'Unnamed';
                final userEmail = user['email'] ?? 'No Email';
                final role = user['role'] ?? 'user';
                final isAdmin = role == 'admin';
                final isOrganizer = user['isOrganizer'] == true;
                final isSystemAdmin = user['isSystemAdmin'] == true;
                final isCurrentUser = currentUserId == userId;

                if (isSystemAdmin || isCurrentUser) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple,
                        child: const Icon(Icons.admin_panel_settings, color: Colors.white),
                      ),
                      title: Text(userName),
                      subtitle: Text('$userEmail\nSystem Admin'),
                      trailing: const Chip(
                        label: Text('System Admin'),
                        backgroundColor: Colors.purple,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isAdmin
                          ? Colors.red
                          : isOrganizer
                              ? Colors.green
                              : Colors.blue,
                      child: Icon(
                        isAdmin
                            ? Icons.security
                            : isOrganizer
                                ? Icons.event
                                : Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(userName),
                    subtitle: Text('$userEmail\n${isAdmin ? 'Admin' : isOrganizer ? 'Organizer' : 'User'}'),
                    trailing: SizedBox(
                      width: 200,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                         
                          if (isAdmin)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                minimumSize: const Size(80, 32),
                              ),
                              onPressed: () => _demoteFromAdmin(context, userId),
                              child: const Text("Remove Admin",
                                  style: TextStyle(color: Colors.white, fontSize: 10)),
                            )
                          else
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(80, 32),
                              ),
                              onPressed: () => _promoteToAdmin(context, userId),
                              child: const Text("Make Admin", style: TextStyle(fontSize: 10)),
                            ),

                          const SizedBox(width: 8),

                          if (isOrganizer)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                minimumSize: const Size(80, 32),
                              ),
                              onPressed: () => _demoteFromOrganizer(context, userId, userName),
                              child: const Text("Remove Org",
                                  style: TextStyle(color: Colors.white, fontSize: 10)),
                            )
                          else
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                minimumSize: const Size(80, 32),
                              ),
                              onPressed: () => _promoteToOrganizer(context, userId, userName),
                              child: const Text("Make Org",
                                  style: TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}