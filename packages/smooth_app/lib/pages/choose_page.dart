import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/utils/PnnsGroups.dart';
import 'package:smooth_app/cards/category_cards/category_card.dart';
import 'package:smooth_app/cards/category_cards/category_chip.dart';
import 'package:smooth_app/cards/category_cards/subcategory_card.dart';
import 'package:smooth_app/database/keywords_product_query.dart';
import 'package:smooth_app/database/group_product_query.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/product_page.dart';
import 'package:smooth_app/database/barcode_product_query.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/pages/product_query_page_helper.dart';

class ChoosePage extends StatefulWidget {
  @override
  _ChoosePageState createState() => _ChoosePageState();

  static Future<void> _barcodeSearch(
    String code,
    BuildContext context,
    final LocalDatabase localDatabase,
  ) async {
    final Product product = await BarcodeProductQuery(code).getProduct();
    if (product != null) {
      await DaoProduct(localDatabase).put(product);
      Navigator.pop(context);
      Navigator.push<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => ProductPage(
            product: product,
          ),
        ),
      );
      return;
    }
    Navigator.pop(context);
    showDialog<Widget>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(20.0)),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 4.0,
                sigmaY: 4.0,
              ),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                width: MediaQuery.of(context).size.width * 0.8,
                height: 120.0,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  color: Colors.white70,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            'No product found with matching barcode : $code',
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 24.0,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: 40.0,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50.0)),
                              color: Colors.redAccent.withAlpha(50),
                            ),
                            child: Center(
                              child: Text(
                                'Close',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4
                                    .copyWith(color: Colors.redAccent),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: 40.0,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50.0)),
                              color: Colors.lightBlue.withAlpha(50),
                            ),
                            child: Center(
                              child: Text(
                                'Contribute',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4
                                    .copyWith(color: Colors.lightBlue),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> onSubmitted(
    final String value,
    final BuildContext context,
    final LocalDatabase localDatabase,
  ) async {
    if (int.parse(value, onError: (String e) => null) != null) {
      showDialog<Widget>(
        context: context,
        builder: (BuildContext context) {
          ChoosePage._barcodeSearch(
            value,
            context,
            localDatabase,
          );
          return Dialog(
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 4.0,
                  sigmaY: 4.0,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 120.0,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    color: Colors.white70,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Looking for : $value'),
                      const SizedBox(
                        height: 24.0,
                      ),
                      const CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      await ProductQueryPageHelper().openBestChoice(
        color: Colors.deepPurple,
        heroTag: 'search_bar',
        name: value,
        localDatabase: localDatabase,
        productQuery: KeywordsProductQuery(
          value,
          Localizations.localeOf(context).languageCode,
        ),
        context: context,
      );
    }
  }
}

class _ChoosePageState extends State<ChoosePage> {
  static const Map<PnnsGroup1, String> _CATEGORY_ICONS = <PnnsGroup1, String>{
    PnnsGroup1.BEVERAGES: 'beverages.svg',
    PnnsGroup1.CEREALS_AND_POTATOES: 'cereals_and_potatoes.svg',
    PnnsGroup1.COMPOSITE_FOODS: 'composite_foods.svg',
    PnnsGroup1.FAT_AND_SAUCES: 'fat_and_sauces.svg',
    PnnsGroup1.FISH_MEAT_AND_EGGS: 'fish_meat_and_eggs.svg',
    PnnsGroup1.FRUITS_AND_VEGETABLES: 'fruits_and_vegetables.svg',
    PnnsGroup1.MILK_AND_DAIRIES: 'milk_and_dairies.svg',
    PnnsGroup1.SALTY_SNACKS: 'salty_snacks.svg',
    PnnsGroup1.SUGARY_SNACKS: 'sugary_snacks.svg',
  };

  static const List<Color> _COLORS = <Color>[
    Colors.deepPurpleAccent,
    Colors.deepOrangeAccent,
    Colors.blueAccent,
    Colors.brown,
    Colors.redAccent,
    Colors.lightGreen,
    Colors.amber,
    Colors.indigoAccent,
    Colors.pink,
  ];

  PnnsGroup1 _selectedCategory;
  Color _selectedColor;

  void _selectCategory(final PnnsGroup1 group, final Color color) {
    _selectedCategory = group;
    _selectedColor = color;
  }

  void _unSelectCategory() {
    if (_selectedCategory != null) {
      _selectedCategory = null;
      _selectedColor = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _selectedCategory == null
                ? 'Food Categories'
                : _selectedCategory.name,
            style: TextStyle(color: colorScheme.onBackground),
          ),
          iconTheme: IconThemeData(color: colorScheme.onBackground),
        ),
        //key: _scaffoldKey,
        body: Column(
          children: <Widget>[
            if (_selectedCategory == null)
              Container()
            else
              Container(
                padding: const EdgeInsets.only(bottom: 0.0),
                width: MediaQuery.of(context).size.width,
                height: 100.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: List<Widget>.generate(
                    PnnsGroup1.values.length,
                    (int index) {
                      final PnnsGroup1 group = PnnsGroup1.values[index];
                      final Color color = _getColor(index);
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 250),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: CategoryChip(
                              title: group.name,
                              color: color,
                              onTap: () async =>
                                  setState(() => _selectCategory(group, color)),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            Expanded(
                child: _selectedCategory == null
                    ? _showAllPnnsGroup1()
                    : _showPnnsGroup2(
                        _selectedCategory,
                        _selectedColor,
                        localDatabase,
                      ))
          ],
        ),
      ),
    );
  }

  Widget _showAllPnnsGroup1() => GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        padding: const EdgeInsets.only(
            top: 10.0, bottom: 80.0, right: 10.0, left: 10.0),
        mainAxisSpacing: 20.0,
        crossAxisSpacing: 10.0,
        children: List<Widget>.generate(
          PnnsGroup1.values.length,
          (int index) {
            final PnnsGroup1 group = PnnsGroup1.values[index];
            final Color color = _getColor(index);
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 400),
              columnCount: 2,
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: CategoryCard(
                    title: group.name,
                    color: color,
                    iconName: _CATEGORY_ICONS[group],
                    onTap: () => setState(() => _selectCategory(group, color)),
                  ),
                ),
              ),
            );
          },
        ),
      );

  Widget _showPnnsGroup2(
    final PnnsGroup1 category,
    final Color color,
    final LocalDatabase localDatabase,
  ) =>
      ListView(
        padding: const EdgeInsets.only(top: 8.0, bottom: 80.0),
        children: List<Widget>.generate(category.subGroups.length, (int index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 250),
            child: SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: SubcategoryCard(
                    heroTag: category.subGroups[index].name,
                    title: category.subGroups[index].name,
                    color: color,
                    onTap: () async {
                      final PnnsGroup2 group = category.subGroups[index];
                      await ProductQueryPageHelper().openBestChoice(
                        productQuery: GroupProductQuery(
                          group,
                          Localizations.localeOf(context).languageCode,
                        ),
                        heroTag: group.id,
                        color: color,
                        name: group.name,
                        localDatabase: localDatabase,
                        context: context,
                      );
                    }),
              ),
            ),
          );
        }),
      );

  Color _getColor(final int index) => _COLORS[index % _COLORS.length];

  Future<bool> _onWillPop() async {
    if (_selectedCategory != null) {
      setState(() => _unSelectCategory());
      return false;
    }
    return true;
  }
}
