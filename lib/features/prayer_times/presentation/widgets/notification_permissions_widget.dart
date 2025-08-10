import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/notification_providers.dart';

/// Widget displaying notification permissions status and management
class NotificationPermissionsWidget extends ConsumerWidget {

  const NotificationPermissionsWidget({
    required this.permissions, super.key,
  });
  final NotificationPermissionsState permissions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getOverallStatusColor().withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildPermissionsList(ref),
          const SizedBox(height: 16),
          _buildOverallStatus(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          _getOverallStatusIcon(),
          color: _getOverallStatusColor(),
          size: 20,
        ),
        const SizedBox(width: 8),
        const Text(
          'Notification Permissions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getOverallStatusColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getOverallStatusText(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _getOverallStatusColor(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionsList(WidgetRef ref) {
    return Column(
      children: [
        _buildPermissionItem(
          'Notifications',
          'Required for prayer time alerts',
          Icons.notifications,
          permissions.notificationPermission,
          () => ref.read(notificationPermissionsProvider.notifier)
              .requestNotificationPermission(),
        ),
        const SizedBox(height: 12),
        _buildPermissionItem(
          'Exact Alarms',
          'Ensures precise prayer time notifications',
          Icons.alarm,
          permissions.exactAlarmPermission,
          () => ref.read(notificationPermissionsProvider.notifier)
              .requestExactAlarmPermission(),
        ),
        const SizedBox(height: 12),
        _buildPermissionItem(
          'Do Not Disturb Override',
          'Shows prayer notifications even in DND mode',
          Icons.do_not_disturb_off,
          permissions.dndOverridePermission,
          null, // This usually requires manual system settings
        ),
      ],
    );
  }

  Widget _buildPermissionItem(
    String title,
    String description,
    IconData icon,
    bool isGranted,
    VoidCallback? onRequest,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isGranted
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isGranted
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isGranted ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isGranted ? Icons.check_circle : Icons.warning,
                      color: isGranted ? Colors.green[600] : Colors.orange[600],
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (!isGranted && onRequest != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRequest,
              style: TextButton.styleFrom(
                backgroundColor: Colors.orange.withOpacity(0.2),
                foregroundColor: Colors.orange[700],
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Grant',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverallStatus() {
    final allGranted = permissions.notificationPermission &&
        permissions.exactAlarmPermission;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: allGranted
              ? [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)]
              : [Colors.orange.withOpacity(0.1), Colors.orange.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            allGranted ? Icons.check_circle : Icons.info,
            color: allGranted ? Colors.green[600] : Colors.orange[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allGranted ? 'All Set!' : 'Setup Required',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: allGranted ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  allGranted
                      ? 'Prayer notifications are properly configured'
                      : 'Some permissions are needed for full functionality',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (!allGranted) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.orange[600],
              size: 16,
            ),
          ],
        ],
      ),
    );
  }

  Color _getOverallStatusColor() {
    final allGranted = permissions.notificationPermission &&
        permissions.exactAlarmPermission;
    return allGranted ? Colors.green : Colors.orange;
  }

  IconData _getOverallStatusIcon() {
    final allGranted = permissions.notificationPermission &&
        permissions.exactAlarmPermission;
    return allGranted ? Icons.verified : Icons.warning;
  }

  String _getOverallStatusText() {
    final allGranted = permissions.notificationPermission &&
        permissions.exactAlarmPermission;
    return allGranted ? 'Ready' : 'Setup Needed';
  }
}
