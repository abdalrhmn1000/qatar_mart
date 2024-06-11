import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/splash_screen_response.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';

class SplashScreenRepository {
  Future<SplashScreenResponse> getSplashScreenResponse() async {
    // $();
    String url = ('${AppConfig.BASE_URL}/splash-screen');
    final response = await ApiRequest.get(url: url);
    return splashScreenResponseFromJson(response.body);
  }
}
