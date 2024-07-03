import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jsonschema_builder/src/builder/logic/widget_builder_logic.dart';
import 'package:flutter_jsonschema_builder/src/fields/fields.dart';
import 'package:flutter_jsonschema_builder/src/fields/shared.dart';
import 'package:flutter_jsonschema_builder/src/utils/input_validation_json_schema.dart';

import '../models/models.dart';
import '../utils/utils.dart';

class TextJFormField extends PropertyFieldWidget<String> {
  const TextJFormField({
    super.key,
    required super.property,
    required super.onSaved,
    super.onChanged,
    super.customValidator,
  });

  @override
  _TextJFormFieldState createState() => _TextJFormFieldState();
}

class _TextJFormFieldState extends State<TextJFormField> {
  SchemaProperty get property => widget.property;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    widget.triggerDefaultValue();
    _controller.text = property.initialValue ?? property.defaultValue ?? '';
    super.initState();
  }

  @override
  void didUpdateWidget(TextJFormField oldWidget) {
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
      property: property,
      child: AbsorbPointer(
        absorbing: property.disabled ?? false,
        child: TextFormField(
          key: Key(property.idKey),
          controller: _controller,
          autofocus: (property.autoFocus ?? false),
          keyboardType: getTextInputTypeFromFormat(property.format),
          maxLines: property.widget == "textarea" ? null : 1,
          obscureText: property.format == PropertyFormat.password,
          onSaved: widget.onSaved,
          maxLength: property.maxLength,
          inputFormatters: [textInputCustomFormatter(property.format)],
          autovalidateMode: AutovalidateMode.onUserInteraction,
          readOnly: property.readOnly,
          onChanged: (value) {
            if (widget.onChanged != null) widget.onChanged!(value);
          },
          validator: (String? value) {
            if (property.requiredNotNull && value != null) {
              final validated = inputValidationJsonSchema(
                localizedTexts: uiConfig.localizedTexts,
                newValue: value,
                property: property,
              );
              if (validated != null) return validated;
            }

            if (widget.customValidator != null)
              return widget.customValidator!(value);

            return null;
          },
          style: property.readOnly
              ? const TextStyle(color: Colors.grey)
              : uiConfig.label,
          decoration: InputDecoration(
            helperText: property.help != null && property.help!.isNotEmpty
                ? property.help
                : null,
            labelStyle: const TextStyle(color: Colors.blue),
            errorStyle: uiConfig.error,
            labelText: uiConfig.fieldLabelText(property),
          ),
        ),
      ),
    );
  }

  TextInputType getTextInputTypeFromFormat(PropertyFormat format) {
    late TextInputType textInputType;

    switch (format) {
      case PropertyFormat.general:
        textInputType = TextInputType.text;
        break;
      case PropertyFormat.password:
        textInputType = TextInputType.visiblePassword;
        break;
      case PropertyFormat.date:
        textInputType = TextInputType.datetime;
        break;
      case PropertyFormat.datetime:
        textInputType = TextInputType.datetime;
        break;
      case PropertyFormat.email:
        textInputType = TextInputType.emailAddress;
        break;
      case PropertyFormat.dataurl:
        textInputType = TextInputType.text;
        break;
      case PropertyFormat.uri:
        textInputType = TextInputType.url;
        break;
    }

    return textInputType;
  }

  TextInputFormatter textInputCustomFormatter(PropertyFormat format) {
    late TextInputFormatter textInputFormatter;
    switch (format) {
      case PropertyFormat.email:
        textInputFormatter = EmailTextInputJsonFormatter();
        break;
      default:
        textInputFormatter =
            DefaultTextInputJsonFormatter(pattern: property.pattern);
        break;
    }
    return textInputFormatter;
  }
}
