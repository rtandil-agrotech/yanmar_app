import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:yanmar_app/bloc/delete_production_model_bloc/delete_production_model_bloc.dart';
import 'package:yanmar_app/bloc/show_production_model_detail_bloc/show_production_model_detail_bloc.dart';

class UploadModelDetailPage extends StatefulWidget {
  const UploadModelDetailPage({super.key, required this.id});

  final int id;

  @override
  State<UploadModelDetailPage> createState() => _UploadModelDetailPageState();
}

class _UploadModelDetailPageState extends State<UploadModelDetailPage> {
  final ShowProductionModelDetailBloc _bloc = ShowProductionModelDetailBloc();
  final DeleteProductionModelBloc _deleteBloc = DeleteProductionModelBloc();

  final DateFormat dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _bloc.add(FetchProductionModelDetail(id: widget.id));
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
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Upload Model Detail'),
          centerTitle: true,
        ),
        body: BlocListener<DeleteProductionModelBloc, DeleteProductionModelState>(
          listener: (context, state) {
            if (state is DeleteProductionModelLoading) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Deleting data...'),
                ),
              );
            } else if (state is DeleteProductionModelFailed) {
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
            } else if (state is DeleteProductionModelDone) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              context.pop();
            }
          },
          child: BlocBuilder<ShowProductionModelDetailBloc, ShowProductionModelDetailState>(
            builder: (context, state) {
              if (state is ShowProductionModelDetailLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is ShowProductionModelDetailFailed) {
                return Center(
                  child: Text('Failed to fetch data. //${state.message}'),
                );
              } else if (state is ShowProductionModelDetailDone) {
                return Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Stack(
                      children: [
                        Column(
                          children: [
                            [
                              const Text('Model Name: '),
                              Text(
                                state.header.typeName,
                                style: const TextStyle(color: Colors.amber),
                              )
                            ],
                            [
                              const Text('Created At: '),
                              Text(
                                dateFormatter.format(state.header.createdAt.toLocal()),
                                style: const TextStyle(color: Colors.amber),
                              )
                            ],
                            [
                              const Text('Cycle Time: '),
                              Text(
                                state.header.estimatedProductionTime.toString().split('.').first,
                                style: const TextStyle(color: Colors.amber),
                              )
                            ]
                          ]
                              .map((e) => Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: e,
                                    ),
                                  ))
                              .toList(),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                final shouldDelete = await showDialog<bool>(
                                    context: context,
                                    builder: (_) {
                                      return AlertDialog(
                                        title: Text('Are you sure you want to delete product ${state.header.typeName}?'),
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
                                  _deleteBloc.add(DeleteProductionModel(id: state.header.id));
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('Delete Product'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ConstrainedBox(
                        constraints: BoxConstraints.loose(const Size(500, double.infinity)),
                        child: ListView.builder(
                          itemCount: state.details.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: ListTile(
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.details[index].part.partName,
                                        style: const TextStyle(color: Colors.amber),
                                      ),
                                      Text(state.details[index].part.partCode),
                                      Text(state.details[index].part.locator),
                                    ],
                                  ),
                                  trailing: Text(
                                    state.details[index].qty.toString(),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}
