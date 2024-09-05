import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:yanmar_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:yanmar_app/bloc/delete_plan_produksi_bloc/delete_plan_produksi_bloc.dart';
import 'package:yanmar_app/bloc/show_plan_produksi_bloc/show_plan_produksi_bloc.dart';
import 'package:yanmar_app/bloc/upload_plan_produksi_bloc/upload_plan_produksi_bloc.dart';
import 'package:yanmar_app/models/role_model.dart';
import 'package:yanmar_app/pages/upload_daily_plan/helper/process_daily_plan_excel.dart';

class UploadDailyPlanPage extends StatefulWidget {
  const UploadDailyPlanPage({super.key});

  static const allowedUserRoles = [superAdminRole, supervisorRole];
  static const route = '/upload-daily-plan';

  @override
  State<UploadDailyPlanPage> createState() => _UploadDailyPlanPageState();
}

class _UploadDailyPlanPageState extends State<UploadDailyPlanPage> {
  DateTime selectedDate = DateTime.now();
  final _bloc = ShowPlanProduksiBloc();
  final _deleteBloc = DeletePlanProduksiBloc();
  final _uploadBloc = UploadPlanProduksiBloc();

  final DateFormat formatter = DateFormat('HH:mm');
  final DateFormat selectedDateFormatter = DateFormat('dd/MM/yyyy');

  List<bool> isChecked = [];

  @override
  void initState() {
    _bloc.add(FetchPlanProduksi(dateTime: selectedDate));
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
          title: const Text('Upload Daily Plan'),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextButton(
                onPressed: () async {
                  final ByteData data = await rootBundle.load('assets/template_excel/Template Upload Daily Plan.xlsx');
                  Uint8List fileData = data.buffer.asUint8List();

                  String fileName = 'Template Upload Daily Plan';
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
        body: MultiBlocListener(
          listeners: [
            BlocListener<DeletePlanProduksiBloc, DeletePlanProduksiState>(
              listener: (context, state) {
                if (state is DeletePlanProduksiFailed) {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: const Text('Failed to Delete Plan'),
                        content: Text(state.message),
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
                } else if (state is DeletePlanProduksiLoading) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Loading...')));
                } else if (state is DeletePlanProduksiDone) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  _bloc.add(FetchPlanProduksi(dateTime: selectedDate));
                }
              },
            ),
            BlocListener<UploadPlanProduksiBloc, UploadPlanProduksiState>(
              listener: (context, state) {
                if (state is UploadPlanProduksiFailed) {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: const Text('Failed to Upload Plan'),
                        content: Text(state.message),
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
                } else if (state is UploadPlanProduksiLoading) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Loading...')));
                } else if (state is UploadPlanProduksiDone) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  _bloc.add(FetchPlanProduksi(dateTime: selectedDate));
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
                            _bloc.add(FetchPlanProduksi(dateTime: selectedDate));
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
                    BlocBuilder<ShowPlanProduksiBloc, ShowPlanProduksiState>(
                      builder: (context, state) {
                        if (state is ShowPlanProduksiDone) {
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
                                  _deleteBloc.add(DeletePlan(state.result.map((e) => e.id).toList()));
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
                  child: BlocBuilder<ShowPlanProduksiBloc, ShowPlanProduksiState>(
                    builder: (context, state) {
                      if (state is ShowPlanProduksiLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (state is ShowPlanProduksiFailed) {
                        return Center(child: Text('Failed to load data: ${state.message}'));
                      } else if (state is ShowPlanProduksiDone) {
                        if (state.result.isEmpty) {
                          return Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['xlsx'],
                                  allowMultiple: false,
                                );

                                if (pickedFile != null) {
                                  var bytes = pickedFile.files.single.bytes;
                                  var excel = Excel.decodeBytes(bytes!);
                                  final result = ExcelProcessor.processExcel(excel, selectedDate);

                                  final int userId = () {
                                    if (mounted) {
                                      return (context.read<AuthBloc>().state as AuthenticatedState).user.id;
                                    } else {
                                      throw Exception('User Id not Found');
                                    }
                                  }();

                                  _uploadBloc.add(
                                    UploadPlan(
                                      result,
                                      userId,
                                    ),
                                  );
                                }
                              },
                              child: const Text('Upload new plan'),
                            ),
                          );
                        } else {
                          return DataTable(
                            dataRowMaxHeight: double.infinity,
                            columns: const [
                              DataColumn(
                                label: Text('Time'),
                              ),
                              DataColumn(
                                label: Text('Plan'),
                              ),
                              DataColumn(
                                label: Text('Qty'),
                              )
                            ],
                            rows: List.generate(
                              state.result.length,
                              (index) => DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                        '${formatter.format(state.result.elementAt(index).startTime.toLocal())} - ${formatter.format(state.result.elementAt(index).endTime.toLocal())}'),
                                  ),
                                  DataCell(
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: state.result.elementAt(index).details.map((e) => Text(e.type.typeName)).toList(),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: state.result.elementAt(index).details.map((e) => Text(e.qty.toString())).toList(),
                                      ),
                                    ),
                                  )
                                ],
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
    );
  }
}
