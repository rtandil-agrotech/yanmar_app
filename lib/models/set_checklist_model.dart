import 'package:equatable/equatable.dart';

class SetChecklistHeaderModel extends Equatable {
  final int prodPlanHeaderId;
  final int picId;
  final bool isHelpedPressed;
  final DateTime? allCheckDoneTime;

  const SetChecklistHeaderModel({required this.prodPlanHeaderId, required this.picId, required this.isHelpedPressed, required this.allCheckDoneTime});

  Map<String, dynamic> toJson() {
    return {
      'production_plan_header_id': prodPlanHeaderId,
      'checker_pic_id': picId,
      'is_help_pressed': isHelpedPressed,
      'all_check_done_time': allCheckDoneTime?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        prodPlanHeaderId,
        picId,
        isHelpedPressed,
        allCheckDoneTime,
      ];
}

class SetChecklistDetailModel extends Equatable {
  final int headerId;
  final int partId;
  final DateTime? checkedDoneTime;

  const SetChecklistDetailModel({required this.headerId, required this.partId, required this.checkedDoneTime});

  Map<String, dynamic> toJson() {
    return {
      'checklist_header_id': headerId,
      'part_id': partId,
      'checked_done_time': checkedDoneTime?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [headerId, partId, checkedDoneTime];
}
