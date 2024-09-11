part of 'upload_production_model_bloc.dart';

sealed class UploadProductionModelEvent extends Equatable {
  const UploadProductionModelEvent();

  @override
  List<Object> get props => [];
}

final class UploadModel extends UploadProductionModelEvent {
  final List<Map<String, dynamic>> excelData;
  final String modelName;

  const UploadModel(this.excelData, this.modelName);

  @override
  List<Object> get props => [excelData, modelName];
}
