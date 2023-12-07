import 'package:chopper/chopper.dart';
import 'package:recipes/network/model_converter.dart';
import 'recipe_model.dart';
import 'model_response.dart';

part 'recipe_service.chopper.dart';

const String apiKey = '';
const String apiId = '';
const String apiUrl = 'https://api.edamam.com';

@ChopperApi()
abstract class RecipeService extends ChopperService {
  @Get(path: 'search')
  Future<Response<Result<APIRecipeQuery>>> queryRecipes(
    @Query('q') String query,
    @Query('from') int from,
    @Query('to') int to,
  );

  static RecipeService create() {
    final client = ChopperClient(
      baseUrl: Uri.parse(apiUrl),
      interceptors: [
        _addQuery,
        HttpLoggingInterceptor(),
      ],
      converter: ModelConverter(),
      errorConverter: const JsonConverter(),
      services: [
        _$RecipeService(),
      ],
    );
    return _$RecipeService(client);
  }
}

Request _addQuery(Request request) {
  final params = Map<String, dynamic>.from(request.parameters);
  params['app_id'] = apiId;
  params['app_key'] = apiKey;
  return request.copyWith(parameters: params);
}

// class RecipeService {
//   Future getData(String url) async {
//     final response = await get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       return response.body;
//     } else {
//       log(response.body);
//     }
//   }
//
//   Future<dynamic> getRecipes(String query, int from, int to) async {
//     final recipeData = await getData(
//         '$apiUrl?app_id=$apiId&app_key=$apiKey&q=$query&from=$from&to=$to');
//     return recipeData;
//   }
// }
