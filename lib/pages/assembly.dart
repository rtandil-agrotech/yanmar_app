import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yanmar_app/bloc/monthly_plan_produksi_data_fetcher_bloc/monthly_plan_produksi_data_fetcher_bloc.dart';
import 'package:yanmar_app/bloc/plan_produksi_data_fetcher/plan_produksi_data_fetcher_bloc.dart';
import 'package:intl/intl.dart';
import 'package:yanmar_app/models/plan_produksi_model.dart';
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
  final MonthlyPlanProduksiDataFetcherBloc _monthlyBloc = MonthlyPlanProduksiDataFetcherBloc();

  @override
  void initState() {
    _bloc.add(const FetchPlanProduksiData());
    _monthlyBloc.add(FetchMonthlyPlanProduksiData());
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    _monthlyBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => _bloc,
        ),
        BlocProvider(
          create: (context) => _monthlyBloc,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          leading: Center(
              child: Text(
            DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
          )),
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
                          child: Text(
                            DateFormat('HH:mm:ss').format(DateTime.now()),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
                          ),
                        )),
                  ),
                ],
              ),
            )
          ],
        ),
        body: const Column(
          children: [
            Center(child: AssemblyTable()),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: SummaryBottom(),
              ),
            ),
            Flexible(flex: 5, child: GraphWidget())
          ],
        ),
      ),
    );
  }

  int generateLateCount({
    required int maxLength,
    required List<PlanProduksiModel> list,
  }) {
    int generatedCell = 0;

    List<PlanProduksiDetailModel> late = [];

    for (var rows in list) {
      int countActualsInRow = 0;

      final DateTime startTime = rows.startTime;
      final DateTime endTime = rows.endTime;

      // Generate actuals boxes in row
      // -> Actuals from this row in time range
      // -> Actuals from another row but in this time range
      for (var row in list) {
        for (var detail in row.details) {
          for (var actuals in detail.actuals) {
            if (actuals.recordedTime.isAfter(startTime) && actuals.recordedTime.isBefore(endTime) ||
                actuals.recordedTime.isAtSameMomentAs(startTime) ||
                actuals.recordedTime.isAtSameMomentAs(endTime)) {
              generatedCell++;
              countActualsInRow++;
            }
          }
        }
      }

      if (!list
          .firstWhere((e) => e.startTime.isAtSameMomentAs(startTime))
          .details
          .expand((f) => f.actuals)
          .any((g) => g.recordedTime.isAfter(endTime))) {
        final int maxQtyInRow = list.firstWhere((e) => e.startTime.isAtSameMomentAs(startTime)).details.fold(0, (total, f) => total + f.qty);
        int accumulatedQty = 0;
        int planGenerated = 0;

        outerloop:
        for (var row in list) {
          for (var detail in row.details) {
            accumulatedQty += detail.qty;

            if (accumulatedQty > generatedCell) {
              // Generate Plan based on qty of current detail
              for (int i = generatedCell; i < accumulatedQty; i++) {
                planGenerated++;

                generatedCell++;

                if (countActualsInRow + planGenerated == maxQtyInRow) {
                  if (list.indexOf(row) == list.length - 1) {
                    for (int j = countActualsInRow + planGenerated; j < detail.qty; j++) {
                      late.add(detail);
                    }
                  }
                  break outerloop;
                }
              }
            }
          }
        }
      }
    }

    return late.isNotEmpty ? late.length : 0;
  }

  Duration calculateLateTime({
    required int maxLength,
    required List<PlanProduksiModel> list,
  }) {
    int generatedCell = 0;

    List<PlanProduksiDetailModel> late = [];

    for (var rows in list) {
      int countActualsInRow = 0;

      final DateTime startTime = rows.startTime;
      final DateTime endTime = rows.endTime;

      // Generate actuals boxes in row
      // -> Actuals from this row in time range
      // -> Actuals from another row but in this time range
      for (var row in list) {
        for (var detail in row.details) {
          for (var actuals in detail.actuals) {
            if (actuals.recordedTime.isAfter(startTime) && actuals.recordedTime.isBefore(endTime) ||
                actuals.recordedTime.isAtSameMomentAs(startTime) ||
                actuals.recordedTime.isAtSameMomentAs(endTime)) {
              generatedCell++;
              countActualsInRow++;
            }
          }
        }
      }

      if (!list
          .firstWhere((e) => e.startTime.isAtSameMomentAs(startTime))
          .details
          .expand((f) => f.actuals)
          .any((g) => g.recordedTime.isAfter(endTime))) {
        final int maxQtyInRow = list.firstWhere((e) => e.startTime.isAtSameMomentAs(startTime)).details.fold(0, (total, f) => total + f.qty);
        int accumulatedQty = 0;
        int planGenerated = 0;

        outerloop:
        for (var row in list) {
          for (var detail in row.details) {
            accumulatedQty += detail.qty;

            if (accumulatedQty > generatedCell) {
              // Generate Plan based on qty of current detail
              for (int i = generatedCell; i < accumulatedQty; i++) {
                planGenerated++;

                generatedCell++;

                if (countActualsInRow + planGenerated == maxQtyInRow) {
                  if (list.indexOf(row) == list.length - 1) {
                    for (int j = countActualsInRow + planGenerated; j < detail.qty; j++) {
                      late.add(detail);
                    }
                  }
                  break outerloop;
                }
              }
            }
          }
        }
      }
    }

    return late.isNotEmpty
        ? Duration(seconds: late.fold(0, (total, e) => total + e.type.estimatedProductionTime!.inSeconds))
        : const Duration(seconds: 0);
  }
}

