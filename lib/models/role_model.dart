import 'package:equatable/equatable.dart';

class RoleModel extends Equatable {
  final int id;
  final String roleName;

  const RoleModel({required this.id, required this.roleName});

  factory RoleModel.fromSupabase(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'],
      roleName: json['role_name'],
    );
  }

  @override
  List<Object?> get props => [id, roleName];
}
