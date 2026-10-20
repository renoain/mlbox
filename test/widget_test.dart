import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:mlbox/core/app_theme.dart';
import 'package:mlbox/models/movie.dart';
import 'package:mlbox/models/watched_entry.dart';
import 'package:mlbox/models/profile_stats.dart';
import 'package:mlbox/models/user.dart';
import 'package:mlbox/pages/activity_page.dart';
import 'package:mlbox/pages/movie_detail_page.dart';
import 'package:mlbox/pages/login_page.dart';
import 'package:mlbox/pages/profile_page.dart';
import 'package:mlbox/pages/register_page.dart';
import 'package:mlbox/pages/settings_page.dart';
import 'package:mlbox/pages/watched_page.dart';
import 'package:mlbox/providers/auth_provider.dart';
import 'package:mlbox/providers/library_provider.dart';
import 'package:mlbox/providers/movie_provider.dart';
import 'package:mlbox/providers/profile_provider.dart';
import 'package:mlbox/repositories/favorite_repository.dart';
import 'package:mlbox/repositories/movie_repository.dart';
import 'package:mlbox/widgets/main_bottom_nav.dart';

void main() {
  testWidgets('Guest: menu Profile membuka halaman login', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const _HomeStub()),
        GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
        GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
        GoRoute(path: '/search', builder: (_, _) => const _SearchStub()),
        GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pump();

    // Navbar selalu 5 ikon; untuk guest, menu Profile (ikon orang).
    await tester.tap(find.byIcon(Icons.person_outline).last);
    await tester.pumpAndSettle();

    expect(find.text('Masuk untuk melihat profil'), findsOneWidget);

    // Dari situ user bisa masuk.
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in to MLBox'), findsOneWidget);
  });

  testWidgets('Guest: Join MLBox opens Register and back returns to Login', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const _HomeStub()),
        GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
        GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
        GoRoute(path: '/search', builder: (_, _) => const _SearchStub()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pump();

    await tester.ensureVisible(find.text('JOIN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('JOIN'));
    await tester.pumpAndSettle();
    expect(find.text('Join MLBox'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();
    expect(find.text('Sign in to MLBox'), findsOneWidget);
  });

  testWidgets('Login: empty submit shows validation, no navigation', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const _HomeStub()),
        GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
        GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
        GoRoute(path: '/search', builder: (_, _) => const _SearchStub()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pump();

    await tester.ensureVisible(find.text('GO'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('GO'));
    await tester.pump();

    expect(find.text('Email dan password wajib diisi.'), findsOneWidget);
    expect(find.text('Sign in to MLBox'), findsOneWidget);
  });

  testWidgets('Register: JOIN butuh persetujuan syarat dan privasi', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/register',
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const _HomeStub()),
        GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
        GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
        GoRoute(path: '/search', builder: (_, _) => const _SearchStub()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pump();

    // Kolom form dan baris persetujuan harus tampil.
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Confirm password'), findsOneWidget);
    expect(find.textContaining('Terms of Use'), findsOneWidget);
    expect(find.textContaining('Privacy Policy'), findsOneWidget);

    // Tekan JOIN tanpa mengisi apa pun -> validasi kolom dulu.
    // Tombol berada di bawah fold, jadi harus digulir dulu.
    await tester.ensureVisible(find.text('JOIN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('JOIN'));
    await tester.pump();
    expect(find.text('Semua kolom wajib diisi.'), findsOneWidget);

    // Isi kolom, tapi persetujuan belum dicentang -> tolak persetujuan.
    await tester.enterText(find.byType(TextField).at(0), 'a@b.com');
    await tester.enterText(find.byType(TextField).at(1), 'Tester');
    await tester.enterText(find.byType(TextField).at(2), 'password123');
    await tester.enterText(find.byType(TextField).at(3), 'password123');
    await tester.ensureVisible(find.text('JOIN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('JOIN'));
    await tester.pump();
    expect(
      find.textContaining('Terms of Use dan Privacy Policy'),
      findsOneWidget,
    );
  });

  testWidgets('Settings: placeholder item shows not-available message', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
        GoRoute(path: '/profile', builder: (_, _) => const _HomeStub()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pump();

    expect(find.text('Settings'), findsOneWidget);

    // Item yang belum ada fiturnya harus memberi tahu, bukan diam saja.
    await tester.tap(find.text('Password and authentication'));
    await tester.pump();

    expect(find.text('Fitur belum tersedia.'), findsOneWidget);
  });

  testWidgets('Settings: desain baru memuat menu dan tombol Sign out', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
        GoRoute(path: '/profile', builder: (_, _) => const _HomeStub()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pump();

    // Item teratas langsung terlihat.
    expect(find.text('Sign out'), findsOneWidget);
    expect(find.text('Password and authentication'), findsOneWidget);

    // Item di bawah harus digulir dulu supaya ter-build.
    await tester.scrollUntilVisible(
      find.text('Language'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Language'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('About MLBox'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('About MLBox'), findsOneWidget);
  });

  testWidgets('Profile: menampilkan nama user dan statistik dari API', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
        GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => _FakeAuthNotifier()),
          profileStatsProvider.overrideWith(
            (ref) async => const ProfileStats(
              totalWatched: 7,
              totalDiary: 5,
              totalReviews: 3,
              totalLists: 2,
              totalWatchlist: 4,
              totalLikes: 1,
              totalTags: 6,
              totalFollowing: 8,
              totalFollowers: 9,
            ),
          ),
          favoritesProvider.overrideWith((ref) async => const []),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // Nama user asli, bukan dummy.
    expect(find.text('Tester'), findsOneWidget);
    expect(find.textContaining('Joined'), findsOneWidget);
    expect(find.text('FAVOURITE FILMS'), findsOneWidget);

    // Angka statistik dari API (barisnya di bawah, harus digulir dulu).
    await tester.scrollUntilVisible(
      find.text('Films'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Films'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('Reviews'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });
  testWidgets('Profile: baris Films/Diary/Watchlist bisa diklik', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
        GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
        GoRoute(path: '/watched', builder: (_, _) => const _WatchedStub()),
        GoRoute(path: '/log', builder: (_, _) => const _LogStub()),
        GoRoute(path: '/watchlist', builder: (_, _) => const _WatchlistStub()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => _FakeAuthNotifier()),
          profileStatsProvider.overrideWith(
            (ref) async => const ProfileStats(totalWatched: 7, totalDiary: 5),
          ),
          favoritesProvider.overrideWith((ref) async => const []),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // Baris statistik baru ter-build setelah digulir.
    await tester.scrollUntilVisible(
      find.text('Films'),
      250,
      scrollable: find.byType(Scrollable).first,
    );

    // Hanya 3 baris yang punya halaman: Films, Diary, Watchlist.
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(4));

    // Films -> halaman Films.
    await tester.tap(find.text('Films'));
    await tester.pumpAndSettle();
    expect(find.text('Watched Stub'), findsOneWidget);

    // Diary -> halaman Log.
    router.go('/profile');
    await tester.pumpAndSettle();
    await _scrollTo(tester, 'Diary');
    await tester.tap(find.text('Diary'));
    await tester.pumpAndSettle();
    expect(find.text('Log Stub'), findsOneWidget);

    // Watchlist -> halaman Watchlist.
    router.go('/profile');
    await tester.pumpAndSettle();
    await _scrollTo(tester, 'Watchlist');
    await tester.tap(find.text('Watchlist'));
    await tester.pumpAndSettle();
    expect(find.text('Watchlist Stub'), findsOneWidget);
  });

  testWidgets('Films: daftar film yang ditonton beserta tanggalnya', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/watched',
      routes: [
        GoRoute(path: '/watched', builder: (_, _) => const WatchedPage()),
        GoRoute(path: '/profile', builder: (_, _) => const _HomeStub()),
        GoRoute(path: '/login', builder: (_, _) => const _HomeStub()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => _FakeAuthNotifier()),
          watchedEntriesProvider.overrideWith(
            (ref) async => const [
              WatchedEntry(
                id: 1,
                movie: Movie(
                  id: 3,
                  title: 'Arrival',
                  posterUrl: 'http://127.0.0.1:8000/api/media/posters/a.jpg',
                ),
                watchedAt: '2026-10-20',
              ),
            ],
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Arrival'), findsOneWidget);
    expect(find.text('Ditonton 20 Okt 2026'), findsOneWidget);
  });
  testWidgets('Favourite Films: pilih film lalu tersimpan ke API', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
        GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
      ],
    );

    final fakeRepository = _FakeFavoriteRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => _FakeAuthNotifier()),
          profileStatsProvider.overrideWith(
            (ref) async => const ProfileStats(),
          ),
          moviesProvider.overrideWith(
            (ref) async => [
              _FakeFavoriteRepositoryList.arrival,
              _FakeFavoriteRepositoryList.dune,
            ],
          ),
          favoritesProvider.overrideWith((ref) async => fakeRepository.stored),
          favoriteRepositoryProvider.overrideWithValue(fakeRepository),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // Belum ada favorit -> ada 4 slot kosong dengan tombol tambah.
    expect(
      find.text('Belum ada film favorit. Ketuk kotak + untuk memilih.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.add), findsNWidgets(4));

    // Ketuk kotak + -> sheet pemilih film terbuka.
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    expect(find.text('Pilih film favorit'), findsOneWidget);
    expect(find.text('Arrival'), findsOneWidget);

    // Pilih satu film -> langsung dikirim ke API.
    await tester.tap(find.text('Arrival'));
    await tester.pumpAndSettle();

    expect(fakeRepository.savedIds, [3]);
    expect(find.text('Film favorit disimpan.'), findsOneWidget);
  });
  testWidgets('Navbar: 5 ikon, kapsul saat aktif, ikon tengah hijau besar', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const _HomeStub()),
        GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pump();

    // Ikon tidak aktif memakai gaya outline, ikon aktif memakai filled.
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsNothing);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.add_circle), findsOneWidget);
    expect(find.byIcon(Icons.bolt_outlined), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);

    // Label tidak ditampilkan. (Label tetap ada di tree, jadi dicek lewat
    // properti widget, bukan lewat find.text.)
    final nav = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(nav.showSelectedLabels, isFalse);
    expect(nav.showUnselectedLabels, isFalse);
    expect(nav.backgroundColor, Colors.transparent);

    // Warna ikon: aktif biru muda, tidak aktif abu-abu.
    expect(nav.selectedItemColor, const Color(0xFF40BCF4));
    expect(nav.unselectedItemColor, const Color(0xFF9AB5C4));

    // Ikon aktif dibungkus kapsul biru gelap.
    final capsule = tester.widget<AnimatedContainer>(
      find
          .ancestor(
            of: find.byIcon(Icons.home),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    );
    final decoration = capsule.decoration! as BoxDecoration;
    expect(decoration.color, const Color(0xFF1A3B4F));
    expect(decoration.borderRadius, BorderRadius.circular(20));

    // Ikon tengah (Quick Review) selalu hijau dan lebih besar, tanpa kapsul.
    final quickReview = tester.widget<Icon>(find.byIcon(Icons.add_circle));
    expect(quickReview.color, AppTheme.primary);
    expect(quickReview.size, 32);

    // Navbar dibungkus gradasi + bayangan di atasnya.
    final wrapper = tester.widget<Container>(
      find
          .ancestor(
            of: find.byType(BottomNavigationBar),
            matching: find.byType(Container),
          )
          .first,
    );
    final wrapperDecoration = wrapper.decoration! as BoxDecoration;
    expect(wrapperDecoration.gradient, isNotNull);
    expect(wrapperDecoration.boxShadow, isNotEmpty);
  });

  testWidgets('Activity: tab Watchlist dan Diary', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/activity',
      routes: [
        GoRoute(path: '/activity', builder: (_, _) => const ActivityPage()),
        GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
        GoRoute(path: '/profile', builder: (_, _) => const _HomeStub()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => _FakeAuthNotifier()),
          watchlistProvider.overrideWith((ref) async => const []),
          diaryProvider.overrideWith((ref) async => const []),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Activity'), findsWidgets);
    expect(find.text('Watchlist'), findsWidgets);
    expect(find.text('Diary'), findsWidgets);
  });
  testWidgets('Detail film: tombol hati menandai film sebagai suka', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/movie/3',
      routes: [
        GoRoute(
          path: '/movie/:id',
          builder: (_, state) => MovieDetailPage(
            movieId: int.parse(state.pathParameters['id'] ?? '0'),
          ),
        ),
        GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
        GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
      ],
    );

    final fakeRepository = _FakeMovieRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => _FakeAuthNotifier()),
          movieRepositoryProvider.overrideWithValue(fakeRepository),
          movieDetailProvider(3).overrideWith(
            (ref) async => const Movie(
              id: 3,
              title: 'Aquaman',
              isLiked: false,
              likeCount: 0,
            ),
          ),
          // Semua provider library ikut dioverride supaya halaman detail
          // tidak menembak API (dan tidak menampilkan spinner tanpa akhir).
          watchlistProvider.overrideWith((ref) async => const []),
          watchedProvider.overrideWith((ref) async => const []),
          diaryProvider.overrideWith((ref) async => const []),
          likedMoviesProvider.overrideWith((ref) async => const []),
          movieReviewsProvider(3).overrideWith((ref) async => const []),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // Awalnya ikon hati kosong.
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNothing);

    // Diklik -> status berubah tanpa reload halaman.
    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);

    // Diklik lagi -> unlike.
    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();

    expect(fakeRepository.calls, ['like:3', 'unlike:3']);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier() : super();

  @override
  Future<void> checkSession() async {
    state = state.copyWith(
      isCheckingSession: false,
      user: User(
        id: 1,
        name: 'Tester',
        email: 'tester@example.com',
        role: 'user',
        createdAt: DateTime(2026, 1, 15),
      ),
    );
  }
}

