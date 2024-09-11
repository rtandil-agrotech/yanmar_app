import 'package:flutter/widgets.dart';
import 'package:yanmar_app/models/role_model.dart';

class UploadModelPage extends StatefulWidget {
  const UploadModelPage({super.key});

  static const allowedUserRoles = [superAdminRole, supervisorRole];
  static const route = '/upload-daily-plan';

  @override
  State<UploadModelPage> createState() => _UploadModelPageState();
}

class _UploadModelPageState extends State<UploadModelPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
