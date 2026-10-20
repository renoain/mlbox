import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_test/flutter_test.dart';

import 'package:mlbox/core/api_config.dart';
import 'package:mlbox/models/movie.dart';

void main() {
  final String host = defaultTargetPlatform == TargetPlatform.android
      ? 'http://10.0.2.2:8000'
      : 'http://127.0.0.1:8000';

  group('ApiConfig.resolveAssetUrl', () {
    test('URL absolut dari host lokal memakai host API yang aktif', () {
      final url = ApiConfig.resolveAssetUrl(
        'http://127.0.0.1:8000/api/media/posters/arrival.jpg',
      );

      expect(url, '$host/api/media/posters/arrival.jpg');
    });

    test('path absolut tetap dipakai apa adanya', () {
      expect(
        ApiConfig.resolveAssetUrl('/api/media/posters/arrival.jpg'),
        '$host/api/media/posters/arrival.jpg',
      );
    });

    test('path relatif diarahkan ke route media', () {
      expect(
        ApiConfig.resolveAssetUrl('posters/arrival.jpg'),
        '$host/api/media/posters/arrival.jpg',
      );
    });

    test('URL eksternal tidak diubah', () {
      expect(
        ApiConfig.resolveAssetUrl(
          'https://image.tmdb.org/t/p/w500/oYuLEt3zVCKq57qu2F8dT7NIa6f.jpg',
        ),
        'https://image.tmdb.org/t/p/w500/oYuLEt3zVCKq57qu2F8dT7NIa6f.jpg',
      );
    });

    test('nilai kosong menghasilkan null', () {
      expect(ApiConfig.resolveAssetUrl(null), isNull);
      expect(ApiConfig.resolveAssetUrl(''), isNull);
      expect(ApiConfig.resolveAssetUrl('   '), isNull);
    });
  });

  group('Movie.fromJson', () {
    test('poster_url dari backend dipakai sebagai URL lengkap', () {
      final movie = Movie.fromJson({
        'id': 1,
        'title': 'Arrival',
        'poster_url': 'http://127.0.0.1:8000/api/media/posters/arrival.jpg',
      });

      expect(movie.posterUrl, '$host/api/media/posters/arrival.jpg');
    });

    test('film tanpa poster menghasilkan posterUrl null', () {
      final movie = Movie.fromJson({'id': 2, 'title': 'Tanpa Poster'});

      expect(movie.posterUrl, isNull);
    });

    test('genres berupa list objek dibaca menjadi nama', () {
      final movie = Movie.fromJson({
        'id': 3,
        'title': 'Ant-Man',
        'genres': [
          {'id': 1, 'name': 'Action'},
          {'id': 2, 'name': 'Sci-Fi'},
        ],
      });

      expect(movie.genres, 'Action, Sci-Fi');
    });

    test('cast berupa teks dipisah koma dibaca menjadi daftar', () {
      final movie = Movie.fromJson({
        'id': 4,
        'title': 'Your Name.',
        'cast': 'Ryunosuke Kamiki, Mone Kamishiraishi, Ryo Narita',
      });

      expect(movie.cast, [
        'Ryunosuke Kamiki',
        'Mone Kamishiraishi',
        'Ryo Narita',
      ]);
    });

    test('cast berupa list objek juga diterima', () {
      final movie = Movie.fromJson({
        'id': 5,
        'title': 'Dune',
        'cast': [
          {'name': 'Timothée Chalamet'},
          {'name': 'Zendaya'},
        ],
      });

      expect(movie.cast, ['Timothée Chalamet', 'Zendaya']);
    });

    test('cast kosong menghasilkan daftar kosong', () {
      expect(Movie.fromJson({'id': 6, 'title': 'X'}).cast, isEmpty);
      expect(Movie.fromJson({'id': 7, 'title': 'X', 'cast': ''}).cast, isEmpty);
    });

    test('agregat rating dan jumlah review dibaca dari payload', () {
      final movie = Movie.fromJson({
        'id': 8,
        'title': 'Arrival',
        'average_rating': 4.25,
        'review_count': 12,
        'watched_count': 7,
        'watchlist_count': 3,
      });

      expect(movie.averageRating, 4.25);
      expect(movie.reviewCount, 12);
      expect(movie.watchedCount, 7);
      expect(movie.watchlistCount, 3);
    });

    test('film tanpa agregat menghasilkan nilai default', () {
      final movie = Movie.fromJson({'id': 9, 'title': 'X'});

      expect(movie.averageRating, isNull);
      expect(movie.reviewCount, 0);
      expect(movie.watchedCount, 0);
      expect(movie.watchlistCount, 0);
    });

    test('backdrop_url memakai route media yang sama seperti poster', () {
      final movie = Movie.fromJson({
        'id': 10,
        'title': 'Interstellar',
        'poster_url':
            'http://127.0.0.1:8000/api/media/posters/interstellar.jpg',
        'backdrop_url':
            'http://127.0.0.1:8000/api/media/backdrops/interstellar.jpg',
      });

      expect(movie.backdropUrl, '$host/api/media/backdrops/interstellar.jpg');
    });
  });
}
