import '../constants/table_header_names.dart';

const List<String> _opAssemblyHeaderDB = [
  'OP 1',
  'OP 2',
  'OP 3/1',
  'OP 3/2',
  'OP 4',
  'OP 5/1',
  'OP 5/2',
  'OP 6',
  'OP 7',
  'OP 8',
  'OP 9',
  'OP 10',
  'OP 11',
];

const List<String> _subAssemblyHeaderDB = [
  'SUB ASSY CRANKSHAFT',
  'SUB ASSY BALANCER',
  'SUB ASSY RADIATOR',
  'SUB ASSY CAMSHAFT',
  'SUB ASSY PISTON',
  'SUB ASSY CYL HEAD',
  'SUB ASSY CAP FO TANK',
  'SUB ASSY GEARCASE',
  'SUB ASSY ROCK ARM',
  'SUB ASSY STAY RADIATOR',
  'SUB ASSY AIR CLEANER',
  'SUB ASSY FO TANK',
  ''
];

final mapOpAssemblyHeaderToDb = Map.fromIterables(opAssemblyHeader, _opAssemblyHeaderDB);
final mapSubAssemblyHeaderToDb = Map.fromIterables(subAssemblyHeader, _subAssemblyHeaderDB);
