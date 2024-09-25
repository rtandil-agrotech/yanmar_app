import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:yanmar_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:yanmar_app/bloc/delete_monthly_plan_produksi_bloc/delete_monthly_plan_produksi_bloc.dart';
import 'package:yanmar_app/bloc/monthly_plan_produksi_data_fetcher_bloc/monthly_plan_produksi_data_fetcher_bloc.dart';
import 'package:yanmar_app/bloc/upload_monthly_plan_produksi_bloc/upload_monthly_plan_produksi_bloc.dart';
import 'package:yanmar_app/models/role_model.dart';
import 'package:yanmar_app/pages/upload_monthly_plan/helper/process_monthly_plan_excel.dart';

class UploadMonthlyPlanPage extends StatefulWidget {
  const UploadMonthlyPlanPage({super.key});

  static const allowedUserRoles = [superAdminRole, supervisorRole];
  static const route = '/upload-monthly-plan';

  @override
  State<UploadMonthlyPlanPage> createState() => _UploadMonthlyPlanPageState();
}

class _UploadMonthlyPlanPageState extends State<UploadMonthlyPlanPage> {
  DateTime selectedDate = DateTime.now();
  final _bloc = MonthlyPlanProduksiDataFetcherBloc();
  final _deleteBloc = DeleteMonthlyPlanProduksiBloc();
  final _uploadBloc = UploadMonthlyPlanProduksiBloc();

  final DateFormat formatter = DateFormat('HH:mm');
  final DateFormat selectedDateFormatter = DateFormat('MMMM yyyy');

  @override
  void initState() {
    _bloc.add(FetchMonthlyPlanProduksiData(currentTime: selectedDate));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => _bloc,
        ),
        BlocProvider(
          create: (context) => _deleteBloc,
        ),
        BlocProvider(
          create: (context) => _uploadBloc,
        )
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Upload Monthly Plan'),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextButton(
                onPressed: () async {
                  final ByteData data = await rootBundle.load('assets/template_excel/Template Upload Monthly Plan.xlsx');
                  Uint8List fileData = data.buffer.asUint8List();

                  String fileName = 'Template Upload Monthly Plan';
                  MimeType mimeType = MimeType.custom;

                  await FileSaver.instance.saveFile(
                    name: fileName,
                    bytes: fileData,
                    ext: 'xlsx',
                    mimeType: mimeType,
                    customMimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                  );
                },
                child: const Text('Download Template Excel'),
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
        body: ConstrainedBox(
          constraints: BoxConstraints.expand(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          child: MultiBlocListener(
            listeners: [
              BlocListener<DeleteMonthlyPlanProduksiBloc, DeleteMonthlyPlanProduksiState>(
                listener: (context, state) async {
                  if (state is DeleteMonthlyPlanProduksiFailed) {
                    await showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: const Text('Failed to Delete Plan'),
                          content: Text(state.error),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                _.pop(false);
                              },
                              child: const Text('Dismiss'),
                            ),
                          ],
                        );
                      },
                    );
                    _bloc.add(FetchMonthlyPlanProduksiData(currentTime: selectedDate));
                  } else if (state is DeleteMonthlyPlanProduksiLoading) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Loading...')));
                  } else if (state is DeleteMonthlyPlanProduksiDone) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    _bloc.add(FetchMonthlyPlanProduksiData(currentTime: selectedDate));
                  }
                },
              ),
              BlocListener<UploadMonthlyPlanProduksiBloc, UploadMonthlyPlanProduksiState>(
                listener: (context, state) async {
                  if (state is UploadMonthlyPlanProduksiFailed) {
                    await showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: const Text('Failed to Upload Plan'),
                          content: Text(state.error),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                _.pop(false);
                              },
                              child: const Text('Dismiss'),
                            ),
                          ],
                        );
                      },
                    );
                    _bloc.add(FetchMonthlyPlanProduksiData(currentTime: selectedDate));
                  } else if (state is UploadMonthlyPlanProduksiLoading) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Loading...')));
                  } else if (state is UploadMonthlyPlanProduksiDone) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    _bloc.add(FetchMonthlyPlanProduksiData(currentTime: selectedDate));
                  }
                },
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
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
                              _bloc.add(FetchMonthlyPlanProduksiData(currentTime: selectedDate));
                            });
                          }
                        },
                        child: const Text('Select Date'),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text('Current Selected Date: ${selectedDateFormatter.format(selectedDate)}'),
                      const Spacer(),
                      BlocBuilder<MonthlyPlanProduksiDataFetcherBloc, MonthlyPlanProduksiDataFetcherState>(
                        builder: (context, state) {
                          if (state is MonthlyPlanProduksiDataFetcherDone) {
                            if (state.result.isEmpty) {
                              return Container();
                            } else {
                              return ElevatedButton(
                                onPressed: () async {
                                  final shouldDelete = await showDialog<bool>(
                                      context: context,
                                      builder: (_) {
                                        return AlertDialog(
                                          title: Text('Are you sure you want to delete plan for ${selectedDateFormatter.format(selectedDate)}?'),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () {
                                                _.pop(false);
                                              },
                                              style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.black12)),
                                              child: const Text('Dismiss'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                _.pop(true);
                                              },
                                              child: const Text('Confirm'),
                                            )
                                          ],
                                        );
                                      });
                                  if (shouldDelete != null && shouldDelete == true) {
                                    _deleteBloc.add(DeletePlan(state.result.first.id));
                                  }
                                },
                                style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red)),
                                child: const Text('Delete Current Plan'),
                              );
                            }
                          }
                          return Container();
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: BlocBuilder<MonthlyPlanProduksiDataFetcherBloc, MonthlyPlanProduksiDataFetcherState>(
                      builder: (context, state) {
                        if (state is MonthlyPlanProduksiDataFetcherLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is MonthlyPlanProduksiDataFetcherFailed) {
                          return Center(child: Text('Failed to load data: ${state.message}'));
                        } else if (state is MonthlyPlanProduksiDataFetcherDone) {
                          if (state.result.isEmpty) {
                            return Center(
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: ['xlsx'],
                                      allowMultiple: false,
                                    );

                                    if (pickedFile != null) {
                                      var bytes = pickedFile.files.single.bytes;
                                      var excel = Excel.decodeBytes(bytes!);
                                      final result = processExcel(excel);

                                      final int userId = () {
                                        if (context.mounted) {
                                          return (context.read<AuthBloc>().state as AuthenticatedState).user.id;
                                        } else {
                                          throw Exception('User Id not Found');
                                        }
                                      }();

                                      _uploadBloc.add(
                                        UploadPlan(result, userId, selectedDate),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      showDialog(
                                        context: context,
                                        builder: (_) {
                                          return AlertDialog(
                                            title: const Text('Failed to Upload Plan'),
                                            content: Text(e.toString()),
                                            actions: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  _.pop(false);
                                                },
                                                child: const Text('Dismiss'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  }
                                },
                                child: const Text('Upload new plan'),
                              ),
                            );
                          } else {
                            return SingleChildScrollView(
                              child: DataTable(
                                dataRowMaxHeight: double.infinity,
                                columns: const [
                                  DataColumn(
                                    label: Text('Plan'),
                                  ),
                                  DataColumn(
                                    label: Text('Qty'),
                                  )
                                ],
                                rows: List.generate(
                                  state.result.isNotEmpty ? state.result.first.details.length : 0,
                                  (index) => DataRow(
                                    cells: [
                                      DataCell(
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(state.result.first.details[index].type.typeName),
                                        ),
                                      ),
                                      DataCell(
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(state.result.first.details[index].qty.toString()),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                        return Container();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
