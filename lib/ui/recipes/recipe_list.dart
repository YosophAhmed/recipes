import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_dropdown.dart';
import '../colors.dart';

class RecipeList extends StatefulWidget {
  const RecipeList({super.key});

  @override
  State<RecipeList> createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  late TextEditingController textEditingController;
  final ScrollController _scrollController = ScrollController();
  List currentSearchList = [];
  int currentCount = 0;
  int currentStartPosition = 0;
  int currentEndPosition = 20;
  int pageCount = 20;
  bool hasMore = false;
  bool loading = false;
  bool inErrorState = false;

  @override
  void initState() {
    super.initState();
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
            const Icon(Icons.search),
            const SizedBox(width: 6.0),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search',
                      ),
                      autofocus: false,
                      controller: textEditingController,
                      onChanged: (query) {
                        if (query.length >= 3) {
                          setState(() {
                            currentSearchList.clear();
                            currentCount = 0;
                            currentStartPosition = 0;
                            currentEndPosition = pageCount;
                          });
                        }
                      },
                    ),
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
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
