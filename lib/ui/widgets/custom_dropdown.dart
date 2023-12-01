import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomDropdownMenuItem extends PopupMenuEntry {
  final dynamic value;
  final String text;
  final Function? callback;

  const CustomDropdownMenuItem({
    super.key,
    required this.value,
    required this.text,
    this.callback,
  });

  @override
  State<CustomDropdownMenuItem> createState() => _CustomDropdownMEnuItemState();

  @override
  double get height => 32;

  @override
  bool represents(value) {
    return this.value == value;
  }
}

class _CustomDropdownMEnuItemState extends State<CustomDropdownMenuItem> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 120,
      ),
      child: InkWell(
        onTap: () {
          Navigator.pop(widget.value);
        },
        child: Container(
          constraints: const BoxConstraints(minWidth: 30.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                widget.text,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              trailing: GestureDetector(
                onTap: () {
                  if (widget.callback != null) {
                    widget.callback;
                  }
                },
                child: SvgPicture.asset(
                  'assets/images/dismiss.svg',
                  color: Colors.grey,
                  semanticsLabel: 'Back',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
