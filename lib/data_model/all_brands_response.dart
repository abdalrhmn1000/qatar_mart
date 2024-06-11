// To parse this JSON data, do
//
//     final allBrandsResponse = allBrandsResponseFromJson(jsonString);

import 'dart:convert';

AllBrandsResponse allBrandsResponseFromJson(String str) =>
    AllBrandsResponse.fromJson(json.decode(str));

String allBrandsResponseToJson(AllBrandsResponse data) =>
    json.encode(data.toJson());

class AllBrandsResponse {
  List<Datum>? data;

  AllBrandsResponse({
    this.data,
  });

  factory AllBrandsResponse.fromJson(Map<String, dynamic> json) =>
      AllBrandsResponse(
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  int? id;
  String? name;
  String? icon;
  String? slug;

  Datum({
    this.id,
    this.name,
    this.icon,
    this.slug,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        name: json["name"],
        icon: json["icon"],
        slug: json["slug"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "icon": icon,
        "slug": slug,
      };
}