/// Repository favorit palsu: mencatat panggilan tanpa menyentuh jaringan.
class _FakeFavoriteRepository extends FavoriteRepository {
  List<int> savedIds = [];
  List<Movie> stored = [];

  @override
  Future<List<Movie>> saveFavorites(List<int> movieIds) async {
    savedIds = List<int>.of(movieIds);
    stored = savedIds.map(_movieById).toList();
    return stored;
  }
}

Movie _movieById(int id) {
  return Movie(
    id: id,
    title: 'Film $id',
    posterUrl: 'http://127.0.0.1:8000/api/media/posters/film$id.jpg',
  );
}

class _FakeFavoriteRepositoryList {
  static final Movie arrival = Movie(
    id: 3,
    title: 'Arrival',
    posterUrl: 'http://127.0.0.1:8000/api/media/posters/arrival.jpg',
  );

  static final Movie dune = Movie(
    id: 4,
    title: 'Dune',
    posterUrl: 'http://127.0.0.1:8000/api/media/posters/dune.jpg',
  );
}

class _HomeStub extends StatelessWidget {
  const _HomeStub();
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Text('Home'),
    bottomNavigationBar: MainBottomNav(currentIndex: 0),
  );
}

class _SearchStub extends StatelessWidget {
  const _SearchStub();
  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('Search'));
}

