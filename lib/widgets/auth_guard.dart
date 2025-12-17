import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import 'package:provider/provider.dart';

/// Auth guard widget to protect routes
class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isAuthenticated) {
          // Redirect to login if not authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Inform FinanceProvider of current user so it can subscribe to transactions
        try {
          final financeProvider = Provider.of<dynamic>(context, listen: false);
          // ignore: avoid_dynamic_calls
          financeProvider?.setUser?.call(authProvider.user?.uid);
        } catch (_) {
          // ignore errors if FinanceProvider not present
        }

        return child;
      },
    );
  }
}
