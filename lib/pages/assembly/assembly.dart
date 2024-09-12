import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yanmar_app/bloc/monthly_plan_produksi_data_fetcher_bloc/monthly_plan_produksi_data_fetcher_bloc.dart';
import 'package:yanmar_app/bloc/plan_produksi_data_fetcher/plan_produksi_data_fetcher_bloc.dart';
import 'package:intl/intl.dart';
import 'package:yanmar_app/locator.dart';
import 'package:yanmar_app/models/plan_produksi_model.dart';
import 'package:yanmar_app/models/production_type_model.dart';
import 'package:yanmar_app/repository/supabase_repository.dart';

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
  late DateTime selectedDate;

  final _repo = locator.get<SupabaseRepository>();
  late final RealtimeChannel _subs;

  @override
  void initState() {
    selectedDate = DateTime.now();
    _bloc.add(FetchPlanProduksiData(currentDate: selectedDate));
    _monthlyBloc.add(FetchMonthlyPlanProduksiData(currentTime: selectedDate));

    _subs = _repo.subscribeToProductionActualChanges((payload) {
      _bloc.add(FetchPlanProduksiData(currentDate: selectedDate));
    });

    super.initState();
  }

  @override
  Future<void> dispose() async {
    _bloc.close();
    _monthlyBloc.close();
    await _repo.unsubscribe(_subs);
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
          leadingWidth: 300,
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
        body: Column(
          children: [
            const Center(child: AssemblyTable()),
            ConstrainedBox(
              constraints: BoxConstraints.loose(const Size.fromHeight(100)),
              child: const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: SummaryBottom(),
              ),
            ),
            const Flexible(
                child: Padding(
              padding: EdgeInsets.only(top: 20, bottom: 20.0),
              child: GraphWidgetAlter(),
            ))
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

    int totalActuals = list.fold(0, (total, row) => total + row.details.fold(0, (total, detail) => total + detail.actuals.length));

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

      if (generatedCell >= totalActuals) {
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

                if (countActualsInRow + planGenerated == maxQtyInRow) break outerloop;
              }
            }
          }
        }
      }
    }

    int accumulatedQty2 = 0;

    for (var row in list) {
      for (var detail in row.details) {
        accumulatedQty2 += detail.qty;

        if (accumulatedQty2 > generatedCell) {
          for (int i = 0; i < accumulatedQty2 - generatedCell; i++) {
            late.add(detail);
          }

          generatedCell += accumulatedQty2 - generatedCell;
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

    int totalActuals = list.fold(0, (total, row) => total + row.details.fold(0, (total, detail) => total + detail.actuals.length));

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

      if (generatedCell >= totalActuals) {
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

                if (countActualsInRow + planGenerated == maxQtyInRow) break outerloop;
              }
            }
          }
        }
      }
    }

    int accumulatedQty2 = 0;

    for (var row in list) {
      for (var detail in row.details) {
        accumulatedQty2 += detail.qty;

        if (accumulatedQty2 > generatedCell) {
          for (int i = 0; i < accumulatedQty2 - generatedCell; i++) {
            late.add(detail);
          }

          generatedCell += accumulatedQty2 - generatedCell;
        }
      }
    }

    return late.isNotEmpty
        ? Duration(seconds: late.fold(0, (total, e) => total + e.type.estimatedProductionTime!.inSeconds))
        : const Duration(seconds: 0);
  }
}

