import 'package:equatable/equatable.dart';
import 'package:yanmar_app/models/role_model.dart';

class UserModel extends Equatable {
  final int id;
  final String username;
  final RoleModel role;

  const UserModel({required this.id, required this.username, required this.role});

  factory UserModel.fromSupabase(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      role: RoleModel.fromSupabase(map['user_roles']),
    );
  }

  @override
  List<Object?> get props => [id, username, role];
}
