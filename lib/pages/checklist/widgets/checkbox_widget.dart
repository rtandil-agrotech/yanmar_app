import 'package:flutter/material.dart';

class CheckboxWidget extends StatefulWidget {
  const CheckboxWidget({super.key, required this.onChangeCallback});

  final Function onChangeCallback;

  @override
  State<CheckboxWidget> createState() => _CheckboxWidgetState();
}

class _CheckboxWidgetState extends State<CheckboxWidget> {
  bool checkboxValue = false;
  int pressed = 0;

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: checkboxValue,
      onChanged: (bool? value) {
        if (value != null) {
          if (value == true) {
            if (pressed == 0) {
              widget.onChangeCallback();
            }
            pressed++;
          }

          setState(() {
            checkboxValue = value;
          });
        }
      },
    );
  }
}
