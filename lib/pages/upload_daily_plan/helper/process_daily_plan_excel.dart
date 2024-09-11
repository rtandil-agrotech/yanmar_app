import 'package:excel/excel.dart';

Map<String, dynamic> processExcel(Excel excel, DateTime date) {
  if (!(excel.tables.containsKey('Plan') && excel.tables.containsKey('Time Slot'))) throw Exception('Sheet Plan or Time Slot not found');

  // Process all time slot
  List<Map<String, dynamic>> timeSlot = [];
  for (int i = 1; i < excel.tables['Time Slot']!.rows.length; i++) {
    final timeRow = excel.tables['Time Slot']!.rows[i];

    if (timeRow[0]?.value == null) break;

    timeSlot.add(
      {
        'zone': int.tryParse(timeRow[0]!.value.toString()) ?? 0,
        'start_time': date.copyWith(
          hour: int.tryParse(timeRow[1]!.value.toString().split(':')[0]) ?? 0,
          minute: int.tryParse(timeRow[1]!.value.toString().split(':')[1]) ?? 0,
          second: 0,
        ),
        'end_time': date.copyWith(
          hour: int.tryParse(timeRow[2]!.value.toString().split(':')[0]),
          minute: int.tryParse(timeRow[2]!.value.toString().split(':')[1]),
          second: 0,
        ),
      },
    );
  }

  // Process all plan
  List<Map<String, dynamic>> planSlot = [];
  for (int i = 1; i < excel.tables['Plan']!.rows.length; i++) {
    final planRow = excel.tables['Plan']!.rows[i];

    if (planRow[0]?.value == null) break;

    planSlot.add(
      {
        'model': planRow[0]!.value.toString(),
        'qty': int.tryParse(planRow[1]!.value.toString()),
        'zone': List.generate(planRow.length - 2, (index) => int.tryParse(planRow[2 + index]!.value.toString())),
      },
    );
  }

  return {
    'time_slot': timeSlot,
    'plan_slot': planSlot,
  };
}
