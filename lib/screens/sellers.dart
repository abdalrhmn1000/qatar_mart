import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/helpers/reg_ex_inpur_formatter.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/brand_repository.dart';
import 'package:active_ecommerce_flutter/repositories/category_repository.dart';
import 'package:active_ecommerce_flutter/repositories/product_repository.dart';
import 'package:active_ecommerce_flutter/repositories/shop_repository.dart';
import 'package:active_ecommerce_flutter/ui_elements/brand_square_card.dart';
import 'package:active_ecommerce_flutter/ui_elements/seller_card.dart';
import 'package:active_ecommerce_flutter/ui_elements/shop_square_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:one_context/one_context.dart';
import 'package:toast/toast.dart';

class WhichFilter {
  String option_key;
  String name;

  WhichFilter(this.option_key, this.name);

  static List<WhichFilter> getWhichFilterList() {
    return <WhichFilter>[
      WhichFilter(
          'product', AppLocalizations.of(OneContext().context!)!.product_ucf),
      WhichFilter(
          'sellers', AppLocalizations.of(OneContext().context!)!.sellers_ucf),
      WhichFilter(
          'brands', AppLocalizations.of(OneContext().context!)!.brands_ucf),
    ];
  }
}

class Sellers extends StatefulWidget {
  Sellers({
    Key? key,
  }) : super(key: key);

  @override
  _SellersState createState() => _SellersState();
}

class _SellersState extends State<Sellers> {
  final _amountValidator = RegExInputFormatter.withRegex(
      '^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$');

  ScrollController _productScrollController = ScrollController();
  ScrollController _brandScrollController = ScrollController();
  ScrollController _shopScrollController = ScrollController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  ScrollController? _scrollController;
  WhichFilter? _selectedFilter;
  String? _givenSelectedFilterOptionKey; // may be it can come from another page
  String? _selectedSort = "";

  List<WhichFilter> _which_filter_list = WhichFilter.getWhichFilterList();
  List<DropdownMenuItem<WhichFilter>>? _dropdownWhichFilterItems;
  List<dynamic> _selectedCategories = [];
  List<dynamic> _selectedBrands = [];

  final TextEditingController _searchController = new TextEditingController();
  final TextEditingController _minPriceController = new TextEditingController();
  final TextEditingController _maxPriceController = new TextEditingController();

  //--------------------
  List<dynamic> _filterBrandList = [];
  bool _filteredBrandsCalled = false;
  List<dynamic> _filterCategoryList = [];
  bool _filteredCategoriesCalled = false;

  List<dynamic> _searchSuggestionList = [];

  //----------------------------------------
  String? _searchKey = "";

  List<dynamic> _productList = [];
  bool _isProductInitial = true;
  int _productPage = 1;
  int? _totalProductData = 0;
  bool _showProductLoadingContainer = false;

  List<dynamic> _brandList = [];
  bool _isBrandInitial = true;
  int _brandPage = 1;
  int? _totalBrandData = 0;
  bool _showBrandLoadingContainer = false;

  List<dynamic> _shopList = [];
  bool _isShopInitial = true;
  int _shopPage = 1;
  int? _totalShopData = 0;
  bool _showShopLoadingContainer = false;

  //----------------------------------------

  fetchFilteredBrands() async {
    var filteredBrandResponse = await BrandRepository().getFilterPageBrands();
    _filterBrandList.addAll(filteredBrandResponse.brands!);
    _filteredBrandsCalled = true;
    setState(() {});
  }

  fetchFilteredCategories() async {
    var filteredCategoriesResponse =
        await CategoryRepository().getFilterPageCategories();
    _filterCategoryList.addAll(filteredCategoriesResponse.categories!);
    _filteredCategoriesCalled = true;
    setState(() {});
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _productScrollController.dispose();
    _brandScrollController.dispose();
    _shopScrollController.dispose();
    super.dispose();
  }

