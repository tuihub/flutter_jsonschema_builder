class OneOfModel {
  const OneOfModel({
    this.oneOfModelEnum,
    this.type,
    this.title,
  });

  final List<dynamic>? oneOfModelEnum;
  final String? type;
  final String? title;

  factory OneOfModel.fromJson(Map<String, dynamic> json) => OneOfModel(
        oneOfModelEnum: List<String>.from(json["enum"]),
        type: json["type"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "enum": List<dynamic>.from(oneOfModelEnum?.map((x) => x) ?? []),
        "type": type,
        "title": title,
      };
}
