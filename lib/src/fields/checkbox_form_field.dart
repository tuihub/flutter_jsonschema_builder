import 'package:flutter/material.dart';
import 'package:flutter_jsonschema_builder/src/builder/logic/widget_builder_logic.dart';
import 'package:flutter_jsonschema_builder/src/fields/fields.dart';
import 'package:flutter_jsonschema_builder/src/fields/shared.dart';

class CheckboxJFormField extends PropertyFieldWidget<bool> {
  const CheckboxJFormField({
    super.key,
    required super.property,
    required super.onSaved,
    super.onChanged,
    super.customValidator,
  });

  @override
  _CheckboxJFormFieldState createState() => _CheckboxJFormFieldState();
}

class _CheckboxJFormFieldState extends State<CheckboxJFormField> {
  @override
  void initState() {
    widget.triggerDefaultValue();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      key: Key(widget.property.idKey),
      initialValue: widget.property.initialValue ?? widget.property.defaultValue ?? false,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onSaved: widget.onSaved,
      validator: widget.customValidator,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              isError: field.hasError,
              value: field.value ?? false,
              title: Text(
                WidgetBuilderInherited.of(context)
                    .uiConfig
                    .labelText(widget.property),
                style: widget.property.readOnly
                    ? const TextStyle(color: Colors.grey)
                    : WidgetBuilderInherited.of(context).uiConfig.label,
              ),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: widget.property.readOnly
                  ? null
                  : (bool? value) {
                      field.didChange(value);
                      if (widget.onChanged != null && value != null) {
                        widget.onChanged!(value);
                      }
                    },
            ),
            if (field.hasError) CustomErrorText(text: field.errorText!),
          ],
        );
      },
    );
  }
}
