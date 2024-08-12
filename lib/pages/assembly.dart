import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yanmar_app/bloc/plan_produksi_data_fetcher/plan_produksi_data_fetcher_bloc.dart';
import 'package:intl/intl.dart';
import 'package:yanmar_app/models/plan_produksi_model.dart';
import 'package:yanmar_app/models/production_actual_model.dart';
import 'package:yanmar_app/models/production_type_model.dart';

class AssemblyPage extends StatefulWidget {
  const AssemblyPage({super.key});

  static const route = '/assembly';

  @override
  State<AssemblyPage> createState() => _AssemblyPageState();
}

class _AssemblyPageState extends State<AssemblyPage> {
  final PlanProduksiDataFetcherBloc _bloc = PlanProduksiDataFetcherBloc();

  static const TextStyle lateStyle = TextStyle(color: Colors.red, fontWeight: FontWeight.bold);

  @override
  void initState() {
    _bloc.add(FetchPlanProduksiData());
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
              child: AssemblyTable(),
            ),
            const Flexible(
              child: SummaryBottom(),
            ),
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

  static const TextStyle tableStyle = TextStyle(fontSize: 11, color: Colors.white, overflow: TextOverflow.ellipsis);
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
              return InteractiveViewer(
                constrained: false,
                scaleEnabled: false,
                child: DataTable(
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
                              DataCell(Text('${calculateEstimatedDuration(e.details)} min')),
                              DataCell(generateActualsCell(list: state.result, startTime: e.startTime, endTime: e.endTime)),
                              DataCell(generateRatioCell(list: state.result, startTime: e.startTime, endTime: e.endTime)),
                            ],
                          ))
                      .toList(),
                ),
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

  int calculateEstimatedDuration(List<PlanProduksiDetailModel> list) {
    int time = 0;

    for (var e in list) {
      time += e.qty * e.type.estimatedProductionTime.inSeconds;
    }

    return Duration(seconds: time).inMinutes;
  }

  List<Widget> generateTableDataRow({
    required int maxLength,
    required List<PlanProduksiModel> list,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    List<Widget> widgets = [];

    // List of Plan Produksi Model that:
    // - Has details with actuals where the recorded time is between startTime and endTime of row
    List<PlanProduksiModel> newList = [];

    for (var planRow in list) {
      List<PlanProduksiDetailModel> newDetails = [];

      for (var detail in planRow.details) {
        List<ProductionActualModel> newActuals = detail.actuals
            .where((element) =>
                element.recordedTime.isAfter(startTime) && element.recordedTime.isBefore(endTime) ||
                element.recordedTime.isAtSameMomentAs(startTime) ||
                element.recordedTime.isAtSameMomentAs(endTime))
            .toList();

        if (newActuals.isNotEmpty) {
          newDetails.add(PlanProduksiDetailModel(
            id: detail.id,
            type: detail.type,
            qty: detail.qty,
            actuals: newActuals,
            order: detail.order,
          ));
        }
      }

      if (newDetails.isNotEmpty) {
        newList.add(PlanProduksiModel(
          id: planRow.id,
          startTime: planRow.startTime,
          endTime: planRow.endTime,
          createdBy: planRow.createdBy,
          details: newDetails,
        ));
      }
    }

    // Populate actuals in current row
    for (var row in newList) {
      for (var detail in row.details) {
        for (int i = 0; i < detail.actuals.length; i++) {
          widgets.add(
            Container(
              constraints: const BoxConstraints.expand(),
              color: Colors.green,
              child: Center(child: Text(detail.type.typeName, style: tableStyle)),
            ),
          );
        }
      }
    }

    // Populate planned in current row
    PlanProduksiModel currentRow = list.firstWhere((element) => element.startTime.isAtSameMomentAs(startTime));

    for (var detail in currentRow.details) {
      for (int i = detail.actuals.length; i < detail.qty; i++) {
        widgets.add(
          Text(detail.type.typeName, style: tableStyle),
        );
      }
    }

    // Populate Empty Cell in current row (if widget qty < max qty length)
    for (int i = widgets.length; i < maxLength; i++) {
      widgets.add(const SizedBox());
    }

    if (widgets.length > maxLength) {
      widgets.removeRange(maxLength, widgets.length);
    }

    return widgets;
  }

  Widget generateActualsCell({
    required List<PlanProduksiModel> list,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    List<Widget> widgets = [];

    // List of Plan Produksi Model that:
    // - Has details with actuals where the recorded time is between startTime and endTime of row
    List<PlanProduksiModel> newList = [];

    for (var planRow in list) {
      List<PlanProduksiDetailModel> newDetails = [];

      for (var detail in planRow.details) {
        List<ProductionActualModel> newActuals = detail.actuals
            .where((element) =>
                element.recordedTime.isAfter(startTime) && element.recordedTime.isBefore(endTime) ||
                element.recordedTime.isAtSameMomentAs(startTime) ||
                element.recordedTime.isAtSameMomentAs(endTime))
            .toList();

        if (newActuals.isNotEmpty) {
          newDetails.add(PlanProduksiDetailModel(
            id: detail.id,
            type: detail.type,
            qty: detail.qty,
            actuals: newActuals,
            order: detail.order,
          ));
        }
      }

      if (newDetails.isNotEmpty) {
        newList.add(PlanProduksiModel(
          id: planRow.id,
          startTime: planRow.startTime,
          endTime: planRow.endTime,
          createdBy: planRow.createdBy,
          details: newDetails,
        ));
      }
    }

    // Find Set of details type from newList
    Set<ProductionTypeModel> detailsType = {};
    for (var row in newList) {
      for (var detail in row.details) {
        detailsType.add(detail.type);
      }
    }

    for (var type in detailsType) {
      int count = newList.fold(0, (total, listB) {
        return total +
            listB.details.where((element) => element.type.id == type.id).fold(0, (innerTotal, listA) {
              return innerTotal + listA.actuals.length;
            });
      });

      if (count > 0) {
        widgets.add(Text(
          '${type.typeName}: $count',
          style: tableStyle.copyWith(color: Colors.amber),
        ));
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  Widget generateRatioCell({required List<PlanProduksiModel> list, required DateTime startTime, required DateTime endTime}) {
    // List of Plan Produksi Model that:
    // - Has details with actuals where the recorded time is between startTime and endTime of row
    List<PlanProduksiModel> newList = [];

    for (var planRow in list) {
      List<PlanProduksiDetailModel> newDetails = [];

      for (var detail in planRow.details) {
        List<ProductionActualModel> newActuals = detail.actuals
            .where((element) =>
                element.recordedTime.isAfter(startTime) && element.recordedTime.isBefore(endTime) ||
                element.recordedTime.isAtSameMomentAs(startTime) ||
                element.recordedTime.isAtSameMomentAs(endTime))
            .toList();

        if (newActuals.isNotEmpty) {
          newDetails.add(PlanProduksiDetailModel(
            id: detail.id,
            type: detail.type,
            qty: detail.qty,
            actuals: newActuals,
            order: detail.order,
          ));
        }
      }

      if (newDetails.isNotEmpty) {
        newList.add(PlanProduksiModel(
          id: planRow.id,
          startTime: planRow.startTime,
          endTime: planRow.endTime,
          createdBy: planRow.createdBy,
          details: newDetails,
        ));
      }
    }

    int count = newList.fold(0, (total, listB) {
      return total +
          listB.details.fold(0, (innerTotal, listA) {
            return innerTotal + listA.actuals.length;
          });
    });

    if (count > 0) {
      return Center(
          child: Text(
        '$count',
        style: tableStyle,
      ));
    } else {
      return const SizedBox();
    }
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
