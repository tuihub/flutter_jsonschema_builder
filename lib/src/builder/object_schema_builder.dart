import 'package:flutter/material.dart';
import 'package:flutter_jsonschema_builder/src/builder/general_subtitle_widget.dart';
import 'package:flutter_jsonschema_builder/src/builder/logic/object_schema_logic.dart';
import 'package:flutter_jsonschema_builder/src/builder/widget_builder.dart';
import 'package:flutter_jsonschema_builder/src/fields/shared.dart';
import 'package:flutter_jsonschema_builder/src/models/models.dart';

class ObjectSchemaBuilder extends StatefulWidget {
  const ObjectSchemaBuilder({
    super.key,
    required this.mainSchema,
    required this.schemaObject,
  });

  final Schema mainSchema;
  final SchemaObject schemaObject;

  @override
  State<ObjectSchemaBuilder> createState() => _ObjectSchemaBuilderState();
}

class _ObjectSchemaBuilderState extends State<ObjectSchemaBuilder> {
  late SchemaObject _schemaObject;

  @override
  void initState() {
    super.initState();
    _schemaObject = widget.schemaObject;
  }

  @override
  Widget build(BuildContext context) {
    return ObjectSchemaInherited(
      schemaObject: _schemaObject,
      listen: (value) {
        if (value is ObjectSchemaDependencyEvent) {
          setState(() => _schemaObject = value.schemaObject);
        }
      },
      child: FormSection(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GeneralSubtitle(
              field: widget.schemaObject,
              mainSchema: widget.mainSchema,
            ),
            if (widget.schemaObject.properties != null)
              ...widget.schemaObject.properties!.map(
                (e) => FormFromSchemaBuilder(
                  schemaObject: widget.schemaObject,
                  mainSchema: widget.mainSchema,
                  schema: e,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
