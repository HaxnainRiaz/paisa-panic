import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'app_drawer.dart';
import 'bottom_nav_bar.dart';
import '../routes/app_routes.dart';

/// Main scaffold wrapper with AppBar, Drawer, and BottomNav
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final String currentRoute;
  final List<Widget>? actions;
  final bool showBottomNav;
  final FloatingActionButton? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.currentRoute,
    this.actions,
    this.showBottomNav = true,
    this.floatingActionButton,
    this.hideShellElements = false,
  });

  final bool hideShellElements;

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;
    final isMobile = !isWeb;

    // Drawer only on Dashboard; back button on all other screens
    final isDashboard = currentRoute == AppRoutes.dashboard;
    final showBackButton = !isDashboard;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: hideShellElements ? null : AppBar(
        title: Text(title),
        // If we're on the dashboard, allow the framework to show the drawer icon
        automaticallyImplyLeading: true, // Let Scaffold handle drawer vs back button
        actions: [
          if (actions != null) ...actions!,
          if (!isDashboard) ...[
            if (currentRoute == AppRoutes.profile)
              const SizedBox.shrink()
            else
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.profile);
                },
              ),
          ],
        ],
      ),
      drawer: isMobile && isDashboard
          ? AppDrawer(currentRoute: currentRoute)
          : null,
      endDrawer: isWeb && isDashboard
          ? AppDrawer(currentRoute: currentRoute)
          : null,
      body: SafeArea(child: body),
      bottomNavigationBar: isMobile && showBottomNav && !hideShellElements
          ? BottomNavBar(
              currentRoute: currentRoute,
              onTap: (route) {
                Navigator.of(context).pushReplacementNamed(route);
              },
            )
          : null,
      floatingActionButton: floatingActionButton,
    );
  }
}
