import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme/theme.dart';
import 'routes/app_routes.dart';
import 'providers/auth_provider.dart';
import 'providers/finance_provider.dart';
import 'widgets/auth_guard.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/budget_setup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_income_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/transaction_history_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Handle Firebase initialization error
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
          // Ensure FinanceProvider knows about current authenticated user at app start
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

              // Protected routes with auth guard
              AppRoutes.budgetSetup: (context) =>
                  const AuthGuard(child: BudgetSetupScreen()),
              AppRoutes.dashboard: (context) =>
                  const AuthGuard(child: DashboardScreen()),
              AppRoutes.addIncome: (context) =>
                  const AuthGuard(child: AddIncomeScreen()),
              AppRoutes.addExpense: (context) =>
                  const AuthGuard(child: AddExpenseScreen()),
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
