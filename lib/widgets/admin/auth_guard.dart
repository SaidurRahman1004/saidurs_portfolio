import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../screens/admin/auth/login_screen.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        // Show loading while checking auth state
        if (adminProvider.currentUser == null) {
          // Not authenticated - show login screen
          return const LoginScreen();
        }

        if (adminProvider.isCheckingAdmin) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!adminProvider.isAdmin) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 56),
                    const SizedBox(height: 16),
                    Text(
                      'Admin authorization required',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Set the Firebase custom claim { admin: true } for this account, then sign in again.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => adminProvider.logout(),
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign out'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Authenticated - show protected content
        return child;
      },
    );
  }
}