class GraphWidgetAlter extends StatelessWidget {
  const GraphWidgetAlter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonthlyPlanProduksiDataFetcherBloc, MonthlyPlanProduksiDataFetcherState>(
      builder: (context, state) {
        if (state is MonthlyPlanProduksiDataFetcherLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is MonthlyPlanProduksiDataFetcherDone) {
          final data = state.result.expand((e) => e.details).toList();

          return Wrap(
            runSpacing: 30,
            spacing: 30,
            children: List.generate(
              data.length,
              (index) => SizedBox(
                width: 200,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(data.elementAt(index).type.typeName),
                        Text(
                            '${data.map((e) => e.actuals.length).toList().elementAt(index).toStringAsFixed(0)} / ${data.map((e) => e.qty).toList().elementAt(index).toStringAsFixed(0)}'),
                      ],
                    ),
                    LinearPercentIndicator(
                      lineHeight: 20,
                      barRadius: const Radius.circular(10),
                      // trailing: Text('${data.map((e) => e.actuals.length / e.qty * 100).toList().elementAt(index).toStringAsFixed(0)} %'),
                      percent: data.map((e) => min((e.actuals.length / e.qty), 1).toDouble()).toList().elementAt(index),
                      backgroundColor: Colors.grey,
                      progressColor: Colors.green,
                    ),
                  ],
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

class GraphWidget extends StatelessWidget {
  const GraphWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonthlyPlanProduksiDataFetcherBloc, MonthlyPlanProduksiDataFetcherState>(
      builder: (context, state) {
        if (state is MonthlyPlanProduksiDataFetcherLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is MonthlyPlanProduksiDataFetcherDone) {
          final data = state.result.expand((e) => e.details).toList().where((f) => f.actuals.length / f.qty * 100 >= 1);

          return Center(
            child: BarChart(
              BarChartData(
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 50,
                      showTitles: true,
                      getTitlesWidget: (index, meta) {
                        final percent = data.map((f) => f.actuals.length / f.qty * 100).toList().elementAt(index.toInt());

                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            '${percent.toStringAsFixed(0)} %',
                            style: TextStyle(color: percent >= 100 ? Colors.green : Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 80,
                      getTitlesWidget: (index, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          angle: 1,
                          child: Text(data.map((f) => f.type).toList().elementAt(index.toInt()).typeName),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(
                  data.map((f) => f.type).toSet().length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data.elementAt(index).qty.toDouble(),
                        color: Colors.grey,
                        width: 20,
                        borderRadius: const BorderRadius.all(Radius.zero),
                        rodStackItems: [
                          BarChartRodStackItem(
                            0,
                            data.elementAt(index).actuals.length.toDouble(),
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
                SizedBox(
                  width: 220,
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

    int totalActuals = list.fold(0, (total, row) => total + row.details.fold(0, (total, detail) => total + detail.actuals.length));

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

      if (generatedCell >= totalActuals) {
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

                if (countActualsInRow + planGenerated == maxQtyInRow) break outerloop;
              }
            }
          }
        }
      }
    }

    int accumulatedQty2 = 0;

    for (var row in list) {
      for (var detail in row.details) {
        accumulatedQty2 += detail.qty;

        if (accumulatedQty2 > generatedCell) {
          for (int i = 0; i < accumulatedQty2 - generatedCell; i++) {
            late.add(detail);
          }

          generatedCell += accumulatedQty2 - generatedCell;
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
              return ConstrainedBox(
                constraints: BoxConstraints.loose(Size(MediaQuery.of(context).size.width, 500)),
                child: InteractiveViewer(
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
                    rows: generateTable(list: state.result, maxLength: maxQtyInDetails),
                  ),
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

    final rowMaxQty = max(totalActuals, qty);

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

  int totalActuals = list.fold(0, (total, row) => total + row.details.fold(0, (total, detail) => total + detail.actuals.length));

  for (var row in list) {
    final DateTime startTime = row.startTime;
    final DateTime endTime = row.endTime;
    // Keeps track of unique types in a row
    final Set<ProductionTypeModel> uniqueActualTypesInRow = {};

    // Time
    final DataCell timeCell = DataCell(Center(child: Text('${formatter.format(startTime.toLocal())} - ${formatter.format(endTime.toLocal())}')));
    // Plan
    final DataCell planCell = DataCell(Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: row.details.map((e) => Text(e.type.typeName)).toList()));
    // Qty
    final DataCell qtyCell =
        DataCell(Center(child: Column(mainAxisSize: MainAxisSize.min, children: row.details.map((e) => Text(e.qty.toString())).toList())));

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
              // margin: const EdgeInsets.all(5.0),
              constraints: const BoxConstraints.expand(),
              color: Colors.green,
              child: Center(
                  child: Text(
                detail.type.typeName,
                style: tableStyle,
                softWrap: true,
                maxLines: 3,
              )),
            ));

            generatedCell++;
            countActualsInRow++;

            uniqueActualTypesInRow.add(detail.type);
          }
        }
      }
    }

    if (generatedCell >= totalActuals) {
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
              if (countActualsInRow + planGenerated >= maxQtyInRow) break outerloop;

              widgets.add(
                Container(
                  margin: const EdgeInsets.all(5.0),
                  constraints: BoxConstraints.tight(const Size.fromWidth(60)),
                  child: Center(
                      child: Text(
                    detail.type.typeName,
                    style: tableStyle,
                    softWrap: true,
                    maxLines: 3,
                  )),
                ),
              );
              planGenerated++;

              generatedCell++;
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
