# CHORD – Simple Music Player (Flutter Web)

JNTUH R22 Flutter external project. Dark charcoal theme, purple accent, Material 3.

## Run
```
flutter pub get
flutter run -d chrome
flutter build web --release      # output: build/web
```
Needs Flutter 3.22 or newer (any recent stable release is fine).
The `web/` folder is already included. If Flutter complains about it, run `flutter create . --platforms=web` once
(it will not overwrite `lib/`) and then run the commands again.

## Folder structure
```
lib/
  main.dart                 app start, MultiProvider, MaterialApp
  theme/app_theme.dart      colours + Material 3 theme + text-field style
  models/                   Song, Playlist (plain Dart classes)
  data/sample_data.dart     6 songs + 4 popular playlists
  providers/
    player_provider.dart    playback, queue, progress, shuffle, repeat, recently played
    library_provider.dart   liked songs, saved playlists, create/edit playlists
    profile_provider.dart   user details
  screens/                  main_shell, home, search, library, playlist, player, profile
  widgets/                  SongTile, PlaylistCard/Grid, MiniPlayer, CoverArt,
                            create-playlist dialog, add-to-playlist sheet, responsive helpers
  utils/format.dart         2:05 time formatting
assets/audio/               6 royalty-free WAV tracks
tools/generate_audio.py     script that created those tracks
```

## Audio
The 6 tracks are synthesised by `tools/generate_audio.py` (sine waves + a simple scale),
so they are our own work and 100 % royalty free. Only extra package besides Provider: `audioplayers`.

## How it works (viva notes)

**State management.** Three `ChangeNotifier` classes hold the data. They are registered once with
`MultiProvider` *above* `MaterialApp`. A widget reads them with `context.watch` (rebuild on change),
`context.read` (just call a method, e.g. in `onTap`) or `context.select` (rebuild only if one value changed).
When a provider method changes data it calls `notifyListeners()` and the UI updates.

**StatefulWidget.** Used where a screen owns local, temporary state: Search (typed text, selected filter),
Library (TabController), Profile (form + text controllers), Player (slider drag value), MainShell (selected tab).
Everything else that is shared between screens lives in Provider.

**Navigation.** `Navigator.push(MaterialPageRoute(...))` opens Playlist and Player screens, `Navigator.pop` goes back.
The four main tabs are switched by changing `_index` in `MainShell` with `setState`.

**Responsive design.** `MainShell` checks `MediaQuery` width: below 600 px a bottom `NavigationBar`, 600–1000 px a
`NavigationRail`, above 1000 px an extended rail. `PageContainer` limits content width on large screens.
`PlaylistGrid` uses `SliverGridDelegateWithMaxCrossAxisExtent`, so the number of columns changes automatically.
The Player screen switches from a column (phone) to a row (tablet/desktop).

**Animations.** `Hero` – the cover image flies from playlist card to Playlist screen and from mini player to Player screen.
`AnimatedContainer` – the cover on the Player screen grows/shrinks with play/pause, and the current song row changes colour.

**Form validation.** `Form` + `GlobalKey<FormState>` + `TextFormField(validator: ...)`.
A validator returns `null` when valid or an error string. `_formKey.currentState!.validate()` runs all of them.
Rules: name (letters, min 3), email (regex), mobile (10 digits starting 6–9), bio (max 80).

**Music playback.** `PlayerProvider` owns one `AudioPlayer`. `play(song, queue:)` starts the asset,
the player's streams (`onPositionChanged`, `onDurationChanged`, `onPlayerStateChanged`, `onPlayerComplete`)
update the provider, which notifies the UI. The slider calls `seek()` when released. When a song finishes the next one starts.

**Reusable widgets.** `SongTile`, `PlaylistCard`, `CoverArt`, `MiniPlayer`, `SectionTitle`, `PageContainer`
are used on several screens, so each piece of UI is written only once.

## Likely viva questions
* *Why Provider and not setState everywhere?* Several screens need the same data (a liked song must show on Home, Search, Library and Player). Provider shares one copy.
* *Difference between `watch`, `read`, `select`?* See above.
* *Why are providers above MaterialApp?* Dialogs and bottom sheets are built below MaterialApp, so they can only find providers placed above it.
* *Why `dispose()`?* Controllers and stream subscriptions must be released to avoid memory leaks.
* *What is `notifyListeners()`?* It tells all listening widgets to rebuild.
* *Why are playlists stored as song ids?* Avoids duplicating song data; one song can be in many playlists.
* *Why a new list in `recentlyPlayed`?* `select` compares old and new values; a new list object is detected as a change, a mutated list is not.
* *Hero needs what?* The same tag on both screens, unique within one screen (so we add a prefix like `home-` / `library-`).
