import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../widgets/comon/responsive_wrapper.dart';

class AdminSettings extends StatelessWidget {
  const AdminSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveWrapper.isMobile(context) ? 16 : 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildAccountInfo(context),
            const SizedBox(height: 24),
            _buildSecuritySection(context),
            const SizedBox(height: 24),
            _buildAboutSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your account settings and preferences',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildAccountInfo(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Information',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              _buildInfoRow(
                context,
                icon: Icons.person_outline,
                label: 'Name',
                value: adminProvider.userDisplayName,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                icon: Icons.email_outlined,
                label: 'Email',
                value: adminProvider.userEmail,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                icon: Icons.verified_user_outlined,
                label: 'Email Verified',
                value: adminProvider.isEmailVerified ? 'Yes' : 'No',
                valueColor: adminProvider.isEmailVerified
                    ? Colors.green
                    : Colors.orange,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textHint),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: valueColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.lock_outline, color: AppTheme.primaryColor),
            title: const Text('Change Password'),
            subtitle: const Text('Update your account password'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showChangePasswordDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            icon: Icons.info_outline,
            label: 'Version',
            value: '1.0.0',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            icon: Icons.code,
            label: 'Built with',
            value: 'Flutter & Firebase',
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Password reset email will be sent to your registered email address.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final adminProvider = Provider.of<AdminProvider>(
                context,
                listen: false,
              );
              final email = adminProvider.userEmail;

              final success = await adminProvider.sendPasswordReset(email);

              if (context.mounted) {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Password reset email sent!'
                          : ' Failed to send email',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Send Reset Email'),
          ),
        ],
      ),
    );
  }
}
