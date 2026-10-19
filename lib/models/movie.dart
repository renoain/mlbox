class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterUrl;
  final String releaseDate;
  final String runtime;
  final String genres;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterUrl,
    required this.releaseDate,
    required this.runtime,
    required this.genres,
  });

  // DATA DUMMY UNTUK DESAIN UI (Diambil dari movies.json)
  static List<Movie> dummyMovies = [
    Movie(
      id: 1,
      title: '127 Hours',
      overview: 'Film ini mengisahkan Aron Ralston, seorang pendaki yang melakukan perjalanan sendirian di ngarai terpencil Utah...',
      posterUrl:
          'https://image.tmdb.org/t/p/w500/1.jpg', // Isi URL poster asli nanti
      releaseDate: '2010-11-05',
      runtime: '94',
      genres: 'Biography, Drama, Adventure',
    ),
    Movie(
      id: 2,
      title: 'Annabelle',
      overview: 'John dan Mia Form adalah pasangan muda yang sedang menantikan kelahiran anak pertama mereka...',
      posterUrl: 'https://image.tmdb.org/t/p/w500/2.jpg',
      releaseDate: '2014-10-03',
      runtime: '99',
      genres: 'Horror, Mystery, Thriller',
    ),
    Movie(
      id: 3,
      title: 'Aquaman',
      overview: 'Arthur Curry mengetahui bahwa dirinya merupakan pewaris takhta kerajaan bawah laut Atlantis...',
      posterUrl: 'https://image.tmdb.org/t/p/w500/3.jpg',
      releaseDate: '2018-12-21',
      runtime: '143',
      genres: 'Action, Adventure, Fantasy',
    ),
    Movie(
      id: 4,
      title: 'Arrival',
      overview: 'Kedatangan pesawat luar angkasa misterius di berbagai wilayah dunia memicu ketegangan internasional...',
      posterUrl: 'https://image.tmdb.org/t/p/w500/4.jpg',
      releaseDate: '2016-11-11',
      runtime: '116',
      genres: 'Science Fiction, Drama, Mystery',
    ),
    Movie(
      id: 5,
      title: 'Avatar',
      overview: 'Jake Sully, seorang mantan marinir yang menggunakan kursi roda, dikirim ke Pandora...',
      posterUrl: 'https://image.tmdb.org/t/p/w500/5.jpg',
      releaseDate: '2009-12-18',
      runtime: '162',
      genres: 'Action, Adventure, Science Fiction',
    ),
  ];
}
