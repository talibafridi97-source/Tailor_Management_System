import 'package:intl/intl.dart';

class DateFormatter {
  static String format(dynamic date) {
    if (date == null) return '-';
    
    DateTime? parsedDate;
    
    if (date is DateTime) {
      parsedDate = date;
    } else if (date is String) {
      parsedDate = DateTime.tryParse(date);
    }
    
    if (parsedDate == null) return date.toString();
    
    // Format: 07 Sep 2026
    return DateFormat('dd MMM yyyy').format(parsedDate);
  }

  static String formatFull(dynamic date) {
    if (date == null) return '-';
    
    DateTime? parsedDate;
    
    if (date is DateTime) {
      parsedDate = date;
    } else if (date is String) {
      parsedDate = DateTime.tryParse(date);
    }
    
    if (parsedDate == null) return date.toString();
    
    // Format: Monday, 07 Sep 2026
    return DateFormat('EEEE, dd MMM yyyy').format(parsedDate);
  }
}
