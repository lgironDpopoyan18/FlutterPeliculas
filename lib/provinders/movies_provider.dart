import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas/helpers/debouncer.dart';
import 'package:peliculas/models/model.dart';
import 'package:peliculas/models/search_movies.dart';


class MoviesProvier extends ChangeNotifier {
  // ignore: non_constant_identifier_names
  final String _Api = 'bda4439a5408f94f46aed36985e09065';
  // ignore: non_constant_identifier_names
  final String _BaseUrl = 'api.themoviedb.org';
  final String _lenguaje = 'es-ES';

  List<Movie> moviesList = [];
  List<Movie> popularMoviesList = [];
  Map<int, List<Cast>> moviesCast = {};

  int _popularPage = 0;
  final debouncer = Debouncer(
    duration: const Duration(milliseconds: 300),
    );
  final StreamController<List<Movie>> _suggestionStreamController = StreamController.broadcast();
 
 Stream<List<Movie>> get suggestionStream => _suggestionStreamController.stream;

  MoviesProvier() {
    // ignore: avoid_print
    print('MoviesProvider Iniciando');
    getOnPlayMovies();
    getPopularM();
  }

  Future<String> _getJsonData(String end, [int page = 1]) async {
    var url = Uri.https(_BaseUrl, end, {
      'api_key': _Api,
      'language': _lenguaje,
      'page': '$page',
    });

    final response = await http.get(url);
    return response.body;
  }

  void getOnPlayMovies() async {
    final jsonData = await _getJsonData('3/movie/now_playing');
    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);
    // ignore: avoid_print
    print(nowPlayingResponse.results[0].title);

    moviesList = nowPlayingResponse.results;
    notifyListeners();
  }

  void getPopularM() async {
    _popularPage++;
    final jsonData = await _getJsonData('3/movie/popular', _popularPage);
    final popularResponse = PopularResponse.fromJson(jsonData);

    popularMoviesList = [...popularMoviesList, ...popularResponse.results];
    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    if (moviesCast.containsKey(movieId)) return moviesCast[movieId]!;
    // ignore: avoid_print
    print('llamando a los actores');

    final jsonData = await _getJsonData('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson(jsonData);

    moviesCast[movieId] = creditsResponse.cast;
    return creditsResponse.cast;
  }

  Future <List<Movie>> searchMovie(String query) async{
    final url = Uri.https(_BaseUrl, '3/search/movie', {
      'api_key': _Api,
      'language': _lenguaje,
      'query': query
    });
    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson(response.body);

    return searchResponse.results;  
  }

  void getSuggestionsQuery (String searchTerm){
    debouncer.value = '';
    debouncer.onValue = (value) async{ 
      final results = await searchMovie(value);
      _suggestionStreamController.add(results);
    };
    final timer = Timer.periodic(const Duration(milliseconds: 200), (_) { 

      debouncer.value = searchTerm;
    });
    Future.delayed(const Duration(milliseconds: 200)).then((_) => timer.cancel());
  }


}