class GraphWidget extends StatelessWidget {
  const GraphWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonthlyPlanProduksiDataFetcherBloc, MonthlyPlanProduksiDataFetcherState>(
      builder: (context, state) {
        if (state is MonthlyPlanProduksiDataFetcherDone) {
          return Center(
            child: BarChart(
              BarChartData(
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (index, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(state.result.expand((e) => e.details).map((f) => f.type).toList().elementAt(index.toInt()).typeName),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(
                  state.result.expand((e) => e.details).map((f) => f.type).toSet().length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: state.result.expand((e) => e.details).elementAt(index).qty.toDouble(),
                        color: Colors.grey,
                        rodStackItems: [
                          BarChartRodStackItem(
                            0,
                            state.result.expand((e) => e.details).elementAt(index).actuals.length.toDouble(),
                            Colors.green,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        } else if (state is MonthlyPlanProduksiDataFetcherFailed) {
          return Center(child: Text('Failed to load graph: ${state.message}'));
        }
        return Container();
      },
    );
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
    int generatedCell = 0;

    List<PlanProduksiDetailModel> late = [];

    for (var rows in list) {
      int countActualsInRow = 0;

      final DateTime startTime = rows.startTime;
      final DateTime endTime = rows.endTime;

      // Generate actuals boxes in row
      // -> Actuals from this row in time range
      // -> Actuals from another row but in this time range
      for (var row in list) {
        for (var detail in row.details) {
          for (var actuals in detail.actuals) {
            if (actuals.recordedTime.isAfter(startTime) && actuals.recordedTime.isBefore(endTime) ||
                actuals.recordedTime.isAtSameMomentAs(startTime) ||
                actuals.recordedTime.isAtSameMomentAs(endTime)) {
              generatedCell++;
              countActualsInRow++;
            }
          }
        }
      }

      if (!list
          .firstWhere((e) => e.startTime.isAtSameMomentAs(startTime))
          .details
          .expand((f) => f.actuals)
          .any((g) => g.recordedTime.isAfter(endTime))) {
        final int maxQtyInRow = list.firstWhere((e) => e.startTime.isAtSameMomentAs(startTime)).details.fold(0, (total, f) => total + f.qty);
        int accumulatedQty = 0;
        int planGenerated = 0;

        outerloop:
        for (var row in list) {
          for (var detail in row.details) {
            accumulatedQty += detail.qty;

            if (accumulatedQty > generatedCell) {
              // Generate Plan based on qty of current detail
              for (int i = generatedCell; i < accumulatedQty; i++) {
                planGenerated++;

                generatedCell++;

                if (countActualsInRow + planGenerated == maxQtyInRow) {
                  if (list.indexOf(row) == list.length - 1) {
                    for (int j = countActualsInRow + planGenerated; j < detail.qty; j++) {
                      late.add(detail);
                    }
                  }
                  break outerloop;
                }
              }
            }
          }
        }
      }
    }

    return late.isNotEmpty ? late.map((e) => e.type.typeName).join(' | ') : '';
  }
}

class AssemblyTable extends StatelessWidget {
  const AssemblyTable({
    super.key,
  });

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
                rows: generateTable(list: state.result, maxLength: maxQtyInDetails),
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

List<DataRow> generateTable({required List<PlanProduksiModel> list, required int maxLength}) {
  final DateFormat formatter = DateFormat('HH:mm');

  final List<DataRow> listDataRow = [];

  // Keeps track of how many cells have been generated
  // Added based on how many actuals and plans are generated in a row
  int generatedCell = 0;

  for (var row in list) {
    final DateTime startTime = row.startTime;
    final DateTime endTime = row.endTime;
    // Keeps track of unique types in a row
    final Set<ProductionTypeModel> uniqueActualTypesInRow = {};

    // Time
    final DataCell timeCell = DataCell(Text('${formatter.format(startTime.toLocal())} - ${formatter.format(endTime.toLocal())}'));
    // Plan
    final DataCell planCell = DataCell(Column(mainAxisSize: MainAxisSize.min, children: row.details.map((e) => Text(e.type.typeName)).toList()));
    // Qty
    final DataCell qtyCell = DataCell(Column(mainAxisSize: MainAxisSize.min, children: row.details.map((e) => Text(e.qty.toString())).toList()));

    final List<Widget> widgets = [];

    int countActualsInRow = 0;

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

            generatedCell++;
            countActualsInRow++;

            uniqueActualTypesInRow.add(detail.type);
          }
        }
      }
    }

    if (!list
        .firstWhere((e) => e.startTime.isAtSameMomentAs(startTime))
        .details
        .expand((f) => f.actuals)
        .any((g) => g.recordedTime.isAfter(endTime))) {
      final int maxQtyInRow = list.firstWhere((e) => e.startTime.isAtSameMomentAs(startTime)).details.fold(0, (total, f) => total + f.qty);
      int accumulatedQty = 0;
      int planGenerated = 0;

      outerloop:
      for (var row in list) {
        for (var detail in row.details) {
          accumulatedQty += detail.qty;

          if (accumulatedQty > generatedCell) {
            // Generate Plan based on qty of current detail
            for (int i = generatedCell; i < accumulatedQty; i++) {
              widgets.add(
                Text(detail.type.typeName, style: tableStyle),
              );
              planGenerated++;

              generatedCell++;

              if (countActualsInRow + planGenerated == maxQtyInRow) break outerloop;
            }
          }
        }
      }
    }

    // Generate Empty Boxes
    for (int i = widgets.length; i < maxLength; i++) {
      widgets.add(const SizedBox());
    }

    /* -------------------------- TOTAL, ACTUAL & RATIO ------------------------- */
    // Calculate estimated time
    int estimatedTime = 0;

    for (var detail in list.firstWhere((e) => e.startTime == startTime).details) {
      estimatedTime += detail.qty * detail.type.estimatedProductionTime!.inSeconds;
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

    listDataRow.add(DataRow(cells: [
      timeCell,
      planCell,
      qtyCell,
      ...widgets.map((e) => DataCell(e)).toList(),
    ]));
  }

  return listDataRow;
}
