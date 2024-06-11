import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/custom/aiz_image.dart';
import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/custom/useful_elements.dart';
import 'package:active_ecommerce_flutter/data_model/category_response.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/presenter/home_presenter.dart';
import 'package:active_ecommerce_flutter/repositories/category_repository.dart';
import 'package:active_ecommerce_flutter/repositories/product_repository.dart';
import 'package:active_ecommerce_flutter/ui_elements/product_card.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

class CategoryProducts extends StatefulWidget {
  CategoryProducts({Key? key, required this.slug}) : super(key: key);
  final String slug;

  @override
  _CategoryProductsState createState() => _CategoryProductsState();
}

class _CategoryProductsState extends State<CategoryProducts> {
  ScrollController _scrollController = ScrollController();
  ScrollController _xcrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();

  List<dynamic> _productList = [];
  List<Category> _subCategoryList = [];
  bool _isInitial = true;
  int _page = 1;
  String _searchKey = "";
  int? _totalData = 0;
  bool _showLoadingContainer = false;
  bool _showSearchBar = false;
  Category? categoryInfo;

  HomePresenter homeData = HomePresenter();

  change() {
    homeData.onRefresh();
    homeData.mainScrollListener();
    homeData.initPiratedAnimation(this);
  }

  getSubCategory() async {
    var res = await CategoryRepository().getCategories(parent_id: widget.slug);
    _subCategoryList.addAll(res.categories!);
    setState(() {});
  }

