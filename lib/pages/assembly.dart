import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:yanmar_app/bloc/plan_produksi_data_fetcher/plan_produksi_data_fetcher_bloc.dart';
import 'package:intl/intl.dart';
import 'package:yanmar_app/models/plan_produksi_model.dart';
import 'package:yanmar_app/models/production_actual_model.dart';
import 'package:yanmar_app/models/production_type_model.dart';

const TextStyle tableStyle = TextStyle(fontSize: 11, color: Colors.white, overflow: TextOverflow.ellipsis);
const TextStyle lateStyle = TextStyle(color: Colors.red, fontWeight: FontWeight.bold);

class AssemblyPage extends StatefulWidget {
  const AssemblyPage({super.key});

  static const route = '/assembly';

  @override
  State<AssemblyPage> createState() => _AssemblyPageState();
}

class _AssemblyPageState extends State<AssemblyPage> {
  final PlanProduksiDataFetcherBloc _bloc = PlanProduksiDataFetcherBloc();

  @override
  void initState() {
    _bloc.add(const FetchPlanProduksiData());
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: Scaffold(
        appBar: AppBar(
          leading: Center(child: Text(DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()))),
          leadingWidth: 200,
          title: const Text('ASSEMBLY BOARD'),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                      width: 300,
                      child: Center(
                        child: BlocBuilder<PlanProduksiDataFetcherBloc, PlanProduksiDataFetcherState>(builder: (context, state) {
                          if (state is PlanProduksiDataFetcherLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is PlanProduksiDataFetcherDone) {
                            final maxQtyInDetails = findMaxQtyInDetails(state.result);

                            return Table(
                              children: [
                                TableRow(children: [
                                  const Text('LATE COUNT', style: lateStyle),
                                  Text('${generateLateCount(maxLength: maxQtyInDetails, list: state.result)}',
                                      textAlign: TextAlign.center, style: lateStyle),
                                  const Text('UNITS', style: lateStyle)
                                ]),
                                TableRow(children: [
                                  const Text('LATE TIME', style: lateStyle),
                                  Text('${calculateLateTime(maxLength: maxQtyInDetails, list: state.result).inMinutes}',
                                      textAlign: TextAlign.center, style: lateStyle),
                                  const Text('MINUTES', style: lateStyle)
                                ])
                              ],
                            );
                          }
                          return Container();
                        }),
                      )),
                  StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: ((context, snapshot) => Align(
                          alignment: Alignment.center,
                          child: Text(DateFormat('HH:mm:ss').format(DateTime.now())),
                        )),
                  ),
                ],
              ),
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(child: AssemblyTable()),
            ),
            const Spacer(),
            Flexible(child: Container(color: Colors.amber, child: const SummaryBottom())),
          ],
        ),
      ),
    );
  }

  int generateLateCount({
    required int maxLength,
    required List<PlanProduksiModel> list,
  }) {
    List<PlanProduksiDetailModel> widgets = [];
    List<String> lateType = [];

    // Find actuals in time range of last row
    for (var rows in list) {
      for (var details in rows.details) {
        for (var actuals in details.actuals) {
          if (actuals.recordedTime.isAfter(list.last.startTime) && actuals.recordedTime.isBefore(list.last.endTime) ||
              actuals.recordedTime.isAtSameMomentAs(list.last.startTime) ||
              actuals.recordedTime.isAtSameMomentAs(list.last.endTime)) {
            widgets.add(details);
          }
        }
      }
    }

    // List of plan produksi not counted for in actuals
    if (list.isNotEmpty) {
      for (var detail in list.last.details) {
        for (int i = 0; i < (detail.qty - detail.actuals.length); i++) {
          widgets.add(detail);
        }
      }
    }

    if (widgets.length > maxLength) {
      lateType = widgets.map((e) => e.type.typeName).toList().sublist(maxLength, widgets.length);
    }

    return lateType.length;
  }

  Duration calculateLateTime({
    required int maxLength,
    required List<PlanProduksiModel> list,
  }) {
    List<PlanProduksiDetailModel> widgets = [];
    List<Duration> lateType = [];

    // Find actuals in time range of last row
    for (var rows in list) {
      for (var details in rows.details) {
        for (var actuals in details.actuals) {
          if (actuals.recordedTime.isAfter(list.last.startTime) && actuals.recordedTime.isBefore(list.last.endTime) ||
              actuals.recordedTime.isAtSameMomentAs(list.last.startTime) ||
              actuals.recordedTime.isAtSameMomentAs(list.last.endTime)) {
            widgets.add(details);
          }
        }
      }
    }

    // List of plan produksi not counted for in actuals
    if (list.isNotEmpty) {
      for (var detail in list.last.details) {
        for (int i = 0; i < (detail.qty - detail.actuals.length); i++) {
          widgets.add(detail);
        }
      }
    }

    if (widgets.length > maxLength) {
      lateType = widgets.map((e) => e.type.estimatedProductionTime).toList().sublist(maxLength, widgets.length);
    }

    return Duration(seconds: lateType.fold(0, (total, element) => total + element.inSeconds));
  }
}

