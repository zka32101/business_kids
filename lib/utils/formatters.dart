import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final _yen = NumberFormat.currency(locale: 'ja_JP', symbol: 'ﾂ･', decimalDigits: 0);
  static final _percent = NumberFormat.decimalPercentPattern(locale: 'ja_JP', decimalDigits: 1);

  static String yen(int amount) => _yen.format(amount);
  static String yenDouble(double amount) => _yen.format(amount.round());
  static String percent(double ratio) => _percent.format(ratio);
  static String percentInt(int percent) => '$percent%';
}