  getCategoryInfo() async {
    var res = await CategoryRepository().getCategoryInfo(widget.slug);
    print(res.categories.toString());
    if (res.categories?.isNotEmpty ?? false) {
      categoryInfo = res.categories?.first ?? null;
    }
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCategoryInfo();
    fetchAllDate();

    _xcrollController.addListener(() {
      //print("position: " + _xcrollController.position.pixels.toString());
      //print("max: " + _xcrollController.position.maxScrollExtent.toString());

      if (_xcrollController.position.pixels ==
          _xcrollController.position.maxScrollExtent) {
        setState(() {
          _page++;
        });
        _showLoadingContainer = true;
        fetchData();
      }
    });
    Future.delayed(Duration.zero).then((value) {
      change();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    _xcrollController.dispose();
    super.dispose();
  }

  fetchData() async {
    var productResponse = await ProductRepository()
        .getCategoryProducts(id: widget.slug, page: _page, name: _searchKey);
    _productList.addAll(productResponse.products!);
    _isInitial = false;
    _totalData = productResponse.meta!.total;
    _showLoadingContainer = false;
    setState(() {});
  }

  fetchAllDate() {
    fetchData();
    getSubCategory();
  }

  reset() {
    _subCategoryList.clear();
    _productList.clear();
    _isInitial = true;
    _totalData = 0;
    _page = 1;
    _showLoadingContainer = false;
    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    fetchAllDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      controller: homeData.mainScrollController,
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: <Widget>[
        SliverAppBar(
          automaticallyImplyLeading: false,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12))),
          backgroundColor: Color(0xff8a1538),
          // leading: const SizedBox.shrink(),
          // leadingWidth: 0,
          pinned: true,
          title: buildAppBarTitle(context),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [
                Image.asset(
                  "assets/background_1.png",
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  fit: BoxFit.cover,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildHomeCarouselSlider(context, homeData),
                      SizedBox(
                        height: 60,
                        child: buildSubCategory(),
                      )
                    ],
                  ),
                ),
              ],
            ),
            // background:
            titlePadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
          expandedHeight: 300,
          floating: true,
          // pinned: true,
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            buildProductList(),
            Align(
                alignment: Alignment.bottomCenter,
                child: buildLoadingContainer()),
            const SizedBox(height: 80,),
          ]),
        )
      ],
    ));
  }

  Container buildLoadingContainer() {
    return Container(
      height: _showLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalData == _productList.length
            ? AppLocalizations.of(context)!.no_more_products_ucf
            : AppLocalizations.of(context)!.loading_more_products_ucf),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: _subCategoryList.isEmpty
          ? DeviceInfo(context).height! / 10
          : DeviceInfo(context).height! / 6.5,
      flexibleSpace: Container(
        height: DeviceInfo(context).height! / 4,
        width: DeviceInfo(context).width,
        color: MyTheme.accent_color,
        alignment: Alignment.topRight,
        child: Image.asset(
          "assets/background_1.png",
        ),
      ),
      bottom: PreferredSize(
          child: AnimatedContainer(
              //color: MyTheme.textfield_grey,
              height: _subCategoryList.isEmpty ? 0 : 200,
              duration: Duration(milliseconds: 500),
              child: Column(
                children: [buildHomeCarouselSlider(context, homeData)],
              )),
          preferredSize: Size.fromHeight(0.0)),
      /*leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),*/
      title: buildAppBarTitle(context),
      elevation: 0.0,
      titleSpacing: 0,
      /*actions: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
          child: IconButton(
            icon: Icon(Icons.search, color: MyTheme.dark_grey),
            onPressed: () {
              _searchKey = _searchController.text.toString();
              reset();
              fetchData();
            },
          ),
        ),
      ],*/
    );
  }

  Widget buildAppBarTitle(BuildContext context) {
    return AnimatedCrossFade(
        firstChild: buildAppBarTitleOption(context),
        secondChild: buildAppBarSearchOption(context),
        firstCurve: Curves.fastOutSlowIn,
        secondCurve: Curves.fastOutSlowIn,
        crossFadeState: _showSearchBar
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        duration: Duration(milliseconds: 500));
  }

  Container buildAppBarTitleOption(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Container(
            width: 20,
            child: UsefulElements.backButton(context, color: "white"),
          ),
          Container(
            padding: EdgeInsets.only(left: 10),
            width: DeviceInfo(context).width! / 2,
            child: Text(
              categoryInfo?.name ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          Spacer(),
          SizedBox(
            width: 20,
            child: IconButton(
                onPressed: () {
                  _showSearchBar = true;
                  setState(() {});
                  print(_showSearchBar);
                },
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 25,
                )),
          ),
        ],
      ),
    );
  }

  Container buildAppBarSearchOption(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18),
      width: DeviceInfo(context).width,
      height: 40,
      child: TextField(
        controller: _searchController,
        onTap: () {},
        onChanged: (txt) {
          _searchKey = txt;
          reset();
          fetchData();
        },
        onSubmitted: (txt) {
          _searchKey = txt;
          reset();
          fetchData();
        },
        autofocus: false,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: () {
              _showSearchBar = false;
              setState(() {});
            },
            icon: Icon(
              Icons.clear,
              color: MyTheme.grey_153,
            ),
          ),
          filled: true,
          fillColor: MyTheme.white.withOpacity(0.6),
          hintText:
              "${AppLocalizations.of(context)!.search_products_from} : " + ""
          //widget.category_name!
          ,
          hintStyle: TextStyle(fontSize: 14.0, color: MyTheme.font_grey),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: MyTheme.noColor, width: 0.0),
              borderRadius: BorderRadius.circular(6)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: MyTheme.noColor, width: 0.0),
              borderRadius: BorderRadius.circular(6)),
          contentPadding: EdgeInsets.all(8.0),
        ),
      ),
    );
  }

  ListView buildSubCategory() {
    return ListView.separated(
        padding: EdgeInsets.only(left: 18, right: 18, bottom: 10),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return CategoryProducts(
                      slug: _subCategoryList[index].slug!,
                      // category_id: _subCategoryList[index].id,
                      // category_name: _subCategoryList[index].name,
                    );
                  },
                ),
              );
            },
            child: Container(
              height: _subCategoryList.isEmpty ? 0 : 46,
              width: _subCategoryList.isEmpty ? 0 : 96,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecorations.buildBoxDecoration_1(),
              child: Text(
                _subCategoryList[index].name!,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: MyTheme.font_grey),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(
            width: 10,
          );
        },
        itemCount: _subCategoryList.length);
  }

  buildProductList() {
    if (_isInitial && _productList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildProductGridShimmer(scontroller: _scrollController));
    } else if (_productList.length > 0) {
      return RefreshIndicator(
        color: MyTheme.accent_color,
        backgroundColor: Colors.white,
        displacement: 0,
        onRefresh: _onRefresh,
        child: MasonryGridView.count(
          controller: homeData.allProductScrollController,
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          itemCount: _productList.length,
          shrinkWrap: true,
          padding:
              EdgeInsets.only(top: 10.0, bottom: 10, left: 18, right: 18),
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            // 3
            return ProductCard(
                id: _productList[index].id,
                slug: _productList[index].slug,
                image: _productList[index].thumbnail_image,
                name: _productList[index].name,
                main_price: _productList[index].main_price,
                stroked_price: _productList[index].stroked_price,
                discount: _productList[index].discount,
                is_wholesale: _productList[index].isWholesale,
                has_discount: _productList[index].has_discount);
          },
        ),
      );
    } else if (_totalData == 0) {
      return Center(
          child: Text(AppLocalizations.of(context)!.no_data_is_available));
    } else {
      return Container(); // should never be happening
    }
  }

  Widget buildHomeCarouselSlider(context, HomePresenter homeData) {
    if (homeData.isBannerTwoInitial && homeData.bannerTwoImageList.length == 0) {
      return Padding(
        padding: const EdgeInsets.only(
          left: 18,
          right: 18,
          top: 0,
          bottom: 20,
        ),
        child: ShimmerHelper().buildBasicShimmer(
          height: 120,
        ),
      );
    } else if (homeData.bannerTwoImageList.length > 0) {
      return CarouselSlider(
        options: CarouselOptions(
          aspectRatio: 338 / 140,
          viewportFraction: 1,
          initialPage: 0,
          enableInfiniteScroll: true,
          reverse: false,
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 5),
          autoPlayAnimationDuration: Duration(milliseconds: 1000),
          autoPlayCurve: Curves.easeInExpo,
          enlargeCenterPage: false,
          scrollDirection: Axis.horizontal,
          onPageChanged: (index, reason) {
            homeData.incrementCurrentSlider(index);
          },
        ),
        items: homeData.bannerTwoImageList.map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.only(
                    left: 18, right: 18, top: 0, bottom: 20),
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 140,
                      child: InkWell(
                        onTap: () {
                          var url =
                              i.url?.split(AppConfig.DOMAIN_PATH).last ?? "";
                          print(url);
                          GoRouter.of(context).go(url);
                        },
                        child: AIZImage.radiusImage(i.photo, 6),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: homeData.bannerTwoImageList.map((url) {
                          int index = homeData.bannerTwoImageList.indexOf(url);
                          return Container(
                            width: 7.0,
                            height: 7.0,
                            margin: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: homeData.current_slider == index
                                  ? MyTheme.white
                                  : Color.fromRGBO(112, 112, 112, .3),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      );
    } else if (!homeData.isCarouselInitial &&
        homeData.bannerTwoImageList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.no_carousel_image_found,
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
