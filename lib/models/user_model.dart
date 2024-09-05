import 'package:equatable/equatable.dart';
import 'package:yanmar_app/models/role_model.dart';

class UserModel extends Equatable {
  final int id;
  final String uuid;
  final String username;
  final RoleModel role;

  const UserModel({required this.id, required this.uuid, required this.username, required this.role});

  factory UserModel.fromSupabase(Map<String, dynamic> json) {
    return UserModel(id: json['id'], uuid: json['uuid'], username: json['username'], role: RoleModel.fromSupabase(json['user_roles']));
  }

  @override
  List<Object?> get props => [
        id,
        uuid,
        username,
        role,
      ];
}
