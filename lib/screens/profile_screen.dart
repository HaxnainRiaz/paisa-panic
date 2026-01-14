import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../services/firestore_service.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../routes/app_routes.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../widgets/app_scaffold.dart';

/// Profile & Settings screen
class ProfileScreen extends StatefulWidget {
  final bool hideShellElements;
  const ProfileScreen({super.key, this.hideShellElements = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();

  bool _isEditingName = false;
  final List<String> _currencies = ['PKR', 'USD', 'EUR', 'GBP', 'INR', 'JPY', 'CAD'];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final authProvider = Provider.of<AuthProvider>(context);
      final user = authProvider.user;
      _nameController.text = user?.displayName ?? '';
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveName() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid;

      if (userId != null) {
        try {
          // Update in Firestore
          await FirestoreService().updateUserProfile(userId, {'displayName': name});
          // Update in Auth (optional if AuthProvider listens to changes or if we rely on Firestore)
          // For now, assume FirestoreService updates the User object or we reload.
          // Ideally AuthProvider should expose a method to update profile. 
          // Let's assume we just need to update Firestore and perhaps `user!.updateDisplayName(name)`.
           await authProvider.user!.updateDisplayName(name);
           await authProvider.user!.reload();

            if (!mounted) return;
            setState(() {
              _isEditingName = false;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Name updated successfully!'),
                backgroundColor: AppColors.secondary,
              ),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error updating name: $e'),
                backgroundColor: AppColors.warning,
              ),
            );
          }
      }
    }
  }

  void _showResetDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Data'),
        content: const Text(
          'Are you sure you want to reset all your data? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data reset (UI only - no actual data)'),
                  backgroundColor: AppColors.secondary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return AppScaffold(
      title: 'Profile & Settings',
      currentRoute: AppRoutes.profile,
      hideShellElements: widget.hideShellElements,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // User Profile Card
            CustomCard(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_isEditingName) ...[
                    CustomTextField(
                      label: 'Name',
                      controller: _nameController,
                      prefixIcon: Icons.person_outlined,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Cancel',
                            onPressed: () {
                              setState(() {
                                _isEditingName = false;
                                _nameController.text = user?.displayName ?? '';
                              });
                            },
                            isOutlined: true,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: CustomButton(
                            text: 'Save',
                            onPressed: _handleSaveName,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      user?.displayName ?? 'Your Name',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'you@example.com',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _isEditingName = true;
                        });
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Change Name'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Currency Selector
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Currency',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: Provider.of<FinanceProvider>(context).selectedCurrency,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.textSecondary.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.textSecondary.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.secondary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    items: _currencies.map((currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        final finance = Provider.of<FinanceProvider>(context, listen: false);
                        finance.setCurrency(user!.uid, value);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Currency changed to $value'),
                            backgroundColor: AppColors.secondary,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Reset Data Button
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Data Management',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  CustomButton(
                    text: 'Reset Data',
                    onPressed: _showResetDataDialog,
                    backgroundColor: AppColors.warning,
                    icon: Icons.refresh,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Logout Button
            CustomButton(
              text: 'Logout',
              onPressed: _handleLogout,
              backgroundColor: AppColors.primary,
              icon: Icons.logout,
            ),
          ],
        ),
      ),
    );
  }
}
