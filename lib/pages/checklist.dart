import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:yanmar_app/bloc/rack_data_fetcher_bloc/rack_data_fetcher_bloc.dart';
import 'package:yanmar_app/models/rack_model.dart';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  static const route = '/checklist';

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  final RackDataFetcherBloc _rackBloc = RackDataFetcherBloc();

  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    _rackBloc.add(FetchRackData());
    _pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _rackBloc.close();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Center(
            child: Text(
          DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.amber),
        )),
        leadingWidth: 300,
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
      body: BlocProvider(
        create: (context) => _rackBloc,
        child: BlocBuilder<RackDataFetcherBloc, RackDataFetcherState>(
          builder: (context, state) {
            if (state is RackDataFetcherLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is RackDataFetcherDone) {
              if (state.data.isEmpty) {
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
                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    ScrollConfiguration(
                      behavior: CustomScrollBehavior(),
                      child: PageView.builder(
                        itemCount: state.data.length,
                        controller: _pageController,
                        onPageChanged: (page) => _handlePageViewChanged(page, state.data),
                        itemBuilder: (context, index) => PartsPage(
                          data: state.data[index],
                        ),
                      ),
                    ),
                    PageIndicator(
                      currentPageIndex: _currentIndex,
                      maxLength: state.data.length,
                      onUpdateCurrentPageIndex: _updateCurrentPageIndex,
                      isOnDesktopAndWeb: _isOnDesktopAndWeb,
                    )
                  ],
                );
              }
            } else if (state is RackDataFetcherFailed) {
              return Center(
                child: Text('Failed to fetch data. ${state.message}'),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  bool get _isOnDesktopAndWeb {
    if (kIsWeb) {
      return true;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return true;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return false;
    }
  }

  void _handlePageViewChanged(int currentPageIndex, List<RackModel> data) {
    if (!_isOnDesktopAndWeb) {
      return;
    }

    setState(() {
      _currentIndex = currentPageIndex;
    });
  }

  void _updateCurrentPageIndex(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}

class PartsPage extends StatelessWidget {
  const PartsPage({
    super.key,
    required this.data,
  });

  final RackModel data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    'Rak ${data.rackName}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
                StreamBuilder(
                  stream: Stream.periodic(const Duration(seconds: 1)),
                  builder: ((context, snapshot) => Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'TIME REMAINING: ${_printDuration(data.startTime.add(const Duration(minutes: 60)).difference(DateTime.now()))}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.amber),
                        ),
                      )),
                ),
              ],
            ),
          ),
          const Divider(
            color: Colors.white,
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...() {
                        List<Widget> widgets = [];

                        for (var detail in data.details) {
                          widgets.addAll([
                            Text(
                              detail.masterProductionType.typeName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Text(
                              '${detail.productionQty} Unit',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            const SizedBox(height: 20),
                          ]);
                        }

                        return widgets;
                      }(),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Row(
                    children: List.generate(
                      data.opAssemblyModel.length,
                      (index) => Expanded(
                        child: Container(
                          decoration: BoxDecoration(border: Border.all(color: Colors.white)),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                data.opAssemblyModel[index].name,
                                style: const TextStyle(fontSize: 20, color: Colors.amber),
                              ),
                              Text(
                                data.opAssemblyModel[index].rackPlacement,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(height: 20),
                              Flexible(
                                child: GridView.builder(
                                  itemCount: data.details
                                      .expand((element) => element.masterProductionType.details)
                                      .where((e) => e.parts.opAssemblyId == data.opAssemblyModel[index].id)
                                      .map((e) => e.parts)
                                      .length,
                                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 500, mainAxisExtent: 70),
                                  itemBuilder: (context, i) => Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          alignment: Alignment.topLeft,
                                          width: 200,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data.details
                                                    .expand((element) => element.masterProductionType.details)
                                                    .where((e) => e.parts.opAssemblyId == data.opAssemblyModel[index].id)
                                                    .map((e) => e.parts)
                                                    .toList()[i]
                                                    .partName,
                                                softWrap: true,
                                                style: const TextStyle(color: Colors.amber),
                                              ),
                                              Text(
                                                data.details
                                                    .expand((element) => element.masterProductionType.details)
                                                    .where((e) => e.parts.opAssemblyId == data.opAssemblyModel[index].id)
                                                    .map((e) => e.parts)
                                                    .toList()[i]
                                                    .partCode,
                                                softWrap: true,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              () {
                                                final partId = data.details
                                                    .expand((element) => element.masterProductionType.details)
                                                    .where((e) => e.parts.opAssemblyId == data.opAssemblyModel[index].id)
                                                    .toList()[i]
                                                    .id;
                                                final partQty = data.details
                                                    .expand((element) => element.masterProductionType.details)
                                                    .where((e) => e.parts.opAssemblyId == data.opAssemblyModel[index].id)
                                                    .toList()[i]
                                                    .qty;
                                                final prodQty = data.details
                                                    .firstWhere((element) => element.masterProductionType.details.map((e) => e.id).contains(partId))
                                                    .productionQty;
                                                return '${partQty * prodQty}';
                                              }(),
                                              softWrap: true,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // child: Container(
                  //   decoration: BoxDecoration(border: Border.all(color: Colors.white)),
                  //   padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                  //   child: GridView.builder(
                  //     itemCount: data.details.expand((element) => element.masterProductionType.details).map((e) => e.parts).length,
                  //     gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 500, mainAxisExtent: 70),
                  //     itemBuilder: (context, index) => Row(
                  //       children: [
                  //         SizedBox(
                  //           width: 200,
                  //           child: Text(
                  //             data!.details.expand((element) => element.masterProductionType.details).map((e) => e.parts).toList()[index].partName,
                  //             softWrap: true,
                  //             style: const TextStyle(color: Colors.amber),
                  //           ),
                  //         ),
                  //         const SizedBox(
                  //           width: 10,
                  //         ),
                  //         Flexible(
                  //           child: Text(
                  //             () {
                  //               final partId = data.details.expand((element) => element.masterProductionType.details).toList()[index].id;
                  //               final partQty = data.details.expand((element) => element.masterProductionType.details).toList()[index].qty;
                  //               final prodQty = data.details
                  //                   .firstWhere((element) => element.masterProductionType.details.map((e) => e.id).contains(partId))
                  //                   .productionQty;
                  //               return '${partQty * prodQty}';
                  //             }(),
                  //             softWrap: true,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _printDuration(Duration duration) {
    String negativeSign = duration.isNegative ? '-' : '';
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
    return "$negativeSign${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}

// class PartsPage extends StatelessWidget {
//   const PartsPage({
//     super.key,
//     required this.rackName,
//   });

//   final String rackName;

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<PartsDataFetcherBloc, PartsDataFetcherState>(
//       builder: (context, state) {
//         if (state is PartsDataFetcherLoading) {
//           return const Center(
//             child: SizedBox(width: 50, height: 50, child: CircularProgressIndicator()),
//           );
//         } else if (state is PartsDataFetcherDone) {
//           if (state.data == null) {
//             return const Center(
//               child: Text('No data'),
//             );
//           } else {
//             return Padding(
//               padding: const EdgeInsets.only(left: 20.0, right: 20.0),
//               child: Column(
//                 children: [
//                   StreamBuilder(
//                     stream: Stream.periodic(const Duration(seconds: 1)),
//                     builder: ((context, snapshot) => Align(
//                           alignment: Alignment.centerRight,
//                           child: Text(
//                             'TIME REMAINING: ${_printDuration(state.data!.startTime.add(const Duration(minutes: 60)).difference(DateTime.now()))}',
//                             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.amber),
//                           ),
//                         )),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
//                     child: Text(
//                       rackName,
//                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//                     ),
//                   ),
//                   const Divider(
//                     color: Colors.white,
//                   ),
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               ...() {
//                                 List<Widget> widgets = [];

//                                 for (var detail in state.data!.details) {
//                                   widgets.addAll([
//                                     Text(
//                                       detail.masterProductionType.typeName,
//                                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//                                     ),
//                                     Text(
//                                       '${detail.productionQty} Unit',
//                                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//                                     ),
//                                     const SizedBox(height: 20),
//                                   ]);
//                                 }

//                                 return widgets;
//                               }(),
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           flex: 5,
//                           child: Container(
//                             decoration: BoxDecoration(border: Border.all(color: Colors.white)),
//                             padding: const EdgeInsets.only(left: 30.0, right: 30.0),
//                             child: GridView.builder(
//                               itemCount: state.data!.details.expand((element) => element.masterProductionType.details).map((e) => e.parts).length,
//                               gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 500, mainAxisExtent: 70),
//                               itemBuilder: (context, index) => Row(
//                                 children: [
//                                   SizedBox(
//                                     width: 200,
//                                     child: Text(
//                                       state.data!.details
//                                           .expand((element) => element.masterProductionType.details)
//                                           .map((e) => e.parts)
//                                           .toList()[index]
//                                           .partName,
//                                       softWrap: true,
//                                       style: const TextStyle(color: Colors.amber),
//                                     ),
//                                   ),
//                                   const SizedBox(
//                                     width: 10,
//                                   ),
//                                   Flexible(
//                                     child: Text(
//                                       () {
//                                         final partId =
//                                             state.data!.details.expand((element) => element.masterProductionType.details).toList()[index].id;
//                                         final partQty =
//                                             state.data!.details.expand((element) => element.masterProductionType.details).toList()[index].qty;
//                                         final prodQty = state.data!.details
//                                             .firstWhere((element) => element.masterProductionType.details.map((e) => e.id).contains(partId))
//                                             .productionQty;
//                                         return '${partQty * prodQty}';
//                                       }(),
//                                       softWrap: true,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//         } else if (state is PartsDataFetcherFailed) {
//           return Center(
//             child: Text('Failed to fetch data. ${state.message}'),
//           );
//         }
//         return Container();
//       },
//     );
//   }

//   String _printDuration(Duration duration) {
//     String negativeSign = duration.isNegative ? '-' : '';
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
//     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
//     return "$negativeSign${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
//   }
// }

/// Page indicator for desktop and web platforms.
///
/// On Desktop and Web, drag gesture for horizontal scrolling in a PageView is disabled by default.
/// You can defined a custom scroll behavior to activate drag gestures,
/// see https://docs.flutter.dev/release/breaking-changes/default-scroll-behavior-drag.
///
/// In this sample, we use a TabPageSelector to navigate between pages,
/// in order to build natural behavior similar to other desktop applications.
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.currentPageIndex,
    required this.maxLength,
    required this.onUpdateCurrentPageIndex,
    required this.isOnDesktopAndWeb,
  });

  final int currentPageIndex;
  final int maxLength;
  final void Function(int) onUpdateCurrentPageIndex;
  final bool isOnDesktopAndWeb;

  @override
  Widget build(BuildContext context) {
    if (!isOnDesktopAndWeb) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            splashRadius: 16.0,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (currentPageIndex == 0) {
                return;
              }
              onUpdateCurrentPageIndex(currentPageIndex - 1);
            },
            icon: const Icon(
              Icons.arrow_left_rounded,
              size: 32.0,
            ),
          ),
          Text('${currentPageIndex + 1} / $maxLength'),
          IconButton(
            splashRadius: 16.0,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (currentPageIndex == maxLength - 1) {
                return;
              }
              onUpdateCurrentPageIndex(currentPageIndex + 1);
            },
            icon: const Icon(
              Icons.arrow_right_rounded,
              size: 32.0,
            ),
          ),
        ].map((e) => Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: e)).toList(),
      ),
    );
  }
}
