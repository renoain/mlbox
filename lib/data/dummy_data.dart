import '../state/app_state.dart';

class FilmItem {
  final int id;
  final String title;
  final int year;
  final String director;
  final String? posterUrl;

  const FilmItem({
    required this.id,
    required this.title,
    required this.year,
    required this.director,
    this.posterUrl,
  });
}

class ReviewItem {
  final FilmItem film;
  final double rating;
  final bool liked;
  final String user;
  final String text;

  const ReviewItem({
    required this.film,
    required this.rating,
    required this.liked,
    required this.user,
    required this.text,
  });
}

class ListItem {
  final String title;
  final String owner;
  final int filmCount;
  final String description;
  final int likes;
  final int commentsCount;
  final List<String> tags;
  final bool official;

  const ListItem({
    required this.title,
    required this.owner,
    required this.filmCount,
    this.description = '',
    this.likes = 0,
    this.commentsCount = 0,
    this.tags = const [],
    this.official = false,
  });
}

class CommentItem {
  final String user;
  final String ago;
  final String text;

  const CommentItem({required this.user, required this.ago, required this.text});
}

class PersonItem {
  final String name;
  final String description;

  const PersonItem({required this.name, required this.description});
}

/// Semua data di sini dummy. Ganti dengan API/provider nanti.
class DummyData {
  DummyData._();

  static const List<FilmItem> films = [
    FilmItem(id: 1, title: 'Digger', year: 2026, director: 'Rina Wibowo'),
    FilmItem(id: 2, title: 'Other Mommy', year: 2026, director: 'Daniel Hart'),
    FilmItem(id: 3, title: 'Resident Evil', year: 2026, director: 'Maya Kusuma'),
    FilmItem(id: 4, title: 'Primetime', year: 2026, director: 'Arman Reyes'),
    FilmItem(id: 5, title: 'The Social Reckoning', year: 2026, director: 'Lena Ortiz'),
    FilmItem(id: 6, title: 'Verity', year: 2026, director: 'Sofia Lindqvist'),
    FilmItem(id: 7, title: 'Spider-Man: Brand New Day', year: 2026, director: 'Kenji Mori'),
    FilmItem(id: 8, title: 'Carrie', year: 2026, director: 'Adrian Bell'),
    FilmItem(id: 9, title: 'The Love Hypothesis', year: 2026, director: 'Nadia Pratama'),
    FilmItem(id: 10, title: 'Jo', year: 2019, director: 'Hana Pratama'),
  ];

  static final List<ReviewItem> reviews = [
    ReviewItem(
      film: films[0],
      rating: 5,
      liked: true,
      user: 'Anne',
      text: 'Smart, trippy and funny. Worth making the time to decide for yourself what you make of it.',
    ),
    ReviewItem(
      film: films[1],
      rating: 2,
      liked: false,
      user: 'mak',
      text: "you're blatantly just not me mum",
    ),
    ReviewItem(
      film: films[9],
      rating: 3.5,
      liked: false,
      user: 'yucchii',
      text: 'jo jo jo jo Jo Jo Jo Jo Jo Jo Jo Jo Jo Jo',
    ),
  ];

  static const List<ListItem> lists = [
    ListItem(title: 'Digger Marathon', owner: 'nina', filmCount: 24),
    ListItem(title: 'Best of 2026', owner: 'darren', filmCount: 50),
    ListItem(title: 'Jo Picks', owner: 'sweetie', filmCount: 12),
  ];

  static const List<PersonItem> people = [
    PersonItem(
      name: 'Jolie Hartanto',
      description: 'Actor in 5 films including Digger and Verity',
    ),
    PersonItem(
      name: 'Joko Santoso',
      description: 'Director of 3 films including Primetime',
    ),
    PersonItem(
      name: 'Johan Lee',
      description: 'Makeup for 4 films including Carrie',
    ),
  ];

