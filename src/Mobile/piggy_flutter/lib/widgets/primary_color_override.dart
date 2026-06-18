import 'package:flutter/material.dart';
import 'package:piggy_flutter/theme/theme.dart';

class PrimaryColorOverride extends StatelessWidget {
  const PrimaryColorOverride({Key? key, this.color, this.child})
      : super(key: key);

  final Color? color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      child: child!,
      data: Theme
          .of(context)
          .copyWith(primaryColor: color ?? Theme.of(context).accentColor),
    );
  }
}
