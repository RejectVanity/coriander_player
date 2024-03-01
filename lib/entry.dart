import 'package:coriander_player/audio_library.dart';
import 'package:coriander_player/component/app_shell.dart';
import 'package:coriander_player/page/album_detail_page/page.dart';
import 'package:coriander_player/page/albums_page/page.dart';
import 'package:coriander_player/page/artist_detail_page/page.dart';
import 'package:coriander_player/page/artists_page/page.dart';
import 'package:coriander_player/page/audios_page/page.dart';
import 'package:coriander_player/page/folders_page/page.dart';
import 'package:coriander_player/page/now_playing_page/page.dart';
import 'package:coriander_player/page/playlists_page/page.dart';
import 'package:coriander_player/page/search_page/search_page.dart';
import 'package:coriander_player/page/search_page/single_result.dart';
import 'package:coriander_player/page/search_page/union_result.dart';
import 'package:coriander_player/page/settings_page/page.dart';
import 'package:coriander_player/page/updating_dialog/dialog.dart';
import 'package:coriander_player/page/welcoming_page/page.dart';
import 'package:coriander_player/playlist.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;

class SlideTransitionPage<T> extends CustomTransitionPage<T> {
  const SlideTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionsBuilder: _transitionsBuilder,
          transitionDuration: const Duration(milliseconds: 150),
          reverseTransitionDuration: const Duration(milliseconds: 150),
        );

  static Widget _transitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final tween = Tween(
      begin: const Offset(0, 0.10),
      end: const Offset(0, 0),
    );

    return SlideTransition(
      position: tween.animate(
        CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
      ),
      child: child,
    );
  }
}

class Entry extends StatelessWidget {
  Entry({super.key, required this.welcom});
  final bool welcom;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: ThemeProvider.instance,
      builder: (context, _) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          platform: TargetPlatform.windows,
        ),
        localizationsDelegates: const [GlobalMaterialLocalizations.delegate],
        supportedLocales: supportedLocales,
        routerConfig: config,
      ),
    );
  }

  late final GoRouter config = GoRouter(
    initialLocation:
        welcom ? app_paths.WELCOMING_PAGE : app_paths.UPDATING_DIALOG,
    routes: [
      ShellRoute(
        builder: (context, state, page) => AppShell(page: page),
        routes: [
          /// audios page
          GoRoute(
            path: app_paths.AUDIOS_PAGE,
            pageBuilder: (context, state) {
              /// such as /audios?target=20, push to audios page
              /// then scroll to the 20th audio of the [AudioLibrary] allAudios list.
              if (state.uri.hasQuery) {
                final targetStr = state.uri.queryParameters["target"];
                final target = int.tryParse(targetStr ?? "") ?? 0;
                return SlideTransitionPage(child: AudiosPage(target: target));
              }
              return const SlideTransitionPage(child: AudiosPage());
            },
          ),

          /// artists page
          GoRoute(
            path: app_paths.ARTISTS_PAGE,
            pageBuilder: (context, state) => const SlideTransitionPage(
              child: ArtistsPage(),
            ),
            routes: [
              GoRoute(
                path: "detail",
                pageBuilder: (context, state) => SlideTransitionPage(
                  child: ArtistDetailPage(artist: state.extra as Artist),
                ),
              ),
            ],
          ),

          /// albums page
          GoRoute(
            path: app_paths.ALBUMS_PAGE,
            pageBuilder: (context, state) => const SlideTransitionPage(
              child: AlbumsPage(),
            ),
            routes: [
              GoRoute(
                path: "detail",
                pageBuilder: (context, state) => SlideTransitionPage(
                  child: AlbumDetailPage(album: state.extra as Album),
                ),
              ),
            ],
          ),

          /// folders page
          GoRoute(
            path: app_paths.FOLDERS_PAGE,
            pageBuilder: (context, state) => const SlideTransitionPage(
              child: FoldersPage(),
            ),
            routes: [
              /// folder detail page
              GoRoute(
                path: "detail",
                pageBuilder: (context, state) {
                  final folder = state.extra as AudioFolder;
                  return SlideTransitionPage(
                    child: FolderDetailPage(folder: folder),
                  );
                },
              ),
            ],
          ),

          /// playlists page
          GoRoute(
            path: app_paths.PLAYLISTS_PAGE,
            pageBuilder: (context, state) => const SlideTransitionPage(
              child: PlaylistsPage(),
            ),
            routes: [
              GoRoute(
                path: "detail",
                pageBuilder: (context, state) {
                  final playlist = state.extra as Playlist;
                  return SlideTransitionPage(
                    child: PlaylistDetailPage(playlist: playlist),
                  );
                },
              ),
            ],
          ),

          /// search page
          GoRoute(
            path: app_paths.SEARCH_PAGE,
            pageBuilder: (context, state) => const SlideTransitionPage(
              child: SearchPage(),
            ),
            routes: [
              GoRoute(
                path: "union",
                pageBuilder: (context, state) {
                  final result = state.extra as UnionSearchResult;
                  return SlideTransitionPage(
                    child: UnionSearchResultPage(result: result),
                  );
                },
              ),
              GoRoute(
                path: "audioresult",
                pageBuilder: (context, state) {
                  final result = state.extra as List<MapEntry<Audio, int>>;
                  return SlideTransitionPage(
                    child: AudioSearchResultPage(result: result),
                  );
                },
              ),
              GoRoute(
                path: "artistresult",
                pageBuilder: (context, state) {
                  final result = state.extra as List<Artist>;
                  return SlideTransitionPage(
                    child: ArtistSearchResultPage(result: result),
                  );
                },
              ),
              GoRoute(
                path: "albumresult",
                pageBuilder: (context, state) {
                  final result = state.extra as List<Album>;
                  return SlideTransitionPage(
                    child: AlbumSearchResultPage(result: result),
                  );
                },
              ),
            ],
          ),

          /// settings page
          GoRoute(
            path: app_paths.SETTINGS_PAGE,
            pageBuilder: (context, state) => const SlideTransitionPage(
              child: SettingsPage(),
            ),
          ),
        ],
      ),

      /// now playing page
      GoRoute(
        path: app_paths.NOW_PLAYING_PAGE,
        pageBuilder: (context, state) => CustomTransitionPage(
          maintainState: false,
          transitionsBuilder: (context, animation, _, child) {
            final tween = Tween(
              begin: const Offset(0, 1),
              end: const Offset(0, 0),
            );

            return SlideTransition(
              position: tween.animate(
                CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
              ),
              child: child,
            );
          },
          child: const NowPlayingPage(),
        ),
      ),

      /// welcoming page
      GoRoute(
        path: app_paths.WELCOMING_PAGE,
        pageBuilder: (context, state) => const SlideTransitionPage(
          child: WelcomingPage(),
        ),
      ),

      /// updating dialog
      GoRoute(
        path: app_paths.UPDATING_DIALOG,
        pageBuilder: (context, state) => const SlideTransitionPage(
          child: UpdatingDialog(),
        ),
      ),
    ],
  );

  final supportedLocales = const [
    Locale.fromSubtags(languageCode: 'zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    Locale.fromSubtags(
        languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'),
    Locale.fromSubtags(
        languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
    Locale.fromSubtags(
        languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK'),
    Locale("en", "US"),
  ];
}