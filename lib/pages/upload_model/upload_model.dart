import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:yanmar_app/bloc/show_production_model_bloc/show_production_model_bloc.dart';
import 'package:yanmar_app/bloc/upload_production_model_bloc/upload_production_model_bloc.dart';
import 'package:yanmar_app/models/role_model.dart';
import 'package:yanmar_app/pages/upload_model/helper/process_model_excel.dart';

class UploadModelPage extends StatefulWidget {
  const UploadModelPage({super.key});

  static const allowedUserRoles = [superAdminRole, supervisorRole];
  static const route = '/upload-model';

  final defaultLimit = 25;

  @override
  State<UploadModelPage> createState() => _UploadModelPageState();
}

class _UploadModelPageState extends State<UploadModelPage> {
  final ShowProductionModelBloc _bloc = ShowProductionModelBloc();
  final UploadProductionModelBloc _uploadBloc = UploadProductionModelBloc();

  final DateFormat dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

  bool isDialogVisible = false;

  @override
  void initState() {
    super.initState();
    _bloc.add(FetchProductionModel(page: 1, limit: widget.defaultLimit));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => _bloc,
        ),
        BlocProvider(
          create: (context) => _uploadBloc,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Upload Product Model'),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextButton(
                onPressed: () async {
                  final ByteData data = await rootBundle.load('assets/template_excel/Template Upload Model.xlsx');
                  Uint8List fileData = data.buffer.asUint8List();

                  String fileName = 'Template Upload Model';
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
        body: BlocListener<UploadProductionModelBloc, UploadProductionModelState>(
          listener: (context, state) async {
            if (state is UploadProductionModelFailed) {
              await showDialog(
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
              _bloc.add(FetchProductionModel(page: 1, limit: widget.defaultLimit));
            } else if (state is UploadProductionModelLoading) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const AlertDialog(
                  content: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );

              setState(() {
                isDialogVisible = true;
              });
            } else if (state is UploadProductionModelDone) {
              _bloc.add(FetchProductionModel(page: 1, limit: widget.defaultLimit));
            }
          },
          child: BlocBuilder<ShowProductionModelBloc, ShowProductionModelState>(
            builder: (context, state) {
              if (state is ShowProductionModelLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is ShowProductionModelFailed) {
                return Center(child: Text('Failed to load data: ${state.message}'));
              } else if (state is ShowProductionModelDone) {
                if (state.productionModels.isEmpty) {
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
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints.loose(const Size(500, double.infinity)),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 80.0, top: 20.0),
                            child: ListView.builder(
                              itemCount: state.currentPage == 1 ? state.productionModels.length + 1 : state.productionModels.length,
                              itemBuilder: (context, index) {
                                if (state.currentPage == 1 && index == 0) {
                                  return Card(
                                    color: Colors.grey.shade700,
                                    child: ListTile(
                                      onTap: () async {
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

                                            if (context.mounted) {
                                              final String? modelName = await showDialog(
                                                context: context,
                                                builder: (_) {
                                                  final GlobalKey<FormFieldState> key = GlobalKey();

                                                  return Dialog.fullscreen(
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(20.0),
                                                      child: Column(
                                                        children: [
                                                          const Text(
                                                            'Excel Data',
                                                            style: TextStyle(fontSize: 16),
                                                          ),
                                                          const SizedBox(height: 10),
                                                          ConstrainedBox(
                                                            constraints: BoxConstraints.loose(const Size(300, double.infinity)),
                                                            child: TextFormField(
                                                              key: key,
                                                              validator: (value) =>
                                                                  value == null || value.isEmpty ? 'Model name must not be empty' : null,
                                                              decoration: const InputDecoration(
                                                                  label: Text('Model name'),
                                                                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                                                            ),
                                                          ),
                                                          const SizedBox(height: 10),
                                                          Expanded(
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
                                                              child: SingleChildScrollView(
                                                                child: Table(
                                                                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                                                  border: TableBorder.all(color: Colors.grey),
                                                                  children: [
                                                                    TableRow(
                                                                      children: [
                                                                        const Text(
                                                                          'Part Code',
                                                                          style: TextStyle(color: Colors.amber),
                                                                        ),
                                                                        const Text(
                                                                          'Part Description',
                                                                          style: TextStyle(color: Colors.amber),
                                                                        ),
                                                                        const Text(
                                                                          'Locator',
                                                                          style: TextStyle(color: Colors.amber),
                                                                        ),
                                                                        const Text(
                                                                          'PIC',
                                                                          style: TextStyle(color: Colors.amber),
                                                                        ),
                                                                        const Text(
                                                                          'Rack',
                                                                          style: TextStyle(color: Colors.amber),
                                                                        ),
                                                                        const Text(
                                                                          'Op Assy',
                                                                          style: TextStyle(color: Colors.amber),
                                                                        ),
                                                                        const Text(
                                                                          'Bagian',
                                                                          style: TextStyle(color: Colors.amber),
                                                                        ),
                                                                        const Text(
                                                                          'Qty',
                                                                          style: TextStyle(color: Colors.amber),
                                                                        ),
                                                                      ].map((e) => TableCell(child: Center(child: e))).toList(),
                                                                    ),
                                                                    ...List.generate(result.length, (index) {
                                                                      return TableRow(
                                                                        children: [
                                                                          Text(
                                                                            result[index]['part_code'],
                                                                            textAlign: TextAlign.center,
                                                                          ),
                                                                          Text(
                                                                            result[index]['part_description'],
                                                                            textAlign: TextAlign.center,
                                                                          ),
                                                                          Text(
                                                                            result[index]['locator'],
                                                                            textAlign: TextAlign.center,
                                                                          ),
                                                                          Text(
                                                                            result[index]['pic'],
                                                                            textAlign: TextAlign.center,
                                                                          ),
                                                                          Text(
                                                                            result[index]['rack'],
                                                                            textAlign: TextAlign.center,
                                                                          ),
                                                                          Text(
                                                                            result[index]['op_assy'],
                                                                            textAlign: TextAlign.center,
                                                                          ),
                                                                          Text(
                                                                            result[index]['rack_placement'],
                                                                            textAlign: TextAlign.center,
                                                                          ),
                                                                          Text(
                                                                            result[index]['qty'].toString(),
                                                                            textAlign: TextAlign.center,
                                                                          ),
                                                                        ]
                                                                            .map(
                                                                              (e) => TableCell(child: Center(child: e)),
                                                                            )
                                                                            .toList(),
                                                                      );
                                                                    })
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          ConstrainedBox(
                                                            constraints: BoxConstraints.loose(const Size(300, double.infinity)),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                    child: ElevatedButton(
                                                                        onPressed: () {
                                                                          _.pop(null);
                                                                        },
                                                                        child: const Text('Cancel'))),
                                                                const SizedBox(width: 20),
                                                                Expanded(
                                                                    child: ElevatedButton(
                                                                        onPressed: () {
                                                                          if (key.currentState!.validate()) {
                                                                            _.pop(key.currentState!.value.toString().trim());
                                                                          }
                                                                        },
                                                                        child: const Text('Upload'))),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                              if (modelName != null && modelName.isNotEmpty) {
                                                _uploadBloc.add(UploadModel(result, modelName));
                                              }
                                            }
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            showDialog(
                                              context: context,
                                              builder: (_) {
                                                return AlertDialog(
                                                  title: const Text('Failed to Upload Model'),
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
                                      title: const Center(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.add),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text('Add Model'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  final int i = state.currentPage == 1 ? index - 1 : index;

                                  return Card(
                                    child: ListTile(
                                      onTap: () {},
                                      title: Text(state.productionModels[i].typeName),
                                      trailing: Text(state.productionModels[i].estimatedProductionTime.toString().split('.').first),
                                      subtitle: Text('created: ${dateFormatter.format(state.productionModels[i].createdAt.toLocal())}'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: PageIndicator(
                              currentPageIndex: state.currentPage - 1,
                              maxLength: (state.totalData ~/ state.limit).toInt() + 1,
                              onUpdateCurrentPageIndex: onUpdateCurrentPageIndex,
                              isOnDesktopAndWeb: _isOnDesktopAndWeb),
                        ),
                      )
                    ],
                  );
                }
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

  void onUpdateCurrentPageIndex(int index) {
    print(index);
    _bloc.add(FetchProductionModel(limit: widget.defaultLimit, page: index + 1));
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
}

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
