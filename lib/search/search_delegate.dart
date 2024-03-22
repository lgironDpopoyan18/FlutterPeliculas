import 'package:flutter/material.dart';
import 'package:peliculas/models/model.dart';
import 'package:peliculas/provinders/movies_provider.dart';
import 'package:provider/provider.dart';

class MovieSearch extends SearchDelegate{

  @override

  String get searchFieldLabel => 'Buscar Pelicula';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = '', 
        icon: const Icon(Icons.cancel_outlined)),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: (){
        close(context, null);
      }, 
      icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    
      return _emptyContainer();
  }

  Widget _emptyContainer(){
    // ignore: avoid_unnecessary_containers
    return Container(
        child: const Center(
          child: Icon(Icons.movie_creation_outlined, color: Colors.black38, size: 300,),
        ),
      );
  }
  @override
  Widget buildSuggestions(BuildContext context) {

    if(query.isEmpty){
      return _emptyContainer();
    }

    final moviesProvier = Provider.of<MoviesProvier>(context, listen: false);
    moviesProvier.getSuggestionsQuery(query);

    return StreamBuilder(
      stream: moviesProvier.suggestionStream,
      builder: ( _ , AsyncSnapshot<List<Movie>> snapshot) {
        if(!snapshot.hasData) return _emptyContainer();

          final movies = snapshot.data!;

          return ListView.builder(
          itemCount: movies.length,
          itemBuilder: ( _, int index)=> MovieItem(movies[index]),
          ) ;
      },
    );
  }

}
class MovieItem extends StatelessWidget {
  
  final Movie movie;

  // ignore: use_key_in_widget_constructors
  const MovieItem(this.movie);

  @override
  Widget build(BuildContext context) {

    movie.heroId= 'search-${movie.id}';
    return ListTile(
      leading: Hero(
        tag: movie.heroId!,
        child: FadeInImage(
          placeholder: const AssetImage('assets/no-image.jpg'), 
          image: NetworkImage(movie.fullPoster),
          width: 50,
          fit: BoxFit.contain,
          ),
      ),
        title: Text(movie.title),
        subtitle: Text(movie.originalTitle),
        onTap: (){
          Navigator.pushNamed(context, 'details', arguments: movie);
        },

    );
  }
}