  static const List<ListItem> featuredLists = [
    ListItem(
      title: 'Most Loved Films',
      owner: 'community',
      filmCount: 250,
      description: 'The films with the most fans, ranked.',
      likes: 12840,
      commentsCount: 320,
      tags: ['community', 'featured'],
    ),
    ListItem(
      title: 'Best of 2026 So Far',
      owner: 'community',
      filmCount: 25,
      description: 'The best films of the year, updated monthly.',
      likes: 8210,
      commentsCount: 145,
      tags: ['2026', 'featured'],
    ),
    ListItem(
      title: 'Films by Women Directors',
      owner: 'community',
      filmCount: 250,
      description: 'Narrative features directed by women.',
      likes: 20450,
      commentsCount: 512,
      tags: ['directors', 'featured'],
    ),
    ListItem(
      title: 'Hidden Gems',
      owner: 'community',
      filmCount: 100,
      description: 'Underseen films worth your time.',
      likes: 5033,
      commentsCount: 98,
      tags: ['hidden gems', 'featured'],
    ),
  ];

  static const List<ListItem> officialLists = [
    ListItem(
      title: 'Top 250 Romance Films',
      owner: 'Official Lists',
      filmCount: 250,
      description:
          'As of October 20, 2026. Ranks narrative feature films in the romance genre by average member rating.',
      likes: 30210,
      commentsCount: 1204,
      tags: ['official', 'romance', 'stats list'],
      official: true,
    ),
    ListItem(
      title: 'Top 50 Indonesian Films',
      owner: 'Official Lists',
      filmCount: 50,
      description:
          'As of October 20, 2026. Ranks Indonesian narrative feature films by average member rating.',
      likes: 9120,
      commentsCount: 310,
      tags: ['official', 'indonesia', 'stats list'],
      official: true,
    ),
    ListItem(
      title: 'Top 500 Films',
      owner: 'Official Lists',
      filmCount: 500,
      description:
          'As of October 20, 2026. Ranks narrative feature films by average member rating.',
      likes: 441506,
      commentsCount: 35040,
      tags: ['official', 'all time', 'top 500', 'featured list', 'stats list'],
      official: true,
    ),
  ];

  static const List<CommentItem> comments = [
    CommentItem(user: 'rina', ago: '2d', text: 'Only 57% seen. So much left to watch.'),
    CommentItem(user: 'dave', ago: '2d', text: "That's 3% more than me!"),
    CommentItem(
      user: 'nina',
      ago: '1w',
      text: 'List updated today! Most notable changes: Digger +3, Verity -2.',
    ),
    CommentItem(user: 'maya', ago: '3w', text: 'Love how this keeps evolving.'),
    CommentItem(user: 'arman', ago: '1mo', text: 'Where is Primetime?'),
  ];

  static List<FilmItem> rankedFilms(int n) =>
      List.generate(n, (i) => films[i % films.length]);

  static final List<ActivityEntry> incoming = [
    ActivityEntry(
      user: 'nina',
      title: 'Verity',
      year: 2026,
      rating: 4,
      liked: true,
      review: 'Did not see that ending coming.',
      watchedOn: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  static bool _match(String text, String q) =>
      text.toLowerCase().contains(q.trim().toLowerCase());

  static List<FilmItem> searchFilms(String q) {
    if (q.trim().isEmpty) return const [];
    return films.where((f) => _match(f.title, q)).toList();
  }

  static List<ReviewItem> searchReviews(String q) {
    if (q.trim().isEmpty) return const [];
    return reviews
        .where((r) => _match(r.film.title, q) || _match(r.text, q))
        .toList();
  }

  static List<ListItem> searchLists(String q) {
    if (q.trim().isEmpty) return const [];
    return lists.where((l) => _match(l.title, q)).toList();
  }

  static List<PersonItem> searchPeople(String q) {
    if (q.trim().isEmpty) return const [];
    return people.where((p) => _match(p.name, q)).toList();
  }
}
