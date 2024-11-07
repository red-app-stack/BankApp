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

String censorCardNumber(String cardNumber) {
  if (cardNumber.length < 8) {
    return cardNumber; // Fallback if the card number is too short
  }
  return '${cardNumber.substring(0, 4)} •••• •••• ${cardNumber.substring(cardNumber.length - 4)}';
}
