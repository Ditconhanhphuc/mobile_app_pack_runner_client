import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerWidget extends StatefulWidget {
  final Function(DateTimeRange) onDateRangeSelected;

  const DatePickerWidget({Key? key, required this.onDateRangeSelected}) : super(key: key);

  @override
  _DatePickerWidgetState createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  late DateTimeRange selectedDateRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 6)),
      end: now,
    );
  }

  Future<void> _pickDateRange() async {
    DateTime now = DateTime.now();
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDateRange: selectedDateRange,
    );

    if (picked != null) {
      debugPrint("Date picked: ${picked.start} - ${picked.end}");
      setState(() {
        selectedDateRange = picked;
      });
      widget.onDateRangeSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickDateRange,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today, size: 20),
          const SizedBox(width: 8),
          Text(
            "${DateFormat('dd/MM/yyyy').format(selectedDateRange.start)} - ${DateFormat('dd/MM/yyyy').format(selectedDateRange.end)}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
