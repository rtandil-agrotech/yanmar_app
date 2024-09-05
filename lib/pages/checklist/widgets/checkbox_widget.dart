import 'package:flutter/material.dart';

class CheckboxWidget extends StatefulWidget {
  const CheckboxWidget({super.key, required this.status, required this.onChangeCallback});

  final Function onChangeCallback;
  final bool status;

  @override
  State<CheckboxWidget> createState() => _CheckboxWidgetState();
}

class _CheckboxWidgetState extends State<CheckboxWidget> {
  late bool checkboxValue;

  @override
  void initState() {
    checkboxValue = widget.status;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: checkboxValue,
      onChanged: (bool? value) {
        if (value != null && value == true) {
          checkboxValue = value;

          widget.onChangeCallback();
        }
      },
    );
  }
}
