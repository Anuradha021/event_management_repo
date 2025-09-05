import 'package:event_management_app1/core/services/auth_service.dart';
import 'package:event_management_app1/core/services/auth_storage_service.dart';

class UserPermissionService {
  static Future<Map<String, bool>> checkPermissions() async {
    final token = await AuthStorageService.getToken();
    if (token == null) return {'isSystemAdmin': false, 'isRegularAdmin': false};

    try {
      final meResult = await AuthService().meWithToken(token);
      if (meResult.isSuccess && meResult.user != null) {
        final user = meResult.user!;
        return {
          'isSystemAdmin': user.role == 'SYSTEM_ADMIN',
          'isRegularAdmin': user.role == 'ADMIN' || user.role == 'SYSTEM_ADMIN',
        };
      }
    } catch (e) {
      print('Error checking user permissions: $e');
    }
    
    return {'isSystemAdmin': false, 'isRegularAdmin': false};
  }
}