import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yanmar_app/bloc/auth_bloc/auth_bloc.dart' as auth_bloc;
import 'package:yanmar_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:yanmar_app/bloc/delivery_data_fetcher_bloc/delivery_data_fetcher_bloc.dart';
import 'package:yanmar_app/locator.dart';
import 'package:yanmar_app/models/delivery_model.dart';
import 'package:yanmar_app/models/role_model.dart';
import 'package:yanmar_app/pages/delivery/helpers/map_db_to_ui.dart';
import 'package:yanmar_app/repository/supabase_repository.dart';

import 'constants/table_header_names.dart';

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  static const route = '/delivery';
  static const rolesForMonitor = [superAdminRole, monitoringRole];

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  final DeliveryDataFetcherBloc _bloc = DeliveryDataFetcherBloc();
  late DateTime selectedDate;

  final DateFormat selectedDateFormatter = DateFormat('dd/MM/yyyy');
  final _repo = locator.get<SupabaseRepository>();
  late final RealtimeChannel _subsItem;
  late final RealtimeChannel _subsChecklist;

  @override
  void initState() {
    selectedDate = DateTime.now();
    _bloc.add(FetchDeliveryData(currentDate: selectedDate));
    _subsItem = _repo.subscribeToItemRequestChanges((payload) {
      if (selectedDate.day == DateTime.now().day && selectedDate.month == DateTime.now().month && selectedDate.year == DateTime.now().year) {
        _bloc.add(FetchDeliveryData(currentDate: selectedDate));
      }
    });
    _subsChecklist = _repo.subscribeToChecklistChanges((payload) {
      if (selectedDate.day == DateTime.now().day && selectedDate.month == DateTime.now().month && selectedDate.year == DateTime.now().year) {
        _bloc.add(FetchDeliveryData(currentDate: selectedDate));
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    _repo.unsubscribe(_subsItem);
    _repo.unsubscribe(_subsChecklist);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Center(
                child: Text(
              DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.amber),
            )),
          ),
          leadingWidth: 300,
          title: const Text(
            'DELIVERY CONTROL BOARD',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: ((context, snapshot) => Align(
                      alignment: Alignment.center,
                      child: Text(DateFormat('HH:mm:ss').format(DateTime.now()),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.amber)),
                    )),
              ),
            ),
          ],
        ),
        floatingActionButton: () {
          final state = context.read<AuthBloc>().state;

          if (state is AuthenticatedState) {
            return FloatingActionButton(
              child: const Icon(Icons.arrow_back),
              onPressed: () {
                context.go('/');
              },
            );
          }

          return null;
        }(),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BlocBuilder<auth_bloc.AuthBloc, auth_bloc.AuthState>(
                builder: (context, state) {
                  if (state is auth_bloc.AuthenticatedState && DeliveryPage.rolesForMonitor.contains(state.user.role.name)) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final newDate = await showDatePicker(
                                context: context,
                                firstDate: DateTime(selectedDate.year, 1, 1),
                                lastDate: DateTime(selectedDate.year + 5, 1, 1),
                                currentDate: selectedDate,
                              );
                              if (newDate != null) {
                                setState(() {
                                  selectedDate = newDate;
                                  _bloc.add(FetchDeliveryData(currentDate: selectedDate));
                                });
                              }
                            },
                            child: const Text('Select Date'),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Text('Current Selected Date: ${selectedDateFormatter.format(selectedDate)}'),
                        ],
                      ),
                    );
                  }
                  return Container();
                },
              ),
              BlocBuilder<DeliveryDataFetcherBloc, DeliveryDataFetcherState>(builder: (context, state) {
                if (state is DeliveryDataFetcherLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DeliveryDataFetcherDone) {
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
                      constraints: BoxConstraints.loose(Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - 144)),
                      child: InteractiveViewer(
                        constrained: false,
                        scaleEnabled: false,
                        child: ConstrainedBox(
                            constraints:
                                BoxConstraints(minHeight: MediaQuery.of(context).size.height - 144, minWidth: MediaQuery.of(context).size.width),
                            child: DeliveryTable(data: state.result)),
                      ),
                    );
                  }
                } else if (state is DeliveryDataFetcherFailed) {
                  return Center(
                    child: Text('Failed to fetch data. ${state.message}'),
                  );
                }
                return Container();
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class DeliveryTable extends StatelessWidget {
  DeliveryTable({
    super.key,
    required this.data,
  });

  final List<DeliveryPlanModel> data;

  final DateFormat formatter = DateFormat('HH:mm');
  final DateFormat monitorFormatter = DateFormat('HH:mm:ss');

  static const headerHeight = 80.0;
  static const rowHeight = 50.0;
  static const columnWidth = 110.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 4 * columnWidth,
          child: Table(
            border: TableBorder.all(color: Colors.white),
            children: [
              TableRow(
                children: const [
                  Text('Jam Pengiriman'),
                  Text('Plan Produksi'),
                  Text('Qty'),
                ]
                    .map(
                      (e) => Container(
                        alignment: Alignment.center,
                        height: 2.4 * headerHeight,
                        child: e,
                      ),
                    )
                    .toList(),
              ),
              ...List.generate(
                data.length,
                (index) => TableRow(
                  children: [
                    // Text('${formatter.format(data[index].startTime.toLocal())} - ${formatter.format(data[index].endTime.toLocal())}'),
                    () {
                      if (index == 0) {
                        return const Text('06:30 - 07:30');
                      } else {
                        return Text(
                            '${formatter.format(data[index - 1].startTime.toLocal())} - ${formatter.format(data[index - 1].endTime.toLocal())}');
                      }
                    }(),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(data[index].details.length, (e) => Text(data[index].details[e].type.typeName))),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(data[index].details.length, (e) => Text(data[index].details[e].qty.toString()))),
                  ]
                      .map(
                        (e) => Container(
                          alignment: Alignment.center,
                          height: 2 * rowHeight,
                          child: e,
                        ),
                      )
                      .toList(),
                ),
              ).toList(),
            ],
          ),
        ),
        Table(
          columnWidths: () {
            final Map<int, TableColumnWidth> map = {};
            for (int i = 0; i < 13; i++) {
              map.addAll({i: const FixedColumnWidth(columnWidth)});
            }

            return map;
          }(),
          border: TableBorder.all(color: Colors.white),
          children: [
            TableRow(
              children: List.generate(13, (index) => Text('${index + 1}'))
                  .map(
                    (e) => Container(
                      alignment: Alignment.center,
                      height: 0.6 * headerHeight,
                      child: e,
                    ),
                  )
                  .toList(),
            ),
            TableRow(
              children: opAssemblyHeader
                  .map((e) => Text(
                        e,
                        textAlign: TextAlign.center,
                      ))
                  .map(
                    (e) => Container(
                      alignment: Alignment.center,
                      height: 0.6 * headerHeight,
                      child: e,
                    ),
                  )
                  .toList(),
            ),
            TableRow(
              children: subAssemblyHeader
                  .map((e) => Text(
                        e,
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ))
                  .map(
                    (e) => Container(
                      alignment: Alignment.center,
                      height: 1.2 * headerHeight,
                      child: e,
                    ),
                  )
                  .toList(),
            ),
            ...() {
              List<TableRow> rows = [];

              for (int i = 0; i < data.length; i++) {
                rows.add(
                  TableRow(
                    children: List.generate(
                      opAssemblyHeader.length,
                      (index) => Container(
                        color: showColor(data[i], mapOpAssemblyHeaderToDb[opAssemblyHeader[index]]!),
                        alignment: Alignment.center,
                        height: rowHeight,
                        child: showChild(context, data: data[i], opAssemblyName: mapOpAssemblyHeaderToDb[opAssemblyHeader[index]]!),
                      ),
                    ),
                  ),
                );
                rows.add(
                  TableRow(
                    children: List.generate(
                      subAssemblyHeader.length,
                      (index) => Container(
                        color: showColor(data[i], mapSubAssemblyHeaderToDb[subAssemblyHeader[index]]!),
                        alignment: Alignment.center,
                        height: rowHeight,
                        child: showChild(context, data: data[i], opAssemblyName: mapSubAssemblyHeaderToDb[subAssemblyHeader[index]]!),
                      ),
                    ),
                  ),
                );
              }

              return rows;
            }()
          ],
        )
      ],
    );
  }

  Color? showColor(DeliveryPlanModel data, String opAssemblyName) {
    if (data.itemRequests.isNotEmpty) {
      try {
        final itemRequestData = data.itemRequests.firstWhere((element) => element.opAssembly.name.trim() == opAssemblyName.trim());
        // 1 hour to fulfil order
        const fulfilmentTime = 3600;

        if (itemRequestData.startTime != null) {
          if (itemRequestData.endTime != null) {
            final duration = itemRequestData.endTime!.difference(itemRequestData.startTime!).inSeconds;

            if (duration < fulfilmentTime) {
              return Colors.green;
            } else if (duration > fulfilmentTime) {
              if (data.isHelpPressed.contains(true)) {
                return Colors.red;
              } else {
                return Colors.yellow;
              }
            }
          } else {
            return Colors.amber;
          }
        }
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  Widget? showChild(BuildContext context, {required DeliveryPlanModel data, required String opAssemblyName}) {
    final state = context.read<auth_bloc.AuthBloc>().state;

    if (state is auth_bloc.AuthenticatedState && DeliveryPage.rolesForMonitor.contains(state.user.role.name)) {
      if (data.itemRequests.isNotEmpty) {
        final List<Widget> widgets = [];

        try {
          final itemRequestData = data.itemRequests.firstWhere((element) => element.opAssembly.name.trim() == opAssemblyName.trim());
          if (itemRequestData.startTime != null) {
            final duration = itemRequestData.endTime?.difference(itemRequestData.startTime!).inSeconds ?? 0;
            // 1 hour to fulfil order
            const fulfilmentTime = 3600;

            TextStyle? labelStyle;
            TextStyle? textStyle = const TextStyle(color: Colors.amber);

            if (duration > fulfilmentTime || itemRequestData.endTime == null) {
              labelStyle = const TextStyle(color: Colors.black);
              textStyle = const TextStyle(color: Colors.black);
            }

            widgets.add(Text.rich(
              TextSpan(children: [
                TextSpan(text: 'ST: ', style: labelStyle),
                TextSpan(text: monitorFormatter.format(itemRequestData.startTime!.toLocal()), style: textStyle),
              ]),
            ));

            if (itemRequestData.endTime != null) {
              widgets.add(Text.rich(
                TextSpan(children: [
                  TextSpan(text: 'SP: ', style: labelStyle),
                  TextSpan(text: monitorFormatter.format(itemRequestData.endTime!.toLocal()), style: textStyle),
                ]),
              ));
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widgets,
            );
          }
        } catch (e) {
          return null;
        }
      }
    }

    return null;
  }
}
