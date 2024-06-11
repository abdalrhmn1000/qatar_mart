import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/presenter/home_presenter.dart';
import 'package:active_ecommerce_flutter/screens/category_products.dart';
import 'package:active_ecommerce_flutter/screens/change_language.dart';
import 'package:flutter/material.dart';

import 'package:active_ecommerce_flutter/screens/main.dart';
import 'package:active_ecommerce_flutter/screens/profile.dart';
import 'package:active_ecommerce_flutter/screens/order_list.dart';
import 'package:active_ecommerce_flutter/screens/wishlist.dart';

import 'package:active_ecommerce_flutter/screens/login.dart';
import 'package:active_ecommerce_flutter/screens/messenger_list.dart';
import 'package:active_ecommerce_flutter/screens/wallet.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/helpers/auth_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({
    Key? key,
  }) : super(key: key);

  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  HomePresenter homeData = HomePresenter()..fetchAll();

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) {
      // change();
    });
    // change();
    // TODO: implement initState
    super.initState();
  }

  change() {
    homeData.onRefresh();
    homeData.mainScrollListener();
    homeData.initPiratedAnimation(this);
  }

  onTapLogout(context) async {
    AuthHelper().clearUserData();

    // var logoutResponse = await AuthRepository().getLogoutResponse();
    //
    // if (logoutResponse.result == true) {
    //   ToastComponent.showDialog(logoutResponse.message, context,
    //       gravity: Toast.center, duration: Toast.lengthLong);
    //
    //   Navigator.push(context, MaterialPageRoute(builder: (context) {
    //     return Login();
    //   }));
    // }
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
      return Main();
    }), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Directionality(
        textDirection:
            app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          padding: EdgeInsets.only(top: 50),
          child: Column(
            children: <Widget>[
              is_logged_in.$ == true
                  ? ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          "${avatar_original.$}",
                        ),
                      ),
                      title: Text("${user_name.$}"),
                      subtitle: Text(
                        //if user email is not available then check user phone if user phone is not available use empty string
                        "${user_email.$ != "" && user_email.$ != null ? user_email.$ : user_phone.$ != "" && user_phone.$ != null ? user_phone.$ : ''}",
                      ))
                  : Text(AppLocalizations.of(context)!.not_logged_in_ucf,
                      style: TextStyle(
                          color: Color.fromRGBO(153, 153, 153, 1),
                          fontSize: 14)),
              Divider(),
              Row(
                children: [
                  SizedBox(width: 20,),
                  Text("Categories" , style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20 ),),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: ListenableBuilder(
                    child: buildHomeFeaturedCategories(context, homeData),
                    builder: (context, child) => buildHomeFeaturedCategories(context, homeData),
                    listenable: homeData,
                  ),
                ),
              ),
              Divider(),
              ListTile(
                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                  leading: Image.asset("assets/language.png",
                      height: 16, color: Color.fromRGBO(153, 153, 153, 1)),
                  title: Text(
                      AppLocalizations.of(context)!.change_language_ucf,
                      style: TextStyle(
                          color: Color.fromRGBO(153, 153, 153, 1),
                          fontSize: 14)),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ChangeLanguage();
                    }));
                  }),
              ListTile(
                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                  leading: Image.asset("assets/home.png",
                      height: 16, color: Color.fromRGBO(153, 153, 153, 1)),
                  title: Text(AppLocalizations.of(context)!.home_ucf,
                      style: TextStyle(
                          color: Color.fromRGBO(153, 153, 153, 1),
                          fontSize: 14)),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Main();
                    }));
                  }),
              is_logged_in.$ == true
                  ? Column(
                      children: [
                        ListTile(
                            visualDensity:
                                VisualDensity(horizontal: -4, vertical: -4),
                            leading: Image.asset("assets/profile.png",
                                height: 16,
                                color: Color.fromRGBO(153, 153, 153, 1)),
                            title: Text(
                                AppLocalizations.of(context)!.profile_ucf,
                                style: TextStyle(
                                    color: Color.fromRGBO(153, 153, 153, 1),
                                    fontSize: 14)),
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return Profile(show_back_button: true);
                              }));
                            }),
                        ListTile(
                            visualDensity:
                                VisualDensity(horizontal: -4, vertical: -4),
                            leading: Image.asset("assets/order.png",
                                height: 16,
                                color: Color.fromRGBO(153, 153, 153, 1)),
                            title: Text(
                                AppLocalizations.of(context)!.orders_ucf,
                                style: TextStyle(
                                    color: Color.fromRGBO(153, 153, 153, 1),
                                    fontSize: 14)),
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return OrderList(from_checkout: false);
                              }));
                            }),
                        ListTile(
                            visualDensity:
                                VisualDensity(horizontal: -4, vertical: -4),
                            leading: Image.asset("assets/heart.png",
                                height: 16,
                                color: Color.fromRGBO(153, 153, 153, 1)),
                            title: Text(
                                AppLocalizations.of(context)!.my_wishlist_ucf,
                                style: TextStyle(
                                    color: Color.fromRGBO(153, 153, 153, 1),
                                    fontSize: 14)),
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return Wishlist();
                              }));
                            }),
                        Visibility(
                          visible: conversation_system_status.$,
                          child: ListTile(
                              visualDensity:
                                  VisualDensity(horizontal: -4, vertical: -4),
                              leading: Image.asset("assets/chat.png",
                                  height: 16,
                                  color: Color.fromRGBO(153, 153, 153, 1)),
                              title: Text(
                                  AppLocalizations.of(context)!.messages_ucf,
                                  style: TextStyle(
                                      color: Color.fromRGBO(153, 153, 153, 1),
                                      fontSize: 14)),
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return MessengerList();
                                }));
                              }),
                        ),
                        wallet_system_status.$
                            ? ListTile(
                                visualDensity: VisualDensity(
                                    horizontal: -4, vertical: -4),
                                leading: Image.asset("assets/wallet.png",
                                    height: 16,
                                    color: Color.fromRGBO(153, 153, 153, 1)),
                                title: Text(
                                    AppLocalizations.of(context)!.wallet_ucf,
                                    style: TextStyle(
                                        color:
                                            Color.fromRGBO(153, 153, 153, 1),
                                        fontSize: 14)),
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return Wallet();
                                  }));
                                })
                            : Container(),
                      ],
                    )
                  : Container(),
              Divider(height: 24),
              is_logged_in.$ == false
                  ? ListTile(
                      visualDensity:
                          VisualDensity(horizontal: -4, vertical: -4),
                      leading: Image.asset("assets/login.png",
                          height: 16,
                          color: Color.fromRGBO(153, 153, 153, 1)),
                      title: Text(AppLocalizations.of(context)!.login_ucf,
                          style: TextStyle(
                              color: Color.fromRGBO(153, 153, 153, 1),
                              fontSize: 14)),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return Login();
                        }));
                      },
                    )
                  : Container(),
              is_logged_in.$ == true
                  ? ListTile(
                      visualDensity:
                          VisualDensity(horizontal: -4, vertical: -4),
                      leading: Image.asset("assets/logout.png",
                          height: 16,
                          color: Color.fromRGBO(153, 153, 153, 1)),
                      title: Text(AppLocalizations.of(context)!.logout_ucf,
                          style: TextStyle(
                              color: Color.fromRGBO(153, 153, 153, 1),
                              fontSize: 14)),
                      onTap: () {
                        onTapLogout(context);
                      })
                  : Container(),

              SizedBox(height: 80,),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHomeFeaturedCategories(context, HomePresenter homeData) {
    if (homeData.isFCategoryInitial &&
        homeData.categoryList.length == 0) {
      return ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context , index){
          return Container(
            height: 50,
            child: ShimmerHelper().buildBasicShimmer(),
          );
        },
        itemCount: 20,
        separatorBuilder: (context , index) => SizedBox(height: 10,),
      );
    } else if (homeData.categoryList.length > 0) {
      //snapshot.hasData
      return ListView.builder(
          padding:
              const EdgeInsets.only(left: 18, right: 18, top: 13, bottom: 20),
          // controller: homeData.featuredCategoryScrollController,
          itemCount: homeData.categoryList.length,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return CategoryProducts(
                    slug: homeData.categoryList[index].slug,
                  );
                }));
              },
              title: Text(
                homeData.categoryList[index].name,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                softWrap: true,
                // style: TextStyle(fontSize: 15, color: MyTheme.font_grey),
              ),
              trailing: Icon(Icons.keyboard_arrow_right_rounded),
            );
          });
    } else if (!homeData.isFCategoryInitial &&
        homeData.categoryList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.no_category_found,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }
}