  init() {
    _givenSelectedFilterOptionKey = 'sellers';

    _dropdownWhichFilterItems =
        buildDropdownWhichFilterItems(_which_filter_list);
    _selectedFilter = _dropdownWhichFilterItems![0].value;

    for (int x = 0; x < _dropdownWhichFilterItems!.length; x++) {
      if (_dropdownWhichFilterItems![x].value!.option_key ==
          _givenSelectedFilterOptionKey) {
        _selectedFilter = _dropdownWhichFilterItems![x].value;
      }
    }

    fetchFilteredCategories();
    fetchFilteredBrands();

    if (_selectedFilter!.option_key == "sellers") {
      fetchShopData();
    } else if (_selectedFilter!.option_key == "brands") {
      fetchBrandData();
    } else {
      fetchProductData();
    }

    //set scroll listeners

    _productScrollController.addListener(() {
      if (_productScrollController.position.pixels ==
          _productScrollController.position.maxScrollExtent) {
        setState(() {
          _productPage++;
        });
        _showProductLoadingContainer = true;
        fetchProductData();
      }
    });

    _brandScrollController.addListener(() {
      if (_brandScrollController.position.pixels ==
          _brandScrollController.position.maxScrollExtent) {
        setState(() {
          _brandPage++;
        });
        _showBrandLoadingContainer = true;
        fetchBrandData();
      }
    });

    _shopScrollController.addListener(() {
      if (_shopScrollController.position.pixels ==
          _shopScrollController.position.maxScrollExtent) {
        setState(() {
          _shopPage++;
        });
        _showShopLoadingContainer = true;
        fetchShopData();
      }
    });
  }

  fetchProductData() async {
    //print("sc:"+_selectedCategories.join(",").toString());
    //print("sb:"+_selectedBrands.join(",").toString());
    var productResponse = await ProductRepository().getFilteredProducts(
        page: _productPage,
        name: _searchKey,
        sort_key: _selectedSort,
        brands: _selectedBrands.join(",").toString(),
        categories: _selectedCategories.join(",").toString(),
        max: _maxPriceController.text.toString(),
        min: _minPriceController.text.toString());

    _productList.addAll(productResponse.products!);
    _isProductInitial = false;
    _totalProductData = productResponse.meta!.total;
    _showProductLoadingContainer = false;
    setState(() {});
  }

  resetProductList() {
    _productList.clear();
    _isProductInitial = true;
    _totalProductData = 0;
    _productPage = 1;
    _showProductLoadingContainer = false;
    setState(() {});
  }

  fetchBrandData() async {
    var brandResponse =
        await BrandRepository().getBrands(page: _brandPage, name: _searchKey);
    _brandList.addAll(brandResponse.brands!);
    _isBrandInitial = false;
    _totalBrandData = brandResponse.meta!.total;
    _showBrandLoadingContainer = false;
    setState(() {});
  }

  resetBrandList() {
    _brandList.clear();
    _isBrandInitial = true;
    _totalBrandData = 0;
    _brandPage = 1;
    _showBrandLoadingContainer = false;
    setState(() {});
  }

  fetchShopData() async {
    var shopResponse =
        await ShopRepository().getShops(page: _shopPage, name: _searchKey);
    _shopList.addAll(shopResponse.shops);
    _isShopInitial = false;
    _totalShopData = shopResponse.meta.total;
    _showShopLoadingContainer = false;
    //print("_shopPage:" + _shopPage.toString());
    //print("_totalShopData:" + _totalShopData.toString());
    setState(() {});
  }

  reset() {
    _searchSuggestionList.clear();
    setState(() {});
  }

  resetShopList() {
    _shopList.clear();
    _isShopInitial = true;
    _totalShopData = 0;
    _shopPage = 1;
    _showShopLoadingContainer = false;
    setState(() {});
  }

  Future<void> _onBrandListRefresh() async {
    reset();
    resetBrandList();
    fetchBrandData();
  }

  Future<void> _onShopListRefresh() async {
    reset();
    resetShopList();
    fetchShopData();
  }

  _onWhichFilterChange() {
    if (_selectedFilter!.option_key == "sellers") {
      resetShopList();
      fetchShopData();
    } else if (_selectedFilter!.option_key == "brands") {
      resetBrandList();
      fetchBrandData();
    } else {
      resetProductList();
      fetchProductData();
    }
  }

