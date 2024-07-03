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
  TextEditingController _controller = TextEditingController();

  static final inputFormatters = [
    FilteringTextInputFormatter.allow(RegExp('[0-9.,]+')),
  ];

  @override
  void initState() {
    widget.triggerDefaultValue();
    _controller.text =
        widget.property.initialValue ?? widget.property.defaultValue ?? '';
    super.initState();
  }

  @override
  void didUpdateWidget(NumberJFormField oldWidget) {
    final data = WidgetBuilderInherited.of(context).getObjectData(
      WidgetBuilderInherited.of(context).data,
      widget.property.idKey,
    );
    if (data is String? && data != _controller.text)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.text = data ?? '';
      });
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiConfig = WidgetBuilderInherited.of(context).uiConfig;
    return WrapFieldWithLabel(
      property: widget.property,
      child: TextFormField(
        key: Key(widget.property.idKey),
        controller: _controller,
        keyboardType: TextInputType.number,
        inputFormatters: inputFormatters,
        autofocus: false,
        onSaved: widget.onSaved,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        readOnly: widget.property.readOnly,
        onChanged: (value) {
          if (widget.onChanged != null) widget.onChanged!(value);
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
