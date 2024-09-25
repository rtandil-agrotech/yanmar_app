import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:yanmar_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:yanmar_app/bloc/rack_data_fetcher_bloc/rack_data_fetcher_bloc.dart';
import 'package:yanmar_app/locator.dart';
import 'package:yanmar_app/models/rack_model.dart';
import 'package:yanmar_app/models/role_model.dart';
import 'package:yanmar_app/pages/checklist/widgets/checkbox_widget.dart';
import 'package:yanmar_app/repository/supabase_repository.dart';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({
    super.key,
    required this.initialPage,
  });

  final int initialPage;

  static const allowedUserRoles = [superAdminRole, picRole, bomRole];
  static const route = '/checklist';

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  final RackDataFetcherBloc _rackBloc = RackDataFetcherBloc();

  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    _rackBloc.add(FetchRackData());
    _currentIndex = widget.initialPage - 1;
    _pageController = PageController(initialPage: _currentIndex);
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
    return BlocProvider(
      create: (context) => _rackBloc,
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Center(
                child: Text(
              DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.amber),
            )),
          ),
          leadingWidth: 300,
          title: BlocBuilder<RackDataFetcherBloc, RackDataFetcherState>(
            builder: (context, state) {
              if (state is RackDataFetcherDone) {
                return Text(
                  'Rak ${state.data[_currentIndex].rackName}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                );
              }
              return Container();
            },
          ),
          centerTitle: true,
          actions: [
            BlocBuilder<RackDataFetcherBloc, RackDataFetcherState>(
              builder: (context, state) {
                if (state is RackDataFetcherDone) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: ((context, snapshot) {
                        var now = DateTime.now();

                        return Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'TIME REMAINING: ${state.data[_currentIndex].startTime != null ? _printDuration(state.data[_currentIndex].startTime!.difference(now)) : 'N/A'}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.amber),
                          ),
                        );
                      }),
                    ),
                  );
                }
                return Container();
              },
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
        body: BlocBuilder<RackDataFetcherBloc, RackDataFetcherState>(
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
                _pageController = PageController(initialPage: _currentIndex);
                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    ScrollConfiguration(
                      behavior: CustomScrollBehavior(),
                      child: PageView.builder(
                        itemCount: state.data.length,
                        controller: _pageController,
                        onPageChanged: _handlePageViewChanged,
                        itemBuilder: (context, index) {
                          final Stream stream = Stream.periodic(const Duration(seconds: 1),
                              (r) => state.data[index].startTime != null && DateTime.now().isAfter(state.data[index].startTime!));
                          StreamSubscription? subscription;
                          subscription = stream.listen((event) {
                            if (event) {
                              subscription!.cancel();
                              // ignore: use_build_context_synchronously
                              BlocProvider.of<RackDataFetcherBloc>(context).add(FetchRackData());
                            }
                          });

                          final ValueKey key = ValueKey('page-$index');

                          return PartsPage(
                            key: key,
                            data: state.data[index],
                            allData: state.data,
                          );
                        },
                      ),
                    ),
                    Visibility(
                      visible: context.read<AuthBloc>().state is AuthenticatedState &&
                          ChecklistPage.allowedUserRoles.contains((context.read<AuthBloc>().state as AuthenticatedState).user.role.name),
                      child: PageIndicator(
                        currentPageIndex: _currentIndex,
                        maxLength: state.data.length,
                        onUpdateCurrentPageIndex: _updateCurrentPageIndex,
                        isOnDesktopAndWeb: _isOnDesktopAndWeb,
                      ),
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

  void _handlePageViewChanged(int currentPageIndex) {
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

  String _printDuration(Duration duration) {
    String negativeSign = duration.isNegative ? '-' : '';
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
    return "$negativeSign${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
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

class PartsPage extends StatefulWidget {
  const PartsPage({
    super.key,
    required this.data,
    required this.allData,
  });

  final RackModel data;
  final List<RackModel> allData;

  @override
  State<PartsPage> createState() => _PartsPageState();
}

class _PartsPageState extends State<PartsPage> with TickerProviderStateMixin {
  late ScrollController _scrollControllerTop;
  late ScrollController _scrollControllerBottom;
  late AnimationController _animationControllerTop;
  late AnimationController _animationControllerBottom;
  bool _scrollingForwardTop = true;
  bool _scrollingForwardBottom = true;

  @override
  void initState() {
    super.initState();

    _scrollControllerTop = ScrollController();
    _scrollControllerBottom = ScrollController();
    _animationControllerTop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    );
    _animationControllerBottom = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthBloc>().state is UnauthenticatedState) {
        if (_scrollControllerTop.position.maxScrollExtent > 0) {
          _animationControllerTop.addListener(_scrollListenerTop);
        }

        if (_scrollControllerBottom.position.maxScrollExtent > 0) {
          _animationControllerBottom.addListener(_scrollListenerBottom);
        }

        _startScrolling();
      }
    });
  }

  @override
  void dispose() {
    _animationControllerBottom.removeListener(_scrollListenerBottom);
    _animationControllerTop.removeListener(_scrollListenerTop);
    _scrollControllerBottom.dispose();
    _scrollControllerTop.dispose();
    _animationControllerBottom.dispose();
    _animationControllerTop.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Column(
        children: [
          const Divider(color: Colors.white),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...() {
                        List<Widget> widgets = [];

                        if (widget.data.startTime == null) {
                          return [
                            const Icon(
                              Icons.warning,
                              size: 40,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Text(
                              'No Schedule Found for this time period',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ];
                        }

                        for (var detail in widget.data.details) {
                          widgets.addAll([
                            Text(
                              detail.masterProductionType.typeName,
                              style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Text(
                              '${detail.productionQty} Unit',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            const SizedBox(height: 20),
                          ]);
                        }

                        widgets.addAll(
                          [
                            const Text('Status'),
                            () {
                              final progress = widget.allData
                                      .expand((element) => element.checklistHeader)
                                      .expand((e) => e.details)
                                      .map((f) => f.partId)
                                      .toSet()
                                      .length /
                                  widget.allData
                                      .expand((element) => element.details)
                                      .expand((e) => e.masterProductionType.details)
                                      .map((f) => f.parts)
                                      .length;

                              final remainingTime = widget.data.startTime?.difference(DateTime.now());

                              if ((remainingTime!.compareTo(const Duration(minutes: 45)) < 0 && progress <= 0.25) ||
                                  (remainingTime.compareTo(const Duration(minutes: 30)) < 0 && progress <= 0.5) ||
                                  (remainingTime.compareTo(const Duration(minutes: 15)) < 0 && progress <= 0.75)) {
                                return Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.all(5.0),
                                    padding: const EdgeInsets.all(5.0),
                                    color: Colors.amber,
                                  ),
                                );
                              }
                              return Container();
                            }(),
                          ],
                        );

                        return widgets;
                      }(),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: List.generate(
                      widget.data.opAssemblyModel.length,
                      (index) => Expanded(
                        child: Container(
                          decoration: BoxDecoration(border: Border.all(color: Colors.white)),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                widget.data.opAssemblyModel[index].name,
                                style: const TextStyle(fontSize: 20, color: Colors.amber),
                              ),
                              Text(
                                widget.data.opAssemblyModel[index].rackPlacement,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(height: 20),
                              Flexible(
                                child: ListView.separated(
                                  controller: index == 0 ? _scrollControllerTop : _scrollControllerBottom,
                                  separatorBuilder: (context, index) => const Divider(),
                                  itemCount: widget.data.details
                                      .expand((element) => element.masterProductionType.details)
                                      .where((e) => e.parts.opAssemblyId == widget.data.opAssemblyModel[index].id)
                                      .map((e) => e.parts)
                                      .length,
                                  itemBuilder: (_, i) => Padding(
                                    padding: const EdgeInsets.only(left: 8.0, right: 10),
                                    child: Row(
                                      children: [
                                        () {
                                          final AuthState authState = context.read<AuthBloc>().state;

                                          if (authState is AuthenticatedState && ChecklistPage.allowedUserRoles.contains(authState.user.role.name)) {
                                            final ValueKey checkboxKey = ValueKey('checkbox-$i');

                                            final currentPartId = widget.data.details
                                                .expand((element) => element.masterProductionType.details)
                                                .where((e) => e.parts.opAssemblyId == widget.data.opAssemblyModel[index].id)
                                                .map((e) => e.parts)
                                                .toList()[i]
                                                .id;

                                            final status = widget.data.checklistHeader
                                                .expand((e) => e.details)
                                                .toList()
                                                .where((f) => f.partId == currentPartId)
                                                .toList()
                                                .isNotEmpty;

                                            return CheckboxWidget(
                                              key: checkboxKey,
                                              status: status,
                                              onChangeCallback: () async {
                                                final repo = locator.get<SupabaseRepository>();

                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Loading...')));

                                                await repo.insertChecklist(widget.data.headerId!, currentPartId, authState.user.id);

                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                }

                                                if (context.mounted) {
                                                  context.read<RackDataFetcherBloc>().add(FetchRackData());
                                                }
                                              },
                                            );
                                          }
                                          return Container();
                                        }(),
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.data.details
                                                    .expand((element) => element.masterProductionType.details)
                                                    .where((e) => e.parts.opAssemblyId == widget.data.opAssemblyModel[index].id)
                                                    .map((e) => e.parts)
                                                    .toList()[i]
                                                    .partName,
                                                softWrap: true,
                                                style: const TextStyle(color: Colors.amber, fontSize: 16),
                                              ),
                                              Text(
                                                widget.data.details
                                                    .expand((element) => element.masterProductionType.details)
                                                    .where((e) => e.parts.opAssemblyId == widget.data.opAssemblyModel[index].id)
                                                    .map((e) => e.parts)
                                                    .toList()[i]
                                                    .partCode,
                                                softWrap: true,
                                                style: const TextStyle(fontSize: 16),
                                              ),
                                              Text(
                                                widget.data.details
                                                    .expand((element) => element.masterProductionType.details)
                                                    .where((e) => e.parts.opAssemblyId == widget.data.opAssemblyModel[index].id)
                                                    .map((e) => e.parts)
                                                    .toList()[i]
                                                    .locator,
                                                softWrap: true,
                                                style: const TextStyle(fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          () {
                                            final partId = widget.data.details
                                                .expand((element) => element.masterProductionType.details)
                                                .where((e) => e.parts.opAssemblyId == widget.data.opAssemblyModel[index].id)
                                                .toList()[i]
                                                .id;
                                            final partQty = widget.data.details
                                                .expand((element) => element.masterProductionType.details)
                                                .where((e) => e.parts.opAssemblyId == widget.data.opAssemblyModel[index].id)
                                                .toList()[i]
                                                .qty;
                                            final prodQty = widget.data.details
                                                .firstWhere((element) => element.masterProductionType.details.map((e) => e.id).contains(partId))
                                                .productionQty;
                                            return '${partQty * prodQty}';
                                          }(),
                                          softWrap: true,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startScrolling() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _animationControllerTop.repeat();
        _animationControllerBottom.repeat();
      }
    });
  }

  void _scrollListenerTop() {
    if (_scrollControllerTop.hasClients) {
      double maxScrollExtent = _scrollControllerTop.position.maxScrollExtent;
      double pixels = _scrollControllerTop.position.pixels;

      if (_scrollingForwardTop) {
        _scrollControllerTop.jumpTo(pixels + 1);
        if (_scrollControllerTop.position.pixels >= maxScrollExtent) {
          _animationControllerTop.stop();
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              setState(() {
                _scrollingForwardTop = !_scrollingForwardTop;
                _animationControllerTop.forward(from: 0);
              });
            }
          });
        }
      } else {
        _scrollControllerTop.jumpTo(pixels - 1);
        if (_scrollControllerTop.position.pixels <= 0) {
          _animationControllerTop.stop();
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              setState(() {
                _scrollingForwardTop = !_scrollingForwardTop;
                _animationControllerTop.forward(from: 0);
              });
            }
          });
        }
      }
    }
  }

  void _scrollListenerBottom() {
    if (_scrollControllerBottom.hasClients) {
      double maxScrollExtent = _scrollControllerBottom.position.maxScrollExtent;
      double pixels = _scrollControllerBottom.position.pixels;

      if (_scrollingForwardBottom) {
        _scrollControllerBottom.jumpTo(pixels + 1);
        if (_scrollControllerBottom.position.pixels >= maxScrollExtent) {
          _animationControllerBottom.stop();
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              setState(() {
                _scrollingForwardBottom = !_scrollingForwardBottom;
                _animationControllerBottom.forward(from: 0);
              });
            }
          });
        }
      } else {
        _scrollControllerBottom.jumpTo(pixels - 1);
        if (_scrollControllerBottom.position.pixels <= 0) {
          _animationControllerBottom.stop();
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              setState(() {
                _scrollingForwardBottom = !_scrollingForwardBottom;
                _animationControllerBottom.forward(from: 0);
              });
            }
          });
        }
      }
    }
  }
}

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