  List<DropdownMenuItem<WhichFilter>> buildDropdownWhichFilterItems(
      List whichFilterList) {
    List<DropdownMenuItem<WhichFilter>> items = [];
    for (WhichFilter which_filter_item
        in whichFilterList as Iterable<WhichFilter>) {
      items.add(
        DropdownMenuItem(
          value: which_filter_item,
          child: Text(which_filter_item.name),
        ),
      );
    }
    return items;
  }

  //--------------------

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Sellers',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: buildShopList(),
      ),
    );
  }

  Row buildBottomAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.symmetric(
                  vertical: BorderSide(color: MyTheme.light_grey, width: .5),
                  horizontal: BorderSide(color: MyTheme.light_grey, width: 1))),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          height: 36,
          width: MediaQuery.of(context).size.width * .33,
          child: new DropdownButton<WhichFilter>(
            icon: Padding(
              padding: app_language_rtl.$!
                  ? const EdgeInsets.only(right: 18.0)
                  : const EdgeInsets.only(left: 18.0),
              child: Icon(Icons.expand_more, color: Colors.black54),
            ),
            hint: Text(
              AppLocalizations.of(context)!.products_ucf,
              style: TextStyle(
                color: Colors.black,
                fontSize: 13,
              ),
            ),
            style: TextStyle(color: Colors.black, fontSize: 13),
            iconSize: 13,
            underline: SizedBox(),
            value: _selectedFilter,
            items: _dropdownWhichFilterItems,
            onChanged: (WhichFilter? selectedFilter) {
              setState(() {
                _selectedFilter = selectedFilter;
              });

              _onWhichFilterChange();
            },
          ),
        ),
        GestureDetector(
          onTap: () {
            _selectedFilter!.option_key == "product"
                ? _scaffoldKey.currentState!.openEndDrawer()
                : ToastComponent.showDialog(
                    AppLocalizations.of(context)!
                        .you_can_use_sorting_while_searching_for_products,
                    gravity: Toast.center,
                    duration: Toast.lengthLong);
          },
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.symmetric(
                    vertical: BorderSide(color: MyTheme.light_grey, width: .5),
                    horizontal:
                        BorderSide(color: MyTheme.light_grey, width: 1))),
            height: 36,
            width: MediaQuery.of(context).size.width * .33,
            child: Center(
                child: Container(
              width: 50,
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt_outlined,
                    size: 13,
                  ),
                  SizedBox(width: 2),
                  Text(
                    AppLocalizations.of(context)!.filter_ucf,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )),
          ),
        ),
      ],
    );
  }




  Container buildShopList() {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: buildShopScrollableList(),
          )
        ],
      ),
    );
  }

  buildShopScrollableList() {
    if (_isShopInitial && _shopList.length == 0) {
      return SingleChildScrollView(
          controller: _scrollController,
          child: ShimmerHelper()
              .buildListShimmer(item_count: 10),);
    } else if (_shopList.length > 0) {
      return RefreshIndicator(
        color: Colors.white,
        backgroundColor: MyTheme.accent_color,
        onRefresh: _onShopListRefresh,
        child: SingleChildScrollView(
          controller: _shopScrollController,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          child: Column(
            children: [
              ListView.builder(
                // 2
                //addAutomaticKeepAlives: true,
                itemCount: _shopList.length,
                controller: _scrollController,
                padding:
                    EdgeInsets.only(top: 20, bottom: 10, left: 18, right: 18),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  // 3
                  return SellerCard(
                    id: _shopList[index].id,
                    shopSlug: _shopList[index].slug,
                    image: _shopList[index].logo,
                    name: _shopList[index].name,
                    stars: double.parse(_shopList[index].rating.toString()),
                  );
                },
              ),
              const SizedBox(height: 80,),
            ],
          ),
        ),
      );
    } else if (_totalShopData == 0) {
      return Center(
          child: Text(AppLocalizations.of(context)!.no_shop_is_available));
    } else {
      return Container(); // should never be happening
    }
  }
}
