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
