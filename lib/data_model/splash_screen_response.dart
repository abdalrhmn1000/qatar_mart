import 'dart:convert';

SplashScreenResponse splashScreenResponseFromJson(String str) => SplashScreenResponse.fromJson(json.decode(str));

String signupResponseToJson(SplashScreenResponse data) => json.encode(data.toJson());

class SplashScreenResponse {
  SplashScreenResponse({
    this.splashScreen,
    this.link,
  });

  String? splashScreen;
  String? link;

  factory SplashScreenResponse.fromJson(Map<String, dynamic> json) => SplashScreenResponse(
    splashScreen: json['data']["splash_screen"],
    link: json['data']["link"],
  );

  Map<String, dynamic> toJson() => {
    "splash_screen": splashScreen,
    "link": link,

  };
}