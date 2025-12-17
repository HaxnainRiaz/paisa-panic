import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'theme/theme.dart';
import 'routes/app_routes.dart';

import 'models/transaction.dart' as app_models;

import 'providers/auth_provider.dart';
import 'providers/finance_provider.dart';

import 'widgets/auth_guard.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/budget_setup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/transaction_history_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/add_transaction_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
      ],
      child: Builder(
        builder: (context) {
          // Sync FinanceProvider with current user
          final auth = Provider.of<AuthProvider>(context, listen: false);
          final finance = Provider.of<FinanceProvider>(context, listen: false);
          finance.setUser(auth.user?.uid);

          return MaterialApp(
            title: 'Math Says I\'m Broke',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute: AppRoutes.splash,
            routes: {
              // Public routes
              AppRoutes.splash: (context) => const SplashScreen(),
              AppRoutes.login: (context) => const LoginScreen(),
              AppRoutes.register: (context) => const RegisterScreen(),
              AppRoutes.forgotPassword: (context) =>
                  const ForgotPasswordScreen(),

              // Protected routes
              AppRoutes.budgetSetup: (context) =>
                  const AuthGuard(child: BudgetSetupScreen()),

              AppRoutes.dashboard: (context) =>
                  const AuthGuard(child: DashboardScreen()),

              /// ✅ Add Income (same screen, different type)
              AppRoutes.addIncome: (context) => AuthGuard(
                child: AddTransactionScreen(
                  type: app_models.TransactionType.income,
                ),
              ),

              /// ✅ Add Expense (same screen, different type)
              AppRoutes.addExpense: (context) => AuthGuard(
                child: AddTransactionScreen(
                  type: app_models.TransactionType.expense,
                ),
              ),

              AppRoutes.categories: (context) =>
                  const AuthGuard(child: CategoriesScreen()),

              AppRoutes.transactionHistory: (context) =>
                  const AuthGuard(child: TransactionHistoryScreen()),

              AppRoutes.budget: (context) =>
                  const AuthGuard(child: BudgetScreen()),

              AppRoutes.reports: (context) =>
                  const AuthGuard(child: ReportsScreen()),

              AppRoutes.profile: (context) =>
                  const AuthGuard(child: ProfileScreen()),
            },
          );
        },
      ),
    );
  }
}
