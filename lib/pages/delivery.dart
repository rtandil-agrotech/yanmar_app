import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:yanmar_app/bloc/delivery_data_fetcher_bloc/delivery_data_fetcher_bloc.dart';
import 'package:yanmar_app/models/delivery_model.dart';

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  static const route = '/delivery';

  static const List<String> opAssemblyHeader = [
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
  static const List<String> subAssemblyHeader = [
    'Crankshaft',
    'Balancer/Support Governor',
    'Radiator/Tens pulley',
    'Camshaft',
    'Piston',
    'Cyl Head',
    'Fuel Cock/Cap Fuel Tank',
    'Gear Case',
    'Rocker Arm',
    'Bonnet/Stay Rad',
    'Air Cleaner',
    'Fi Pipe, Cover Top, Lamp, Fo',
    ''
  ];

  static const List<String> subAssemblyHeaderDB = [
    'SUB ASSY CRANKSHAFT',
    'SUB ASSY BALANCER',
    'SUB ASSY STAY RADIATOR',
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

  static final mapSubAssemblyHeaderToDb = Map.fromIterables(subAssemblyHeader, subAssemblyHeaderDB);

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  final DeliveryDataFetcherBloc _bloc = DeliveryDataFetcherBloc();

  @override
  void initState() {
    _bloc.add(FetchDeliveryData());
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
          leading: Center(
              child: Text(
            DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.amber),
          )),
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
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: BlocBuilder<DeliveryDataFetcherBloc, DeliveryDataFetcherState>(builder: (context, state) {
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
                return InteractiveViewer(
                  constrained: false,
                  scaleEnabled: false,
                  child: DeliveryTable(data: state.result),
                );
              }
            } else if (state is DeliveryDataFetcherFailed) {
              return Center(
                child: Text('Failed to fetch data. ${state.message}'),
              );
            }
            return Container();
          }),
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

  static const headerHeight = 50.0;
  static const rowHeight = 50.0;
  static const columnWidth = 110.0;

  @override
  Widget build(BuildContext context) {
    return Row(
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
                        height: 3 * headerHeight,
                        child: e,
                      ),
                    )
                    .toList(),
              ),
              ...List.generate(
                data.length,
                (index) => TableRow(
                  children: [
                    Text('${formatter.format(data[index].startTime.toLocal())} - ${formatter.format(data[index].endTime.toLocal())}'),
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
              children: DeliveryPage.opAssemblyHeader
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
              children: DeliveryPage.subAssemblyHeader
                  .map((e) => Text(
                        e,
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ))
                  .map(
                    (e) => Container(
                      alignment: Alignment.center,
                      height: 1.8 * headerHeight,
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
                      DeliveryPage.opAssemblyHeader.length,
                      (index) => Container(
                        color: showColor(data[i], DeliveryPage.opAssemblyHeader[index]),
                        alignment: Alignment.center,
                        height: rowHeight,
                      ),
                    ),
                  ),
                );
                rows.add(
                  TableRow(
                    children: List.generate(
                      DeliveryPage.subAssemblyHeader.length,
                      (index) => Container(
                        color: showColor(data[i], DeliveryPage.mapSubAssemblyHeaderToDb[DeliveryPage.subAssemblyHeader[index]]!),
                        alignment: Alignment.center,
                        height: rowHeight,
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
        final itemRequestData = data.itemRequests.firstWhere((element) => element.opAssembly.name == opAssemblyName);
        final opAssemblyId = itemRequestData.opAssembly.id;
        final fulfilmentTime = data.details.fold(
            0,
            (total, listB) =>
                total + (listB.type.fulfillment?.firstWhere((element) => element.opAssemblyId == opAssemblyId).estimatedDuration.inSeconds ?? 0));

        if (itemRequestData.startTime != null && itemRequestData.endTime != null) {
          final duration = itemRequestData.endTime!.difference(itemRequestData.startTime!).inSeconds;

          if (duration < fulfilmentTime) {
            return Colors.green;
          } else if (duration > fulfilmentTime) {
            if (data.isHelpPressed.contains(true)) {
              return Colors.red;
            } else {
              return Colors.amber;
            }
          }
        }
      } catch (e) {
        return null;
      }
    }

    return null;
  }
}
