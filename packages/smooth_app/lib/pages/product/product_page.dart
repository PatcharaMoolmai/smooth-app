// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/database/database_helper.dart';
import 'package:smooth_app/functions/user_product_process.dart';
import 'package:smooth_app/pages/product/alert_dialog/product_alert_dialog_25p.dart';
import 'package:smooth_app/pages/product/alert_dialog/product_alert_dialog_50p.dart';
import 'package:smooth_app/pages/product/alert_dialog/product_alert_dialog_75p.dart';
import 'package:smooth_app/pages/product/alert_dialog/product_alert_dialog_full.dart';
import 'package:smooth_app/temp/available_attribute_groups.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_ui_library/widgets/smooth_card.dart';
import 'package:smooth_app/temp/product_extra.dart';

// Project imports:
import 'package:smooth_app/bottom_sheet_views/user_preferences_view.dart';
import 'package:smooth_app/cards/data_cards/image_upload_card.dart';
import 'package:smooth_app/cards/expandables/attribute_list_expandable.dart';
import 'package:smooth_app/temp/attribute_extra.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/category_product_query.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/functions/launchURL.dart';
import 'package:smooth_app/pages/product/common/product_dialog_helper.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_ui_library/widgets/smooth_expandable_card.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({@required this.product, this.newProduct = false});

  final bool newProduct;
  final Product product;

  @override
  _ProductPageState createState() => _ProductPageState();

  static Future<void> showLists(
    final Product product,
    final BuildContext context,
  ) async {
    final String barcode = product.barcode;
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final List<ProductList> list =
        await daoProductList.getAll(withStats: false);
    final List<ProductList> listWithBarcode =
        await daoProductList.getAllWithBarcode(barcode);
    int index = 0;
    final Set<int> already = <int>{};
    final Set<int> editable = <int>{};
    final Set<int> addable = <int>{};
    for (final ProductList productList in list) {
      switch (productList.listType) {
        case ProductList.LIST_TYPE_HISTORY:
        case ProductList.LIST_TYPE_USER_DEFINED:
        case ProductList.LIST_TYPE_SCAN:
          editable.add(index);
      }
      switch (productList.listType) {
        case ProductList.LIST_TYPE_USER_DEFINED:
          addable.add(index);
      }
      for (final ProductList withBarcode in listWithBarcode) {
        if (productList.lousyKey == withBarcode.lousyKey) {
          already.add(index);
          break;
        }
      }
      index++;
    }
    showCupertinoModalBottomSheet<Widget>(
      expand: false,
      context: context,
      backgroundColor: Colors.transparent,
      bounce: true,
      barrierColor: Colors.black45,
      builder: (BuildContext context) => Material(
        child: ListView.builder(
          itemCount: list.length + 1,
          itemBuilder: (final BuildContext context, int index) {
            if (index == 0) {
              return ListTile(
                onTap: () {
                  Navigator.pop(context);
                },
                title: Text(product.productName),
                leading: const Icon(Icons.close),
              );
            }
            index--;
            final ProductList productList = list[index];
            return StatefulBuilder(
              builder:
                  (final BuildContext context, final StateSetter setState) {
                Function onPressed;
                IconData iconData;
                if (already.contains(index)) {
                  if (!editable.contains(index)) {
                    iconData = Icons.check;
                  } else {
                    iconData = Icons.check_box_outlined;
                    onPressed = () async {
                      already.remove(index);
                      daoProductList.removeBarcode(productList, barcode);
                      localDatabase.notifyListeners();
                      setState(() {});
                    };
                  }
                } else {
                  if (!addable.contains(index)) {
                    iconData = null;
                  } else if (!editable.contains(index)) {
                    iconData = null;
                  } else {
                    iconData = Icons.check_box_outline_blank_outlined;
                    onPressed = () async {
                      already.add(index);
                      daoProductList.addBarcode(productList, barcode);
                      localDatabase.notifyListeners();
                      setState(() {});
                    };
                  }
                }
                return Card(
                  child: ListTile(
                    title: Text(
                      ProductQueryPageHelper.getProductListLabel(productList),
                    ),
                    trailing: iconData == null
                        ? null
                        : IconButton(
                            icon: Icon(iconData),
                            onPressed: () {
                              onPressed();
                            },
                          ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ProductPageState extends State<ProductPage> {
  Product _product;

  final EdgeInsets padding =
      const EdgeInsets.only(right: 8.0, left: 8.0, top: 4.0, bottom: 20.0);
  final EdgeInsets insets = const EdgeInsets.all(12.0);

  @override
  void initState() {
    super.initState();
    _updateHistory(context);
  }

  static const List<String> _ORDERED_ATTRIBUTE_GROUP_IDS = <String>[
    AvailableAttributeGroups.ATTRIBUTE_GROUP_INGREDIENT_ANALYSIS,
    AvailableAttributeGroups.ATTRIBUTE_GROUP_NUTRITIONAL_QUALITY,
    AvailableAttributeGroups.ATTRIBUTE_GROUP_PROCESSING,
    AvailableAttributeGroups.ATTRIBUTE_GROUP_ENVIRONMENT,
    AvailableAttributeGroups.ATTRIBUTE_GROUP_LABELS,
    AvailableAttributeGroups.ATTRIBUTE_GROUP_ALLERGENS,
  ];

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final DatabaseHelper databaseHelper = context.watch<DatabaseHelper>();
    final ThemeData themeData = Theme.of(context);
    _product ??= widget.product;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            _product.productName ?? appLocalizations.unknownProductName,
            //style: themeData.textTheme.headline4,
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.fastfood_rounded,
                color: themeData.bottomNavigationBarTheme.selectedItemColor,
              ),
              label: 'Eat',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.playlist_add),
              label: 'Product lists',
            ),
            // const BottomNavigationBarItem(
            //   icon: Icon(Icons.launch),
            //   label: 'openfoodfact.org',
            // ),
            // const BottomNavigationBarItem(
            //   icon: Icon(Icons.refresh),
            //   label: 'refresh',
            // ),
            // BottomNavigationBarItem(
            //   icon: Icon(ConstantIcons.getShareIcon()),
            //   label: 'share',
            // ),
          ],
          onTap: (final int index) async {
            switch (index) {
              case 0:
                // UserPreferencesView.showModal(context);
                // UserProductProcess().productToEat(_product);
                await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) => SmoothAlertDialog(
                    close: false,
                    body:
                        const Text('How much would you like to eat this food?'),
                    actions: <SmoothSimpleButton>[
                      // SmoothSimpleButton(
                      //   text: AppLocalizations.of(context).no,
                      //   important: false,
                      //   onPressed: () => Navigator.pop(context, false),
                      // ),
                      SmoothSimpleButton(
                        text: '25%',
                        important: true,
                        onPressed: () async {
                          // UserProductProcess().productToEat(_product);
                          // Navigator.pop(context, true);
                          eatSummary25p();
                        },
                      ),
                      SmoothSimpleButton(
                        text: '50%',
                        important: true,
                        onPressed: () async {
                          // UserProductProcess().productToEat(_product);
                          // Navigator.pop(context, true);
                          eatSummary50p();
                        },
                      ),
                      SmoothSimpleButton(
                        text: '75%',
                        important: true,
                        onPressed: () async {
                          // UserProductProcess().productToEat(_product);
                          // Navigator.pop(context, true);
                          eatSummary75p();
                        },
                      ),
                      SmoothSimpleButton(
                        text: 'Full',
                        important: true,
                        onPressed: () async {
                          // UserProductProcess().productToEat(_product);
                          // Navigator.pop(context, true);
                          eatSummaryfull();
                        },
                      ),
                    ],
                  ),
                );

                // Navigator.pop(context);

                // databaseHelper.notifyListeners();
                return;
              case 1:
                ProductPage.showLists(_product, context);
                return;
              // case 2:
              //   Launcher().launchURL(
              //       context,
              //       'https://openfoodfacts.org/product/${_product.barcode}/',
              //       false);
              //   return;
              // case 3:
              //   final ProductDialogHelper productDialogHelper =
              //       ProductDialogHelper(
              //     barcode: _product.barcode,
              //     context: context,
              //     localDatabase: localDatabase,
              //     refresh: true,
              //   );
              //   final Product product =
              //       await productDialogHelper.openUniqueProductSearch();
              //   if (product == null) {
              //     productDialogHelper.openProductNotFoundDialog();
              //     return;
              //   }
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     const SnackBar(
              //       content: Text('Product refreshed'),
              //       duration: Duration(seconds: 2),
              //     ),
              //   );
              //   setState(() {
              //     _product = product;
              //   });
              //   return;
              // case 4:
              //   Share.share(
              //     'Try this food: https://openfoodfacts.org/product/${_product.barcode}/',
              //     subject: '${_product.productName} (by openfoodfacts.org)',
              //   );
              //   return;
            }
            throw 'Unexpected index $index';
          },
        ),
        body: widget.newProduct
            ? _buildNewProductBody(context)
            : _buildProductBody(context));
  }

  Future<void> _updateHistory(final BuildContext context) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final ProductList productList =
        ProductList(listType: ProductList.LIST_TYPE_HISTORY, parameters: '');
    await daoProductList.get(productList);
    productList.add(_product);
    await daoProductList.put(productList);
    localDatabase.notifyListeners();
  }

// Photo Zone
  Widget _buildProductImagesCarousel(BuildContext context) {
    final List<ImageUploadCard> carouselItems = <ImageUploadCard>[
      ImageUploadCard(
          product: _product,
          imageField: ImageField.FRONT,
          imageUrl: _product.imageFrontUrl,
          title: 'Product',
          buttonText: 'Front photo'),
      ImageUploadCard(
          product: _product,
          imageField: ImageField.INGREDIENTS,
          imageUrl: _product.imageIngredientsUrl,
          title: 'Ingredients',
          buttonText: 'Ingredients photo'),
      ImageUploadCard(
        product: _product,
        imageField: ImageField.NUTRITION,
        imageUrl: _product.imageNutritionUrl,
        title: 'Nutrition',
        buttonText: 'Nutrition facts photo',
      ),
      ImageUploadCard(
        product: _product,
        imageField: ImageField.PACKAGING,
        imageUrl: _product.imagePackagingUrl,
        title: 'Packaging information',
        buttonText: 'Packaging information photo',
      ),
      ImageUploadCard(
        product: _product,
        imageField: ImageField.OTHER,
        imageUrl: null,
        title: 'More photos',
        buttonText: 'More photos',
      ),
    ];

    return Container(
      height: 200,
      child: ListView(
        // This next line does the trick.
        scrollDirection: Axis.horizontal,
        children: carouselItems
            .map(
              (ImageUploadCard item) => Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                decoration: const BoxDecoration(color: Colors.black12),
                child: item,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildNewProductBody(BuildContext context) {
    return ListView(children: <Widget>[
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        margin: const EdgeInsets.only(top: 20.0),
        child: Text(
          'Add a new product',
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
      ImageUploadCard(
          product: _product,
          imageField: ImageField.FRONT,
          buttonText: 'Front photo'),
      ImageUploadCard(
          product: _product,
          imageField: ImageField.INGREDIENTS,
          buttonText: 'Ingredients photo'),
      ImageUploadCard(
        product: _product,
        imageField: ImageField.NUTRITION,
        buttonText: 'Nutrition facts photo',
      ),
      ImageUploadCard(
          product: _product,
          imageField: ImageField.OTHER,
          buttonText: 'More interesting photos'),
    ]);
  }

  Widget _buildProductBody(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Size screenSize = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);
    final double iconWidth =
        screenSize.width / 10; // TODO(monsieurtanuki): target size?
    final Map<String, String> attributeGroupLabels = <String, String>{};
    for (final AttributeGroup attributeGroup
        in productPreferences.attributeGroups) {
      attributeGroupLabels[attributeGroup.id] = attributeGroup.name;
    }
    final List<String> attributeIds =
        productPreferences.getOrderedImportantAttributeIds();
    final List<Widget> listItems = <Widget>[];

    listItems.add(_buildProductImagesCarousel(context));

    // Brands, quantity
    listItems.add(
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Text(
                _product.brands ?? appLocalizations.unknownBrand,
                style: themeData.textTheme.subtitle1,
              ),
            ),
            Flexible(
              child: Text(
                _product.quantity != null ? '${_product.quantity}' : '',
                style: themeData.textTheme.headline4
                    .copyWith(color: Colors.grey, fontSize: 13.0),
              ),
            ),
          ],
        ),
      ),
    );

    // Controlled nutrient
    final Map<String, Attribute> attributes =
        ProductExtra.getAttributes(_product, attributeIds);
    final double opacity = themeData.brightness == Brightness.light
        ? 1
        : SmoothTheme.ADDITIONAL_OPACITY_FOR_DARK;

    for (final String attributeId in attributeIds) {
      if (attributes[attributeId] != null) {
        listItems.add(
          AttributeListExpandable(
            padding: padding,
            insets: insets,
            product: _product,
            iconWidth: iconWidth,
            attributeIds: <String>[attributeId],
            collapsible: false,
            background: _getBackgroundColor(attributes[attributeId])
                .withOpacity(opacity),
          ),
        );
      }
    }
    // Product Nutriment
    listItems.add(attributeProductEN());

    // Group Atiribute
    // for (final AttributeGroup attributeGroup
    //     in _getOrderedAttributeGroups(productPreferences)) {
    //   listItems.add(_getAttributeGroupWidget(attributeGroup, iconWidth));
    // }

    //Similar foods
    // if (_product.categoriesTags != null && _product.categoriesTags.isNotEmpty) {
    //   for (int i = _product.categoriesTags.length - 1;
    //       i < _product.categoriesTags.length;
    //       i++) {
    //     final String categoryTag = _product.categoriesTags[i];
    //     const MaterialColor materialColor = Colors.blue;
    //     listItems.add(
    //       SmoothCard(
    //         padding: padding,
    //         insets: insets,
    //         color: SmoothTheme.getColor(
    //           themeData.colorScheme,
    //           materialColor,
    //           ColorDestination.SURFACE_BACKGROUND,
    //         ),
    //         child: ListTile(
    //           leading: Icon(
    //             Icons.search,
    //             size: iconWidth,
    //             color: SmoothTheme.getColor(
    //               themeData.colorScheme,
    //               materialColor,
    //               ColorDestination.SURFACE_FOREGROUND,
    //             ),
    //           ),
    //           onTap: () async => await ProductQueryPageHelper().openBestChoice(
    //             color: materialColor,
    //             heroTag: 'search_bar',
    //             name: categoryTag,
    //             localDatabase: localDatabase,
    //             productQuery: CategoryProductQuery(
    //               category: categoryTag,
    //               languageCode: ProductQuery.getCurrentLanguageCode(context),
    //               countryCode: ProductQuery.getCurrentCountryCode(),
    //               size: 500,
    //             ),
    //             context: context,
    //           ),
    //           title: Text(
    //             categoryTag,
    //             style: themeData.textTheme.headline3,
    //           ),
    //           subtitle: Text(
    //             'Similar foods',
    //             style: themeData.textTheme.subtitle2,
    //           ),
    //         ),
    //       ),
    //     );
    //   }
    // }

    return ListView(children: listItems);
  }

  Widget attributeProductEN() {
    return Column(children: <Widget>[attributeEnergy(), attributeNutrition()]);
  }

  Widget attributeEnergy() {
    return Padding(
        padding: const EdgeInsets.all(1.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SmoothCard(
                color: Colors.teal[50],
                child: Column(children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                              const SizedBox(
                                height: 8,
                              ),
                              const Text(' Product Energy'),
                              const SizedBox(
                                height: 8,
                              ),
                            ])),
                        Flexible(
                            child:
                                Text('${_product.nutriments.energyKcal} Kcal'))
                      ]),
                ]))
          ],
        ));
  }

  Widget attributeNutrition() {
    return Padding(
        padding: const EdgeInsets.all(1.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SmoothCard(
                // color: Colors.cyan[700],
                child: Column(children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            ' Nutrition',
                            // style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                        ])),
                  ]),
              SmoothCard(
                color: Colors.pink[50],
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                                ' Protein : ${_product.nutriments.proteinsServing} g'),
                            const SizedBox(
                              height: 8,
                            ),
                          ])),
                      Flexible(
                          child: Text(
                              '${(_product.nutriments.proteinsServing) * 4} Kcal'))
                    ]),
              ),
              SmoothCard(
                color: Colors.lightGreen[100],
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                                ' Carbohydrate : ${_product.nutriments.carbohydratesServing} g'),
                            SizedBox(
                              height: 8,
                            ),
                          ])),
                      Flexible(
                          child: Text(
                              '${(_product.nutriments.carbohydratesServing) * 4} Kcal'))
                    ]),
              ),
              attributeFatData(),
              SmoothCard(
                  color: Colors.lime[50],
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                              const Text(' Sodium : '),
                              const SizedBox(
                                height: 8,
                              ),
                            ])),
                        Flexible(
                            child: Text(
                                '${(_product.nutriments.sodiumServing) * 1000} mg'))
                      ])),
            ]))
          ],
        ));
  }

  Widget attributeFatData() {
    return SmoothExpandableCard(
        collapsedHeader: Text(
            'Fat : ${_product.nutriments.fatServing} g (${(_product.nutriments.fatServing) * 9} Kcal)'),
        color: Colors.amber[100],
        child: Column(children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                      Text(
                          'Satured : ${_product.nutriments.saturatedFatServing} g'),
                      SizedBox(
                        height: 8,
                      ),
                    ])),
                Flexible(
                    child: Text(
                        '${((_product.nutriments.fatServing) - (_product.nutriments.saturatedFatServing)) * 9} Kcal'))
              ]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
              Widget>[
            Flexible(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  Text(
                      'Unsatured Fat : ${(_product.nutriments.fatServing) - (_product.nutriments.saturatedFatServing)} g Kcal'),
                ])),
            Flexible(
                child: Text('${(_product.nutriments.saturatedFatServing) * 9}'))
          ]),
        ]));
  }

  Future<bool> eatSummary25p() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        close: false,
        body:
            // const Text('25% to eat?\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na'),
            // Text(_product.barcode),
            AlertDialog25p(_product),
            // AlertDialog25p(),
        actions: <SmoothSimpleButton>[
          SmoothSimpleButton(
            text: AppLocalizations.of(context).no,
            important: false,
            onPressed: () => Navigator.pop(context, false),
          ),
          SmoothSimpleButton(
            text: AppLocalizations.of(context).yes,
            important: true,
            onPressed: () async {
              UserProductProcess().productToEat1of4(_product);
              Navigator.pop(context, true);
              Navigator.pop(context);
              Navigator.pop(context);
              super.widget;
            },
          )
        ],
      ),
    );
  }

  Future<bool> eatSummary50p() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        close: false,
        body: 
        // const Text('50% to eat?'),
        AlertDialog50p(_product),
        actions: <SmoothSimpleButton>[
          SmoothSimpleButton(
            text: AppLocalizations.of(context).no,
            important: false,
            onPressed: () => Navigator.pop(context, false),
          ),
          SmoothSimpleButton(
            text: AppLocalizations.of(context).yes,
            important: true,
            onPressed: () async {
              UserProductProcess().productToEat1of2(_product);
              Navigator.pop(context, true);
              Navigator.pop(context);
              Navigator.pop(context);
              super.widget;
            },
          )
        ],
      ),
    );
  }

  Future<bool> eatSummary75p() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        close: false,
        body: 
        // const Text('75% to eat?'),
        AlertDialog75p(_product),
        actions: <SmoothSimpleButton>[
          SmoothSimpleButton(
            text: AppLocalizations.of(context).no,
            important: false,
            onPressed: () => Navigator.pop(context, false),
          ),
          SmoothSimpleButton(
            text: AppLocalizations.of(context).yes,
            important: true,
            onPressed: () async {
              UserProductProcess().productToEat3of4(_product);
              Navigator.pop(context, true);
              Navigator.pop(context);
              Navigator.pop(context);
              super.widget;
            },
          )
        ],
      ),
    );
  }

  Future<bool> eatSummaryfull() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        close: false,
        body: 
        // const Text('Full of product?'),
        AlertDialogFull(_product),
        actions: <SmoothSimpleButton>[
          SmoothSimpleButton(
            text: AppLocalizations.of(context).no,
            important: false,
            onPressed: () => Navigator.pop(context, false),
          ),
          SmoothSimpleButton(
            text: AppLocalizations.of(context).yes,
            important: true,
            onPressed: () async {
              UserProductProcess().productToEat(_product);
              Navigator.pop(context, true);
              Navigator.pop(context);
              Navigator.pop(context);
              super.widget;
            },
          )
        ],
      ),
    );
  }

  Widget _getAttributeGroupWidget(
    final AttributeGroup attributeGroup,
    final double iconWidth,
  ) {
    final List<String> attributeIds = <String>[];
    for (final Attribute attribute in attributeGroup.attributes) {
      attributeIds.add(attribute.id);
    }
    return AttributeListExpandable(
      padding: padding,
      insets: insets,
      product: _product,
      iconWidth: iconWidth,
      attributeIds: attributeIds,
      title: attributeGroup.name,
    );
  }

  List<AttributeGroup> _getOrderedAttributeGroups(
      final ProductPreferences productPreferences) {
    final List<AttributeGroup> attributeGroups = <AttributeGroup>[];
    for (final String attributeGroupId in _ORDERED_ATTRIBUTE_GROUP_IDS) {
      for (final AttributeGroup attributeGroup
          in productPreferences.attributeGroups) {
        if (attributeGroupId == attributeGroup.id) {
          attributeGroups.add(attributeGroup);
        }
      }
    }

    /// in case we get new attribute groups but we haven't included them yet
    for (final AttributeGroup attributeGroup
        in productPreferences.attributeGroups) {
      if (!_ORDERED_ATTRIBUTE_GROUP_IDS.contains(attributeGroup.id)) {
        attributeGroups.add(attributeGroup);
      }
    }
    return attributeGroups;
  }

  Color _getBackgroundColor(final Attribute attribute) {
    if (attribute.status == AttributeExtra.STATUS_KNOWN) {
      if (attribute.match <= 20) {
        return const HSLColor.fromAHSL(1, 0, 1, .9).toColor();
      }
      if (attribute.match <= 40) {
        return const HSLColor.fromAHSL(1, 30, 1, .9).toColor();
      }
      if (attribute.match <= 60) {
        return const HSLColor.fromAHSL(1, 60, 1, .9).toColor();
      }
      if (attribute.match <= 80) {
        return const HSLColor.fromAHSL(1, 90, 1, .9).toColor();
      }
      return const HSLColor.fromAHSL(1, 120, 1, .9).toColor();
    } else {
      return const Color.fromARGB(0xff, 0xEE, 0xEE, 0xEE);
    }
  }
}
