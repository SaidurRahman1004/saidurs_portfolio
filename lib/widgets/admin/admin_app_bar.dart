import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../screens/public/home_screen.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed;

  const AdminAppBar({super.key, required this.title, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (isMobile) ...[
                IconButton(
                  onPressed: onMenuPressed,
                  icon: const Icon(Icons.menu),
                  tooltip: 'Menu',
                ),
                const SizedBox(width: 8),
              ],
              //Title with icon
              Icon(
                Icons.admin_panel_settings,
                color: AppTheme.primaryColor,
                size: 24,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              // View public site button
              TextButton.icon(
                onPressed: () {
                  //Home Page
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                label: Text(isMobile ? 'Site' : 'View Public Site'),
                icon: const Icon(Icons.launch, size: 18),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(64);
}
