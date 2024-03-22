import 'package:flutter/material.dart';
import 'package:peliculas/provinders/movies_provider.dart';
import 'package:peliculas/search/search_delegate.dart';
import 'package:peliculas/widgets/widgets.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final moviesProvier = Provider.of<MoviesProvier>(context);

    return Scaffold(
      // ignore: avoid_unnecessary_containers
      appBar: AppBar( 
        centerTitle: true,
        title: const Text('Peliculas en Cines'),
        elevation: 0,
        actions: [ 
          IconButton(
            onPressed: () => showSearch(context: context, delegate: MovieSearch()), 
            icon: const Icon(Icons.search_outlined),)
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            
            CardSwiper(movies: moviesProvier.moviesList,),

            MovieSlider(
              movies: moviesProvier.popularMoviesList, 
              title: 'Populares',
              onNextPage: () =>
                moviesProvier.getPopularM(),
              ),
          ],
        ),
      ),
    );
  }
}
