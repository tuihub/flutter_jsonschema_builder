// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jsonschema_builder/src/builder/array_schema_builder.dart';
import 'package:flutter_jsonschema_builder/src/builder/logic/widget_builder_logic.dart';
import 'package:flutter_jsonschema_builder/src/builder/object_schema_builder.dart';
import 'package:flutter_jsonschema_builder/src/builder/property_schema_builder.dart';
import 'package:flutter_jsonschema_builder/src/models/json_form_schema_style.dart';

import '../models/models.dart';

typedef FileHandler = Map<String, Future<List<XFile>?> Function()?> Function();
typedef CustomPickerHandler = Map<String, Future<dynamic> Function(Map data)>
    Function();

typedef CustomValidatorHandler = Map<String, String? Function(dynamic)?>
    Function();

class JsonForm extends StatefulWidget {
  const JsonForm({
    super.key,
    this.controller,
    required this.jsonSchema,
    this.jsonData = '{}',
    this.uiSchema,
    required this.onFormDataSaved,
    this.fileHandler,
    this.jsonFormSchemaUiConfig,
    this.customPickerHandler,
    this.customValidatorHandler,
  });

  final JsonFormController? controller;

  final String jsonSchema;
  final String jsonData;
  final void Function(dynamic) onFormDataSaved;

  final String? uiSchema;
  final FileHandler? fileHandler;
  final JsonFormSchemaUiConfig? jsonFormSchemaUiConfig;
  final CustomPickerHandler? customPickerHandler;
  final CustomValidatorHandler? customValidatorHandler;

  @override
  _JsonFormState createState() => _JsonFormState();
}

class _JsonFormState extends State<JsonForm> {
  late SchemaObject mainSchema;

  final _formKey = GlobalKey<FormState>();

  _JsonFormState();

  @override
  void initState() {
    late Map<String, dynamic> initialValue;
    try {
      initialValue = json.decode(widget.jsonData) as Map<String, dynamic>;
    } catch (e) {
      initialValue = {};
    }

    mainSchema = (Schema.fromJson(
      json.decode(widget.jsonSchema),
      id: kGenesisIdKey,
    ) as SchemaObject)
      ..setUiSchema(
        widget.uiSchema != null ? json.decode(widget.uiSchema!) : null,
      )
      ..initialValue = initialValue;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetBuilderInherited(
      mainSchema: mainSchema,
      fileHandler: widget.fileHandler,
      customPickerHandler: widget.customPickerHandler,
      customValidatorHandler: widget.customValidatorHandler,
      child: Builder(
        builder: (context) {
          final widgetBuilderInherited = WidgetBuilderInherited.of(context);
          final uiConfig = widgetBuilderInherited.uiConfig;
          widget.controller
              ?._setSubmitFunction(() => onSubmit(widgetBuilderInherited));

          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: <Widget>[
                    if (uiConfig.debugMode)
                      TextButton(
                        onPressed: () {
                          inspect(mainSchema);
                        },
                        child: const Text('INSPECT'),
                      ),
                    _buildHeaderTitle(context),
                    FormFromSchemaBuilder(
                      mainSchema: mainSchema,
                      schema: mainSchema,
                    ),
                    const SizedBox(height: 20),
                    uiConfig.submitButtonBuilder == null
                        ? ElevatedButton(
                            onPressed: () => onSubmit(widgetBuilderInherited),
                            child: Text(
                              uiConfig.localizedTexts.submit(),
                            ),
                          )
                        : uiConfig.submitButtonBuilder!(
                            () => onSubmit(widgetBuilderInherited),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    )..setJsonFormSchemaStyle(context, widget.jsonFormSchemaUiConfig);
  }

  Widget _buildHeaderTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          child: Text(
            mainSchema.title,
            style: WidgetBuilderInherited.of(context).uiConfig.title,
            textAlign: WidgetBuilderInherited.of(context).uiConfig.titleAlign,
          ),
        ),
        const Divider(),
        if (mainSchema.description != null)
          SizedBox(
            width: double.infinity,
            child: Text(
              mainSchema.description!,
              style: WidgetBuilderInherited.of(context).uiConfig.description,
              textAlign: WidgetBuilderInherited.of(context).uiConfig.titleAlign,
            ),
          ),
      ],
    );
  }

  //  Form methods
  bool onSubmit(WidgetBuilderInherited widgetBuilderInherited) {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState?.save();

      log(widgetBuilderInherited.data.toString());
      widget.onFormDataSaved(widgetBuilderInherited.data);
      return true;
    }
    return false;
  }
}

class FormFromSchemaBuilder extends StatelessWidget {
  const FormFromSchemaBuilder({
    super.key,
    required this.mainSchema,
    required this.schema,
    this.schemaObject,
  });

  final Schema mainSchema;
  final Schema schema;
  final SchemaObject? schemaObject;

  @override
  Widget build(BuildContext context) {
    if (schema is SchemaProperty) {
      return PropertySchemaBuilder(
        mainSchema: mainSchema,
        schemaProperty: schema as SchemaProperty,
      );
    }
    if (schema is SchemaArray) {
      return ArraySchemaBuilder(
        mainSchema: mainSchema,
        schemaArray: schema as SchemaArray,
      );
    }

    if (schema is SchemaObject) {
      return ObjectSchemaBuilder(
        mainSchema: mainSchema,
        schemaObject: schema as SchemaObject,
      );
    }

    return const SizedBox.shrink();
  }
}

class JsonFormController {
  JsonFormController();

  late bool Function() _submit;

  void _setSubmitFunction(bool Function() submit) {
    _submit = submit;
  }

  bool submit() {
    return _submit();
  }
}
