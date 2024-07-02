import 'dart:developer';

import '../models/models.dart';

class SchemaObject extends Schema {
  SchemaObject({
    required super.id,
    this.required = const [],
    this.dependencies,
    String? title,
    super.description,
    required super.nullable,
    super.requiredProperty,
    super.parentIdKey,
    super.dependentsAddedBy,
  }) : super(title: title ?? kNoTitle, type: SchemaType.object);

  factory SchemaObject.fromJson(
    String id,
    Map<String, dynamic> json, {
    Schema? parent,
  }) {
    final schema = SchemaObject(
      id: id,
      title: json['title'],
      description: json['description'],
      required:
          json["required"] != null ? List<String>.from(json["required"]) : [],
      nullable: SchemaType.isNullable(json['type']),
      dependencies: json['dependencies'],
      parentIdKey: parent?.idKey,
    );
    schema.dependentsAddedBy.addAll(parent?.dependentsAddedBy ?? []);

    if (json['properties'] != null) {
      schema.setProperties(json['properties'], schema);
    }
    if (json['oneOf'] != null) {
      schema.setOneOf(json['oneOf'], schema);
    }

    return schema;
  }

  void setUi(Map<String, dynamic> uiSchema) {
    uiSchema.forEach((key, data) {
      switch (key) {
        case "ui:order":
          order = List<String>.from(data);
          break;
        case "ui:title":
          title = data as String;
          break;
        case "ui:description":
          description = data as String;
          break;
        default:
          break;
      }
    });
  }

  @override
  SchemaObject copyWith({
    required String id,
    String? parentIdKey,
    List<String>? dependentsAddedBy,
  }) {
    final newSchema = SchemaObject(
      id: id,
      title: title,
      description: description,
      required: required,
      nullable: nullable,
      parentIdKey: parentIdKey ?? this.parentIdKey,
      dependentsAddedBy: dependentsAddedBy ?? this.dependentsAddedBy,
    )
      ..dependencies = dependencies
      ..oneOf = oneOf
      ..order = order;

    final otherProperties = properties!; //.map((p) => p.copyWith(id: p.id));

    newSchema.properties = otherProperties
        .map(
          (e) => e.copyWith(
            id: e.id,
            parentIdKey: newSchema.idKey,
            dependentsAddedBy: newSchema.dependentsAddedBy,
          ),
        )
        .toList();

    return newSchema;
  }

  // ! Getters
  bool get isGenesis => id == kGenesisIdKey;

  bool isOneOf = false;

  /// array of required keys
  List<String> required;
  List<Schema>? properties;
  List<String>? order;

  /// the dependencies keyword from an earlier draft of JSON Schema
  /// (note that this is not part of the latest JSON Schema spec, though).
  /// Dependencies can be used to create dynamic schemas that change fields based on what data is entered
  Map<String, dynamic>? dependencies;

  /// A [Schema] with [oneOf] is valid if exactly one of the subschemas is valid.
  List<Schema>? oneOf;

  void setUiSchema(Map<String, dynamic>? uiSchema) {
    if (uiSchema == null) return;
    if (properties != null && properties!.isEmpty) return;

    // set UI Schema to this ObjectSchema
    setUi(uiSchema);

    // set UI Schema to their properties
    properties?.forEach((_property) {
      if (_property is SchemaObject) {
        _property.setUi(uiSchema);
      } else if (_property is SchemaProperty) {
        _property.setUi(uiSchema);
      }
    });

    // order logic
    if (order != null) {
      properties!.sort((a, b) {
        return order!.indexOf(a.id) - order!.indexOf(b.id);
      });
    }
  }

  void setProperties(
    Map<String, dynamic>? properties,
    SchemaObject schema,
  ) {
    if (properties == null) return;
    final props = <Schema>[];

    properties.forEach((key, _property) {
      final isRequired = schema.required.contains(key);

      final property = Schema.fromJson(
        _property,
        id: key,
        parent: schema,
      );

      if (property is SchemaProperty) {
        property.requiredProperty = isRequired;
        // Asignamos las propiedades que dependen de este
        property.setDependents(schema);
      } else {
        property.requiredProperty = isRequired;
      }

      props.add(property);
    });

    this.properties = props;
  }

  void setOneOf(List<dynamic>? oneOf, SchemaObject schema) {
    if (oneOf == null) return;
    final oneOfs = <Schema>[];
    for (Map<String, dynamic> element in oneOf.cast()) {
      log(element.toString());
      oneOfs.add(Schema.fromJson(element, parent: schema));
    }

    this.oneOf = oneOfs;
  }
}
