/// User model for profile and settings
class User {
  final String id;
  final String name;
  final String email;
  final String currency;
  final double monthlyBudget;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.currency,
    required this.monthlyBudget,
  });
}

/// Mock user data
class MockUser {
  static User getCurrentUser() {
    return User(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      currency: 'USD',
      monthlyBudget: 2000.0,
    );
  }
}

