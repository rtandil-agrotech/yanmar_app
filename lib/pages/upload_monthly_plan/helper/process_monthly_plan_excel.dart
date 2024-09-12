import 'package:excel/excel.dart';

List<Map<String, dynamic>> processExcel(Excel excel) {
  if (!excel.tables.containsKey('Plan Monthly')) throw Exception('Sheet Plan Monthly not found');

  List<Map<String, dynamic>> monthlyPlan = [];
  for (int i = 1; i < excel.tables['Plan Monthly']!.rows.length; i++) {
    final dataRow = excel.tables['Plan Monthly']!.rows[i];

    if (dataRow[0]?.value == null) break;

    if (int.tryParse(dataRow[1]!.value.toString()) == null) continue;

    monthlyPlan.add({dataRow[0]!.value.toString(): int.tryParse(dataRow[1]!.value.toString()) ?? 0});
  }

  return monthlyPlan;
}
