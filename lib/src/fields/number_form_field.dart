import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jsonschema_builder/src/builder/logic/widget_builder_logic.dart';
import 'package:flutter_jsonschema_builder/src/fields/fields.dart';
import 'package:flutter_jsonschema_builder/src/fields/shared.dart';

class NumberJFormField extends PropertyFieldWidget<String?> {
  const NumberJFormField({
    super.key,
    required super.property,
    required super.onSaved,
    super.onChanged,
    super.customValidator,
  });

  @override
  _NumberJFormFieldState createState() => _NumberJFormFieldState();
}

class _NumberJFormFieldState extends State<NumberJFormField> {
  Timer? _timer;

  static final inputFormatters = [
    FilteringTextInputFormatter.allow(RegExp('[0-9.,]+')),
  ];

  @override
  void initState() {
    widget.triggerDefaultValue();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiConfig = WidgetBuilderInherited.of(context).uiConfig;
    return WrapFieldWithLabel(
      property: widget.property,
      child: TextFormField(
        key: Key(widget.property.idKey),
        keyboardType: TextInputType.number,
        inputFormatters: inputFormatters,
        autofocus: false,
        initialValue: widget.property.initialValue ?? widget.property.defaultValue,
        onSaved: widget.onSaved,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        readOnly: widget.property.readOnly,
        onChanged: (value) {
          if (_timer != null && _timer!.isActive) _timer!.cancel();

          _timer = Timer(const Duration(seconds: 1), () {
            if (widget.onChanged != null) widget.onChanged!(value);
          });
        },
        style: widget.property.readOnly
            ? const TextStyle(color: Colors.grey)
            : uiConfig.label,
        validator: (String? value) {
          if (widget.property.requiredNotNull &&
              value != null &&
              value.isEmpty) {
            return uiConfig.localizedTexts.required();
          }
          if (widget.property.minLength != null &&
              value != null &&
              value.isNotEmpty &&
              value.length <= widget.property.minLength!) {
            return uiConfig.localizedTexts
                .minLength(minLength: widget.property.minLength!);
          }

          if (widget.customValidator != null)
            return widget.customValidator!(value);
          return null;
        },
        decoration: InputDecoration(
          helperText:
              widget.property.help != null && widget.property.help!.isNotEmpty
                  ? widget.property.help
                  : null,
          errorStyle: uiConfig.error,
          labelText: uiConfig.fieldLabelText(widget.property),
        ),
      ),
    );
  }
}
