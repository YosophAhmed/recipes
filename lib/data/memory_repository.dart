import 'dart:core';
import 'package:flutter/foundation.dart';

import 'repository.dart';
import 'models/models.dart';

class MemoryRepository extends Repository with ChangeNotifier {
  final List<Recipe> _currentRecipes = <Recipe>[];
  final List<Ingredient> _currentIngredients = <Ingredient>[];

  @override
  void close() {}

  @override
  void deleteIngredient(Ingredient ingredient) {
    // TODO: implement deleteIngredient
  }

  @override
  void deleteIngredients(List<Ingredient> ingredients) {
    // TODO: implement deleteIngredients
  }

  @override
  void deleteRecipe(Recipe recipe) {
    // TODO: implement deleteRecipe
  }

  @override
  void deleteRecipeIngredients(int recipeId) {
    // TODO: implement deleteRecipeIngredients
  }

  @override
  List<Ingredient> findAllIngredients() {
    // TODO: implement findAllIngredients
    throw UnimplementedError();
  }

  @override
  List<Recipe> findAllRecipes() {
    // TODO: implement findAllRecipes
    throw UnimplementedError();
  }

  @override
  Recipe findRecipeById(int id) {
    // TODO: implement findRecipeById
    throw UnimplementedError();
  }

  @override
  List<Ingredient> findRecipeIngredients(int recipeId) {
    // TODO: implement findRecipeIngredients
    throw UnimplementedError();
  }

  @override
  Future init() {
    return Future.value(null);
  }

  @override
  List<int> insertIngredients(List<Ingredient> ingredients) {
    // TODO: implement insertIngredients
    throw UnimplementedError();
  }

  @override
  int insertRecipe(Recipe recipe) {
    // TODO: implement insertRecipe
    throw UnimplementedError();
  }
}
