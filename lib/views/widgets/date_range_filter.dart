import 'package:flutter/material.dart';

Future<DateTimeRange?> showCustomDateRangePicker({
  required BuildContext context,
  DateTimeRange? initialRange,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  DateTime now = DateTime.now();

  return showDateRangePicker(
    context: context,
    firstDate: firstDate ?? DateTime(2000),
    lastDate: lastDate ?? now,
    initialDateRange: initialRange,
  );
}
