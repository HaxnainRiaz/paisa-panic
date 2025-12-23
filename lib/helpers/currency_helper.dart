class CurrencyHelper {
  static String getSymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'PKR':
        return 'Rs';
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CAD':
        return 'C\$';
      default:
        return '\$';
    }
  }
}
