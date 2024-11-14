import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Locale currentLocale = const Locale('ru', 'RU');

void setCurrentLocale(BuildContext context) {
  currentLocale = Localizations.localeOf(context);
}

String formatCurrency(double amount, String currencyCode, String locale) {
  final formatter = NumberFormat.currency(
    locale: locale,
    symbol: getCurrencySymbol(currencyCode),
    name: currencyCode,
  );
  return formatter.format(amount);
}

String formatAccountType(String type) {
  switch (type.toLowerCase()) {
    case 'card':
      return 'карта';
    case 'deposit':
      return 'депозит';
    case 'credit':
      return 'кредит';
    default:
      return type;
  }
}

String getCurrencySymbol(String currencyCode) {
  switch (currencyCode) {
    case 'USD':
      return '\$';
    case 'EUR':
      return '€';
    case 'KZT':
      return '₸';
    default:
      return currencyCode;
  }
}

String getInitials(String fullName) {
  List<String> names = fullName.trim().split(RegExp(r'\s+'));

  if (names.length < 2) return '';

  String firstNameInitial =
      names[0].isNotEmpty ? names[0][0].toUpperCase() : '';
  String lastNameInitial = names[1].isNotEmpty ? names[1][0].toUpperCase() : '';

  return firstNameInitial + lastNameInitial;
}


String formatCardNumber(String cardNumber) {
  if (cardNumber.length < 8) {
    return cardNumber; // Fallback if the card number is too short
  }
  return '${cardNumber.substring(0, 4)} ${cardNumber.substring(4, 8)} ${cardNumber.substring(8, 12)} ${cardNumber.substring(cardNumber.length - 4)}';
}


String censorCardNumber(String cardNumber) {
  if (cardNumber.length < 8) {
    return cardNumber; // Fallback if the card number is too short
  }
  return '${cardNumber.substring(0, 4)} •••• •••• ${cardNumber.substring(cardNumber.length - 4)}';
}
