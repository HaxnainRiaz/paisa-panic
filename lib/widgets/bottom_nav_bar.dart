import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../routes/app_routes.dart';

/// Bottom navigation bar for mobile
class BottomNavBar extends StatelessWidget {
  final String currentRoute;
  final Function(String) onTap;

  const BottomNavBar({
    super.key,
    required this.currentRoute,
    required this.onTap,
  });

  int _getCurrentIndex() {
    switch (currentRoute) {
      case AppRoutes.dashboard:
        return 0;
      case AppRoutes.transactionHistory:
        return 1;
      case AppRoutes.budget:
        return 2;
      case AppRoutes.reports:
        return 3;
      case AppRoutes.profile:
        return 4;
      default:
        return 0;
    }
  }

  void _onItemTapped(int index, BuildContext context) {
    String route;
    switch (index) {
      case 0:
        route = AppRoutes.dashboard;
        break;
      case 1:
        route = AppRoutes.transactionHistory;
        break;
      case 2:
        route = AppRoutes.budget;
        break;
      case 3:
        route = AppRoutes.reports;
        break;
      case 4:
        route = AppRoutes.profile;
        break;
      default:
        route = AppRoutes.dashboard;
    }
    onTap(route);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _getCurrentIndex(),
      onTap: (index) => _onItemTapped(index, context),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.secondary,
      unselectedItemColor: AppColors.textSecondary,
      backgroundColor: AppColors.cardSurface,
      elevation: 0, // Removed elevation for a flatter, modern look
      selectedFontSize: 10,
      unselectedFontSize: 10,
      iconSize: 20,
      items: const [
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(Icons.dashboard_rounded),
          ),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(Icons.receipt_long_rounded),
          ),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(Icons.savings_rounded),
          ),
          label: 'Budget',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(Icons.analytics_rounded),
          ),
          label: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(Icons.person_rounded),
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}

