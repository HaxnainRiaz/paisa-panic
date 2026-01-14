import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'transaction_history_screen.dart';
import 'budget_screen.dart';
import 'reports_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../theme/theme.dart';
import '../routes/app_routes.dart';

class MainWrapper extends StatefulWidget {
  final int initialIndex;
  const MainWrapper({super.key, this.initialIndex = 0});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  late int _currentIndex;
  late PageController _pageController;

  final List<Widget> _pages = [
    const DashboardScreen(hideShellElements: true),
    TransactionHistoryScreen(hideShellElements: true, key: TransactionHistoryScreen.historyKey),
    const BudgetScreen(hideShellElements: true),
    const ReportsScreen(hideShellElements: true),
    const ProfileScreen(hideShellElements: true),
  ];

  final List<String> _routes = [
    AppRoutes.dashboard,
    AppRoutes.transactionHistory,
    AppRoutes.budget,
    AppRoutes.reports,
    AppRoutes.profile,
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavBarTapped(String route) {
    final index = _routes.indexOf(route);
    if (index != -1 && index != _currentIndex) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _currentIndex == 0 ? null : Text(_getPageTitle(_currentIndex)),
        actions: [
          ..._getPageActions(context),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.dashboard),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentRoute: _routes[_currentIndex],
        onTap: _onNavBarTapped,
      ),
    );
  }

  List<Widget> _getPageActions(BuildContext context) {
    if (_currentIndex == 1) {
      return [
        IconButton(
          icon: const Icon(Icons.filter_list_rounded),
          onPressed: () {
            TransactionHistoryScreen.historyKey.currentState?.showFilterDialog(context);
          },
        ),
      ];
    }
    return [];
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0: return 'Paisa Panic';
      case 1: return 'History';
      case 2: return 'Budget';
      case 3: return 'Reports';
      case 4: return 'Profile';
      default: return 'Paisa Panic';
    }
  }
}
