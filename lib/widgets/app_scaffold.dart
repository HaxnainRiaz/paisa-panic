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
  });

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;
    final isMobile = !isWeb;

    // Drawer only on Dashboard; back button on all other screens
    final isDashboard = currentRoute == AppRoutes.dashboard;
    final showBackButton = !isDashboard;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        // If we're on the dashboard, allow the framework to show the drawer icon when a drawer is present.
        automaticallyImplyLeading: !showBackButton,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // Pop if possible, otherwise go back to the dashboard
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).maybePop();
                  } else {
                    Navigator.of(
                      context,
                    ).pushReplacementNamed(AppRoutes.dashboard);
                  }
                },
              )
            : null,
        actions: [
          if (actions != null) ...actions!,
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
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
      ),
      drawer: isMobile && isDashboard
          ? AppDrawer(currentRoute: currentRoute)
          : null,
      endDrawer: isWeb && isDashboard
          ? AppDrawer(currentRoute: currentRoute)
          : null,
      body: SafeArea(child: body),
      bottomNavigationBar: isMobile && showBottomNav
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
