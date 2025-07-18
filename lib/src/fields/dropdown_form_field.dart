import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_jsonschema_builder/src/builder/logic/widget_builder_logic.dart';
import 'package:flutter_jsonschema_builder/src/fields/fields.dart';
import 'package:flutter_jsonschema_builder/src/fields/shared.dart';
import '../models/models.dart';

class DropDownJFormField extends PropertyFieldWidget<dynamic> {
  const DropDownJFormField({
    super.key,
    required super.property,
    required super.onSaved,
    super.onChanged,
    this.customPickerHandler,
    super.customValidator,
  });

  final Future<dynamic> Function(Map)? customPickerHandler;
  @override
  _DropDownJFormFieldState createState() => _DropDownJFormFieldState();
}

class _DropDownJFormFieldState extends State<DropDownJFormField> {
  dynamic value;
  @override
  void initState() {
    // fill enum property

    if (widget.property.enumm == null) {
      switch (widget.property.type) {
        case SchemaType.boolean:
          widget.property.enumm = [true, false];
          break;
        default:
          widget.property.enumm =
              widget.property.enumNames?.map((e) => e.toString()).toList() ??
                  [];
      }
    }

    value = widget.property.defaultValue;
    if (widget.property.initialValue != null)
      value = widget.property.initialValue;
    widget.triggerDefaultValue();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.property.enumm != null, 'enum is required');
    assert(
      () {
        if (widget.property.enumNames != null) {
          return widget.property.enumNames!.length ==
              widget.property.enumm!.length;
        }
        return true;
      }(),
      '[enumNames] and [enum]  must be the same size ',
    );
    final uiConfig = WidgetBuilderInherited.of(context).uiConfig;
    return WrapFieldWithLabel(
      property: widget.property,
      child: GestureDetector(
        onTap: _onTap,
        child: AbsorbPointer(
          absorbing: widget.customPickerHandler != null,
          child: DropdownButtonFormField<dynamic>(
            key: Key(widget.property.idKey),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            hint: Text(uiConfig.localizedTexts.select()),
            isExpanded: false,
            validator: (value) {
              if (widget.property.requiredNotNull && value == null) {
                return uiConfig.localizedTexts.required();
              }
              if (widget.customValidator != null)
                return widget.customValidator!(value);
              return null;
            },
            items: _buildItems(),
            value: value,
            onChanged: _onChanged,
            onSaved: widget.onSaved,
            style: widget.property.readOnly
                ? const TextStyle(color: Colors.grey)
                : uiConfig.label,
            decoration: InputDecoration(
              errorStyle: uiConfig.error,
              labelText: uiConfig.fieldLabelText(widget.property),
            ),
          ),
        ),
      ),
    );
  }

  void _onTap() async {
    log('ontap');
    if (widget.customPickerHandler == null) return;
    final response = await widget.customPickerHandler!(_getItems());
    if (response != null) _onChanged(response);
  }

  void _onChanged(dynamic value) {
    if (widget.property.readOnly) return;

    if (widget.onChanged != null) widget.onChanged!(value);
    setState(() {
      this.value = value;
    });
  }

  List<DropdownMenuItem>? _buildItems() {
    final w = <DropdownMenuItem>[];
    for (var i = 0; i < widget.property.enumm!.length; i++) {
      final value = widget.property.enumm![i];
      final text = widget.property.enumNames?[i] ?? value;
      w.add(
        DropdownMenuItem(
          value: value,
          child: Text(text.toString()),
        ),
      );
    }
    return w;
  }

  Map _getItems() {
    final data = {};
    for (var i = 0; i < widget.property.enumm!.length; i++) {
      final value = widget.property.enumm![i];
      final text = widget.property.enumNames?[i] ?? value;
      data[value] = text;
    }

    return data;
  }
}
