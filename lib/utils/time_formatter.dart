import 'package:intl/intl.dart';

class TimeFormatter {
  static String formatMessageTimestamp(String isoString) {
    try {
      final DateTime timestamp = DateTime.parse(isoString);
      final DateTime now = DateTime.now();

      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

      final int difference = today.difference(messageDate).inDays;

      if (difference == 0) {
        return 'Today, ${_formatTime(timestamp)}';
      } else if (difference == 1) {
        return 'Yesterday, ${_formatTime(timestamp)}';
      } else if (difference < 7) {
        return '${_getDayName(timestamp.weekday)}, ${_formatTime(timestamp)}';
      } else {
        return '${_formatDate(timestamp)} • ${_formatTime(timestamp)}';
      }
    } catch (e) {
      return isoString;
    }
  }

  static String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final amPm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
  }

  static String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }
}