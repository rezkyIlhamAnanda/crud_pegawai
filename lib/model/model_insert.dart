// To parse this JSON data, do
//
//     final modelInsert = modelInsertFromJson(jsonString);

import 'dart:convert';

ModelInsert modelInsertFromJson(String str) => ModelInsert.fromJson(json.decode(str));

String modelInsertToJson(ModelInsert data) => json.encode(data.toJson());

class ModelInsert {
  int value;
  String message;

  ModelInsert({
    required this.value,
    required this.message,
  });

  factory ModelInsert.fromJson(Map<String, dynamic> json) => ModelInsert(
    value: json["value"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "value": value,
    "message": message,
  };
}