class SummaryBottom extends StatelessWidget {
  const SummaryBottom({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 20, right: 20),
      child: BlocBuilder<PlanProduksiDataFetcherBloc, PlanProduksiDataFetcherState>(
        builder: (context, state) {
          if (state is PlanProduksiDataFetcherLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PlanProduksiDataFetcherDone) {
            final totalPlanned = state.result.fold(0, (total, element) => total + element.details.fold(0, (total, element) => total + element.qty));
            final totalActual =
                state.result.fold(0, (total, element) => total + element.details.fold(0, (total, element) => total + element.actuals.length));
            final maxQtyInDetails = findMaxQtyInDetails(state.result);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Table(
                    columnWidths: const {
                      0: FixedColumnWidth(100),
                      1: FlexColumnWidth(),
                    },
                    children: [
                      TableRow(
                        children: [
                          const Text('TOTAL:'),
                          Text('$totalPlanned'),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Text('LATE TYPE:'),
                          Text(
                            generateLateType(
                              maxLength: maxQtyInDetails,
                              list: state.result,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Table(
                      columnWidths: const {
                        0: FixedColumnWidth(150),
                        1: FixedColumnWidth(50),
                      },
                      children: [
                        TableRow(children: [
                          const Text('TOTAL ACTUAL:'),
                          Text('$totalActual'),
                        ]),
                        TableRow(children: [
                          const Text('LEFT:'),
                          Text('${totalPlanned - totalActual}'),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }

  String generateLateType({
    required int maxLength,
    required List<PlanProduksiModel> list,
  }) {
    List<PlanProduksiDetailModel> widgets = [];
    List<String> lateType = [];

    // Find actuals in time range of last row
    for (var rows in list) {
      for (var details in rows.details) {
        for (var actuals in details.actuals) {
          if (actuals.recordedTime.isAfter(list.last.startTime) && actuals.recordedTime.isBefore(list.last.endTime) ||
              actuals.recordedTime.isAtSameMomentAs(list.last.startTime) ||
              actuals.recordedTime.isAtSameMomentAs(list.last.endTime)) {
            widgets.add(details);
          }
        }
      }
    }

    // List of plan produksi not counted for in actuals
    if (list.isNotEmpty) {
      for (var detail in list.last.details) {
        for (int i = 0; i < (detail.qty - detail.actuals.length); i++) {
          widgets.add(detail);
        }
      }
    }

    if (widgets.length > maxLength) {
      lateType = widgets.map((e) => e.type.typeName).toList().sublist(maxLength, widgets.length);
    }

    return lateType.isNotEmpty ? lateType.join(' | ') : '';
  }
}

class AssemblyTable extends StatelessWidget {
  AssemblyTable({
    super.key,
  });

  final DateFormat formatter = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BlocBuilder<PlanProduksiDataFetcherBloc, PlanProduksiDataFetcherState>(
        builder: (context, state) {
          if (state is PlanProduksiDataFetcherLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PlanProduksiDataFetcherDone) {
            final int maxQtyInDetails = findMaxQtyInDetails(state.result);
            if (state.result.isEmpty) {
              return const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: Icon(Icons.warning_amber),
                    ),
                    Text(
                      'No data',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return DataTable(
                columnSpacing: 10,
                dataTextStyle: tableStyle,
                border: TableBorder.all(color: Colors.white),
                columns: [
                  const DataColumn(label: Text('Time')),
                  const DataColumn(label: Text('Plan')),
                  const DataColumn(label: Text('Qty')),
                  ...List.generate(maxQtyInDetails, (index) => DataColumn(label: Flexible(child: Center(child: Text((index + 1).toString()))))),
                  const DataColumn(label: Text('Total')),
                  const DataColumn(label: Text('Actual')),
                  const DataColumn(label: Text('Ratio')),
                ],
                rows: state.result
                    .map((e) => DataRow(
                          cells: [
                            DataCell(Text('${formatter.format(e.startTime.toLocal())} - ${formatter.format(e.endTime.toLocal())}')),
                            DataCell(
                              Column(mainAxisSize: MainAxisSize.min, children: e.details.map((e) => Text(e.type.typeName)).toList()),
                            ),
                            DataCell(Column(
                              mainAxisSize: MainAxisSize.min,
                              children: e.details.map((e) => Text(e.qty.toString())).toList(),
                            )),
                            // Generate table data cells
                            ...generateTableDataRow(maxLength: maxQtyInDetails, list: state.result, startTime: e.startTime, endTime: e.endTime)
                                .map((e) => DataCell(e))
                                .toList(),
                          ],
                        ))
                    .toList(),
              );
            }
          } else if (state is PlanProduksiDataFetcherError) {
            return Center(
              child: Text('Failed to fetch data. ${state.message}'),
            );
          }
          return Container();
        },
      ),
    );
  }
}

int findMaxQtyInDetails(List<PlanProduksiModel> list) {
  int maxQty = 0;

  // Iterate through rows of time table
  for (var scannedRow in list) {
    // Map element to qty, then total the qty of details
    final int qty = scannedRow.details.map((e) => e.qty).reduce((value, element) => value + element);

    final int totalActuals = list.fold(0, (total, listB) {
      return total +
          listB.details.fold(0, (innerTotal, listA) {
            return innerTotal +
                listA.actuals
                    .where((element) =>
                        element.recordedTime.isAfter(scannedRow.startTime) && element.recordedTime.isBefore(scannedRow.endTime) ||
                        element.recordedTime.isAtSameMomentAs(scannedRow.startTime) ||
                        element.recordedTime.isAtSameMomentAs(scannedRow.endTime))
                    .toList()
                    .length;
          });
    });

    int movingActuals = 0;

    for (var detail in scannedRow.details) {
      final int movingTotal = list.fold(0, (total, listB) {
        return total +
            listB.details.where((element) => element.id == detail.id).fold(0, (innerTotal, listA) {
              return innerTotal +
                  listA.actuals
                      .where((element) => !(element.recordedTime.isAfter(scannedRow.startTime) && element.recordedTime.isBefore(scannedRow.endTime)))
                      .toList()
                      .length;
            });
      });

      movingActuals += movingTotal;
    }

    final rowMaxQty = max(totalActuals, qty - movingActuals);

    // update max qty value
    if (rowMaxQty > maxQty) {
      maxQty = rowMaxQty;
    }
  }

  return maxQty;
}

List<Widget> generateTableDataRow(
    {required int maxLength, required List<PlanProduksiModel> list, required DateTime startTime, required DateTime endTime}) {
  final List<Widget> widgets = [];

  final List<PlanProduksiDetailModel> movedFromBeforeRow = [];
  final List<PlanProduksiDetailModel> movedToAfterRow = [];

  // Record unique types of actual record in current time range
  final Set<ProductionTypeModel> uniqueActualTypesInRow = {};

  // Generate actuals boxes in row
  // -> Actuals from this row in time range
  // -> Actuals from another row but in this time range
  for (var row in list) {
    for (var detail in row.details) {
      for (var actuals in detail.actuals) {
        if (actuals.recordedTime.isAfter(startTime) && actuals.recordedTime.isBefore(endTime) ||
            actuals.recordedTime.isAtSameMomentAs(startTime) ||
            actuals.recordedTime.isAtSameMomentAs(endTime)) {
          widgets.add(Container(
            constraints: const BoxConstraints.expand(),
            color: Colors.green,
            child: Center(child: Text(detail.type.typeName, style: tableStyle)),
          ));

          uniqueActualTypesInRow.add(detail.type);
        }
      }
    }
  }

  final PlanProduksiModel currentRowPlan = list.firstWhere((e) => e.startTime == startTime);

  for (var row in list) {
    for (var detail in row.details) {
      for (var actuals in detail.actuals) {
        if (actuals.recordedTime.isAfter(row.endTime) &&
            (actuals.recordedTime.isBefore(startTime) || actuals.recordedTime.isAfter(startTime) && actuals.recordedTime.isBefore(endTime))) {
          // if actual is after plan time (move to next row) and before current start time or in current row
          movedFromBeforeRow.add(detail);
        } else if (actuals.recordedTime.isBefore(row.startTime) &&
            (actuals.recordedTime.isBefore(startTime) || actuals.recordedTime.isAfter(startTime) && actuals.recordedTime.isBefore(endTime))) {
          // if actual is before plan time (move to prev row) and after current end time or in current row
          movedToAfterRow.add(detail);
        }
      }
    }
  }

  final int movedDiff = movedFromBeforeRow.length - movedToAfterRow.length;

  print('moved diff: $movedDiff');

  // Generate plan moved from prev row
  if (movedDiff > 0) {
    int loopCount = 0;

    // Get details for plans before current row
    final List<PlanProduksiDetailModel> detailsBeforeRow =
        list.where((e) => e.startTime.isBefore(currentRowPlan.startTime)).expand((f) => f.details).toList();

    // Print type sequentially from row n-1 to row 0 according to qty of the detail in each row.
    // Only break loop when loop count is equal to movedDiff
    outerloop:
    for (int j = detailsBeforeRow.length - 1; j >= 0; j--) {
      // If prev row's actual is already achieved, no need to move planned to next row
      if (detailsBeforeRow[j].qty == detailsBeforeRow[j].actuals.length) break;

      for (int i = 0; i < detailsBeforeRow[j].qty; i++) {
        widgets.add(
          Text(detailsBeforeRow[j].type.typeName, style: tableStyle),
        );

        loopCount += 1;

        if (loopCount == movedDiff.abs()) break outerloop;
      }
    }
  }

  // Generate planned for current row
  // -> Planned for this row in this time range - ACtuals in this row in this time range already generated
  for (var detail in currentRowPlan.details) {
    final List actualsForDetail = list.expand((f) => f.details).where((g) => g.id == detail.id).expand((h) => h.actuals).toList();
    for (int i = 0; i < (detail.qty - actualsForDetail.length); i++) {
      widgets.add(
        Text(detail.type.typeName, style: tableStyle),
      );
    }
  }

  // TODO: fix this
  // Generate planned for next row
  if (movedDiff < 0) {
    int loopCount = 0;

    final List<PlanProduksiDetailModel> detailsAfterRow =
        list.where((e) => e.startTime.isAfter(currentRowPlan.endTime)).expand((f) => f.details).toList();

    // If no next plan, no need to loop
    if (detailsAfterRow.isNotEmpty) {
      // Print type sequentially from row 0 to row n+1 according to qty of detail in each row
      // Only break loop when loop count is equal to movedDiff
      print(detailsAfterRow);

      outerloop:
      for (int i = 0; i < detailsAfterRow.length - 1; i++) {
        for (int j = 0; j < detailsAfterRow[i].qty; i++) {
          widgets.add(
            Text(detailsAfterRow[i].type.typeName, style: tableStyle),
          );

          print('j: $j, i: $i');

          loopCount += 1;

          if (loopCount == movedDiff.abs()) break outerloop;
        }
      }
    }
  }

  // TODO: check if this is true for all condition of movedDiff
  // Remove overflow from movedDiff
  widgets.removeRange(widgets.length - movedDiff.abs(), widgets.length);

  print(widgets.length);

  // Generate empty boxes to fill row
  for (int i = widgets.length; i < maxLength; i++) {
    widgets.add(const SizedBox());
  }

  // Prevent row overflow
  if (widgets.length > maxLength) {
    widgets.removeRange(maxLength, widgets.length);
  }

  /* -------------------------- TOTAL, ACTUAL & RATIO ------------------------- */
  // Calculate estimated time
  int estimatedTime = 0;

  for (var detail in list.firstWhere((e) => e.startTime == startTime).details) {
    estimatedTime += detail.qty * detail.type.estimatedProductionTime.inSeconds;
  }

  widgets.add(Text('${Duration(seconds: estimatedTime).inMinutes} min'));

  // Count actuals based on type in current row
  final List<Widget> actualCountWidgets = [];
  int ratio = 0;

  for (var type in uniqueActualTypesInRow) {
    int count = list
        .expand((e) => e.details)
        .where((f) => f.type.id == type.id) // filter details based on type id
        .expand((g) => g.actuals)
        .where((h) =>
            h.recordedTime.isAfter(startTime) && h.recordedTime.isBefore(endTime) ||
            h.recordedTime.isAtSameMomentAs(startTime) ||
            h.recordedTime.isAtSameMomentAs(endTime))
        .toList()
        .length;

    if (count > 0) {
      actualCountWidgets.add(Text(
        '${type.typeName}: $count',
        style: tableStyle.copyWith(color: Colors.amber),
      ));

      ratio += count;
    }
  }

  widgets.add(Column(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: actualCountWidgets,
  ));

  // Count Ratio
  if (ratio > 0) {
    widgets.add(Center(
        child: Text(
      '$ratio',
      style: tableStyle,
    )));
  } else {
    widgets.add(const SizedBox());
  }

  return widgets;
}
