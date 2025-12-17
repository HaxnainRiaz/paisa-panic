import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../routes/app_routes.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// App drawer for navigation
class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.calculate, size: 40, color: Colors.white),
                  const SizedBox(height: 8),
                  const Text(
                    'Math Says I\'m Broke',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (authProvider.user != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      authProvider.user!.email ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    route: AppRoutes.dashboard,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.add_circle_outline,
                    title: 'Add Income',
                    route: AppRoutes.addIncome,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.remove_circle_outline,
                    title: 'Add Expense',
                    route: AppRoutes.addExpense,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.receipt_long,
                    title: 'Transactions',
                    route: AppRoutes.transactionHistory,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.savings,
                    title: 'Budget',
                    route: AppRoutes.budget,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.analytics,
                    title: 'Reports',
                    route: AppRoutes.reports,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.category,
                    title: 'Categories',
                    route: AppRoutes.categories,
                  ),
                  const Divider(),
                  _buildDrawerItem(
                    context,
                    icon: Icons.person,
                    title: 'Profile & Settings',
                    route: AppRoutes.profile,
                  ),
                ],
              ),
            ),

            // Logout button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: ListTile(
                leading: const Icon(Icons.logout, color: AppColors.warning),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.login,
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    final isSelected = currentRoute == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.secondary : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.secondary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        if (currentRoute != route) {
          Navigator.of(context).pushReplacementNamed(route);
        } else {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
