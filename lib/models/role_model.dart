import 'package:equatable/equatable.dart';

class RoleModel extends Equatable {
  final int id;
  final String name;

  const RoleModel({required this.id, required this.name});

  factory RoleModel.fromSupabase(Map<String, dynamic> json) {
    return RoleModel(id: json['id'], name: json['role_name']);
  }

  @override
  List<Object?> get props => [id, name];
}

const superAdminRole = 'Super Admin';
const adminRole = 'Admin';
const monitoringRole = 'Monitoring';
const supervisorRole = 'Supervisor';
