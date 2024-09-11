import 'package:excel/excel.dart';

List<Map<String, dynamic>> processExcel(Excel excel) {
  if (!(excel.tables.containsKey('Sheet1'))) throw Exception('Sheet with name Sheet1 not found');

  const List<String> templateHeaderName = ['Parts Code', 'Parts Description', 'LOCATOR', 'PIC', 'RACK', 'OP ASSY', 'BAGIAN', 'BOM QTY'];

  /* ---------------------- Check table header name match --------------------- */
  final headerRow = excel.tables['Sheet1']!.rows.first;

  final List<String> errorHeader = [];

  for (int i = 0; i < headerRow.length; i++) {
    // Header name is null or not match with template
    if (!(headerRow[i]?.value != null && headerRow[i]!.value.toString() == templateHeaderName[i])) {
      errorHeader.add('Wrong header name ${headerRow[i]?.value.toString() ?? ' '} ; Should be ${templateHeaderName[i]}');
    }
  }

  if (errorHeader.isNotEmpty) throw Exception('\n${errorHeader.join('\n')}');

  /* ------------------------------ Process Excel ----------------------------- */
  List<Map<String, dynamic>> partSlot = [];

  for (int i = 1; i < excel.tables['Sheet1']!.rows.length; i++) {
    final partRow = excel.tables['Sheet1']!.rows[i];

    // If op assy row is null or empty, skip
    if (partRow[5]?.value.toString() == 'null') continue;

    partSlot.add({
      'part_code': partRow[0]?.value.toString() ?? '',
      'part_description': partRow[1]?.value.toString() ?? '',
      'locator': partRow[2]?.value.toString() ?? '',
      'pic': partRow[3]?.value.toString() ?? '',
      'rack': partRow[4]?.value.toString() ?? '',
      'op_assy': partRow[5]!.value.toString(),
      'rack_placement': partRow[6]?.value.toString() ?? '',
      'qty': int.tryParse(partRow[7]?.value.toString() ?? '0'),
    });
  }

  return partSlot;
}