/// Repository film palsu: mencatat pemanggilan like tanpa jaringan.
class _FakeMovieRepository extends MovieRepository {
  final List<String> calls = [];

  @override
  Future<void> likeMovie(int movieId) async {
    calls.add('like:$movieId');
  }

  @override
  Future<void> unlikeMovie(int movieId) async {
    calls.add('unlike:$movieId');
  }
}

/// Scroll sampai sebuah teks benar-benar terlihat dan bisa diklik.
///
/// `scrollUntilVisible` saja tidak cukup: item bisa berhenti persis di tepi
/// bawah ListView, sehingga posisinya jatuh di balik bottom navigation bar
/// dan tap-nya mendarat di navbar.
Future<void> _scrollTo(WidgetTester tester, String label) async {
  await tester.scrollUntilVisible(
    find.text(label),
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(find.text(label));
  await tester.pumpAndSettle();
}

/// Stub untuk halaman yang dipakai sebagai tujuan navigasi di test.
class _WatchedStub extends StatelessWidget {
  const _WatchedStub();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Text('Watched Stub'));
}

class _LogStub extends StatelessWidget {
  const _LogStub();
  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('Log Stub'));
}

class _WatchlistStub extends StatelessWidget {
  const _WatchlistStub();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Text('Watchlist Stub'));
}
