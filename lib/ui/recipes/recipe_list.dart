import 'dart:math';

import 'package:flutter/material.dart';
import 'package:recipes/network/recipe_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_dropdown.dart';
import '../colors.dart';

import '../../network/recipe_model.dart';
import '../widgets/recipe_card.dart';
import '../../ui/recipes/recipe_details.dart';

import 'package:chopper/chopper.dart';
import '../../network/model_response.dart';
import 'dart:collection';

class RecipeList extends StatefulWidget {
  const RecipeList({super.key});

  @override
  State<RecipeList> createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  static const String prefSearchKey = 'previousSearches';

  late TextEditingController textEditingController;
  final ScrollController _scrollController = ScrollController();
  List<APIHits> currentSearchList = [];
  int currentCount = 0;
  int currentStartPosition = 0;
  int currentEndPosition = 20;
  int pageCount = 20;
  bool hasMore = false;
  bool loading = false;
  bool inErrorState = false;
  List<String> previousSearches = <String>[];

  @override
  void initState() {
    super.initState();

    getPreviousSearches();

    textEditingController = TextEditingController(text: '');

    _scrollController.addListener(() {
      final triggerFetchMoreSize =
          0.7 * _scrollController.position.maxScrollExtent;
      if (hasMore &&
          currentEndPosition < currentCount &&
          !loading &&
          !inErrorState) {
        loading = true;
        currentStartPosition = currentEndPosition;
        currentEndPosition =
            min(currentStartPosition + pageCount, currentCount);
      }
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void savePreviousSearches() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(prefSearchKey, previousSearches);
  }

  void getPreviousSearches() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(prefSearchKey)) {
      final searches = prefs.getStringList(prefSearchKey);
      if (searches != null) {
        previousSearches = searches;
      } else {
        previousSearches = [];
      }
    }
  }

  void startSearch({required String value}) {
    setState(() {
      currentSearchList.clear();
      currentCount = 0;
      currentEndPosition = pageCount;
      currentStartPosition = 0;
      hasMore = true;
      value = value.trim();

      if (!previousSearches.contains(value)) {
        previousSearches.add(value);
        savePreviousSearches();
      }
    });
  }

  // Future<APIRecipeQuery> getRecipeData(String query, int from, int to) async {
  //   final recipeJson = await RecipeService().getRecipes(query, from, to);
  //   final recipeMap = json.decode(recipeJson);
  //   return APIRecipeQuery.fromJson(recipeMap);
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchCard(),
            _buildRecipeLoader(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeList(BuildContext recipeListContext, List<APIHits> hits) {
    final size = MediaQuery.of(context).size;
    const itemHeight = 310;
    final itemWidth = size.width / 2;
    return Flexible(
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: (itemWidth / itemHeight),
        ),
        itemCount: hits.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildRecipeCard(context, hits, index);
        },
      ),
    );
  }

  Widget _buildRecipeCard(
      BuildContext topLevelContext, List<APIHits> hits, int index) {
    final recipe = hits[index].recipe;
    return GestureDetector(
      onTap: () {
        Navigator.push(
            topLevelContext,
            MaterialPageRoute(
              builder: (context) => const RecipeDetails(),
            ));
      },
      child: recipeCard(recipe),
    );
  }

  Widget _buildSearchCard() {
    return Card(
      elevation: 4.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                startSearch(value: textEditingController.text);
                final currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
            ),
            const SizedBox(width: 6.0),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textEditingController,
                      autofocus: false,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search',
                      ),
                      onSubmitted: (value) {
                        startSearch(value: textEditingController.text);
                      },
                      // onChanged: (query) {
                      //   if (query.length >= 3) {
                      //     setState(() {
                      //       currentSearchList.clear();
                      //       currentCount = 0;
                      //       currentStartPosition = 0;
                      //       currentEndPosition = pageCount;
                      //     });
                      //   }
                      // },
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: lightGrey,
                    ),
                    onSelected: (String value) {
                      textEditingController.text = value;
                      startSearch(value: textEditingController.text);
                    },
                    itemBuilder: (BuildContext context) {
                      return previousSearches
                          .map<CustomDropdownMenuItem<String>>((String value) {
                        return CustomDropdownMenuItem<String>(
                          text: value,
                          value: value,
                          callback: () {
                            setState(() {
                              previousSearches.remove(value);
                              savePreviousSearches();
                              Navigator.pop(context);
                            });
                          },
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeLoader(BuildContext context) {
    if (textEditingController.text.length < 3) {
      return Container();
    }
    return FutureBuilder<Response<Result<APIRecipeQuery>>>(
      future: RecipeService.create().queryRecipes(
        textEditingController.text.trim(),
        currentStartPosition,
        currentEndPosition,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                textAlign: TextAlign.center,
                textScaleFactor: 1.3,
              ),
            );
          }

          loading = false;

          if (snapshot.data?.isSuccessful == false) {
            var errorMessage = 'Problems getting data';
            if (snapshot.data?.error != null &&
                snapshot.data?.error is LinkedHashMap) {
              final map = snapshot.data?.error as LinkedHashMap;
              errorMessage = map['message'];
            }
            return Center(
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18.0),
              ),
            );
          }

          final result = snapshot.data?.body;

          if (result == null || result is Error) {
            inErrorState = true;
            return _buildRecipeList(context, currentSearchList);
          }

          final query = (result as Success).value;
          inErrorState = false;

          if (query != null) {
            currentCount = query.count;
            hasMore = query.more;
            currentSearchList.addAll(query.hits);

            if (query.to < currentEndPosition) {
              currentEndPosition = query.to;
            }

          }

          return _buildRecipeList(context, currentSearchList);
        } else {
          if (currentCount == 0) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return _buildRecipeList(context, currentSearchList);
          }
        }
      },
    );
  }
}
