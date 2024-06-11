import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/helpers/system_config.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/splash_screen_repository.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? splashScreenUrl;
  String? url;

  PackageInfo _packageInfo = PackageInfo(
    appName: AppConfig.app_name,
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }
  getSplashScreenData() async {
    var splashScreenResponse =
    await SplashScreenRepository().getSplashScreenResponse();

    splashScreenUrl = splashScreenResponse.splashScreen;
    url = splashScreenResponse.link;


    setState(() {});
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initPackageInfo();
    getSplashScreenData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: splashScreen());
  }

  Widget splashScreen() {
    return Container(
      width: DeviceInfo(context).height,
      height: DeviceInfo(context).height,
      color:  MyTheme.splash_screen_color,
      child:Builder(
          builder: (context) {
            if(splashScreenUrl!=null){
              return GestureDetector(
                onTap: (){
                  if(url!=null){
                  _launchUrl(url!);
                  }
                },
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/splash_login_registration_background_image.png',
                  image: splashScreenUrl??'',
                  fit: BoxFit.fill,
                  height: DeviceInfo(context).height,
                  width: DeviceInfo(context).width,
                ),
              );
            }else{
              return Container(
                alignment: Alignment.center,
                width: 60,
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.all(160.0),
                  child: Image.asset(
                    "assets/splash_screen_logo.png",
                    filterQuality: FilterQuality.low,
                  ),
                ),
              );
            }

          }
      ),
    );
  }
  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        universalLinksOnly: true,
      );
    } else {
      throw 'There was a problem to open the url: $url';
    }
  }

}
