import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_jsonschema_builder/src/builder/logic/widget_builder_logic.dart';
import 'package:flutter_jsonschema_builder/src/fields/fields.dart';
import 'package:flutter_jsonschema_builder/src/fields/shared.dart';
import '../models/models.dart';

class RadioButtonJFormField extends PropertyFieldWidget<dynamic> {
  const RadioButtonJFormField({
    super.key,
    required super.property,
    required super.onSaved,
    super.onChanged,
    super.customValidator,
  });

  @override
  _RadioButtonJFormFieldState createState() => _RadioButtonJFormFieldState();
}

class _RadioButtonJFormFieldState extends State<RadioButtonJFormField> {
  bool booleanValue = false;

  dynamic groupValue;

  @override
  void initState() {
    log(widget.property.defaultValue.toString());

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

    // fill groupValue
    if (widget.property.type == SchemaType.boolean) {
      groupValue = widget.property.defaultValue;
      if (widget.property.initialValue != null)
        groupValue = widget.property.initialValue;
    } else {
      groupValue = widget.property.defaultValue ?? 0;
      if (widget.property.initialValue != null)
        groupValue = widget.property.initialValue ?? 0;
    }

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

    inspect(widget.property);
    return FormField<dynamic>(
      key: Key(widget.property.idKey),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      initialValue: groupValue,
      onSaved: (newValue) {
        widget.onSaved(newValue);
      },
      validator: (value) {
        if (widget.customValidator != null)
          return widget.customValidator!(value);

        return null;
      },
      builder: (field) {
        return WrapFieldWithLabel(
          property: widget.property,
          ignoreFieldLabel: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List<Widget>.generate(
                  widget.property.enumNames?.length ?? 0,
                  (int i) => RadioListTile(
                    value: widget.property.enumm != null
                        ? widget.property.enumm![i]
                        : i,
                    title: Text(
                      widget.property.enumNames![i],
                      style: widget.property.readOnly
                          ? const TextStyle(color: Colors.grey)
                          : WidgetBuilderInherited.of(context).uiConfig.label,
                    ),
                    groupValue: groupValue,
                    onChanged: widget.property.readOnly
                        ? null
                        : (dynamic value) {
                            log(value.toString());
                            groupValue = value;
                            if (value != null) {
                              field.didChange(groupValue);
                              if (widget.onChanged != null) {
                                widget.onChanged!(groupValue!);
                              }
                            }
                          },
                  ),
                ),
              ),
              if (field.hasError) CustomErrorText(text: field.errorText!),
            ],
          ),
        );
      },
    );
  }
}
