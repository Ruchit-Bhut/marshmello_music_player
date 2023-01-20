import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marshmello_music_player/favorite_songs.dart';
import 'package:marshmello_music_player/play_screen.dart';
import 'package:marshmello_music_player/provider/fav_song_model.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class ShowInternalMusic extends StatefulWidget {
  const ShowInternalMusic({super.key});

  @override
  State<ShowInternalMusic> createState() => _ShowInternalMusicState();
}

class _ShowInternalMusicState extends State<ShowInternalMusic> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final OnAudioQuery audioQuery = OnAudioQuery();
  final TextEditingController _searchingController = TextEditingController();

  bool isFavorite = false;

  String isSearching = '';

  Future<void> playSong(String? uri) async {
    try {
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(uri!),
        ),
      );
      await _audioPlayer.play();
    } on Exception {
      stdout.write('Error parsing song');
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<FavSongProvider>();
    requestPermission();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> requestPermission() async {
    if (!kIsWeb) {
      final permissionStatus = await audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await audioQuery.permissionsRequest();
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<SongModel>>(
        future: audioQuery.querySongs(
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        ),
        builder: (context, item) {
          if (item.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (item.data!.isEmpty) {
            return const Text('No Song Found');
          }
          return DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff100919),
                  Color(0xff110c1d),
                  Color(0xff1b0c2b),
                  Color(0xff30164e),
                  Color(0xff3b1a60),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchingController,
                          onChanged: (value) {
                            setState(() {
                              isSearching = value;
                            });
                          },
                          textCapitalization: TextCapitalization.sentences,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.grey,
                          decoration: InputDecoration(
                            fillColor: isSearching == ''
                                ? Colors.white10
                                : const Color(0xff30164e),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'Search Song ',
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                            ),
                            prefixIcon: Container(
                              padding: const EdgeInsets.all(15),
                              width: 18,
                              child: Image.asset('assets/icons/search.png'),
                            ),
                            suffixIcon: isSearching == ''
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      setState(_searchingController.clear);
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      size: 28,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      CupertinoButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (context) => FavoriteSongs(
                                songs: item.data!,
                              ),
                            ),
                          );
                        },
                        child: Image.asset(
                          'assets/icons/lover.png',
                          height: 30,
                          width: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Your Songs',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      // Text(
                      //   'See All',
                      //   style: TextStyle(color: Colors.grey, fontSize: 16),
                      // ),
                    ],
                  ),
                ),
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView.builder(
                      itemCount: item.data!.length,
                      itemBuilder: (context, index) {
                        if (item.data![index].displayName
                            .toLowerCase()
                            .startsWith(isSearching.toLowerCase())) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white10,
                            ),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            child: ListTile(
                              onTap: () {
                                context
                                    .read<FavSongProvider>()
                                    .isFav(item.data![index].id);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                    builder: (context) => PlayMusicScreen(
                                      songModel: item.data![index],
                                      audioPlayer: _audioPlayer,
                                    ),
                                  ),
                                );
                              },
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: QueryArtworkWidget(
                                  id: item.data![index].id,
                                  type: ArtworkType.AUDIO,
                                  artworkHeight: 50,
                                  artworkWidth: 50,
                                  nullArtworkWidget: Image.asset(
                                    'assets/icons/music.png',
                                    height: 50,
                                    width: 50,
                                  ),
                                ),
                              ),
                              title: Text(
                                item.data![index].displayNameWOExt,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                '${item.data![index].artist}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white60,
                                ),
                              ),
                              trailing: InkWell(
                                onTap: () {
                                  if (context.read<FavSongProvider>().isFav(
                                        item.data![index].id,
                                      )) {
                                    context
                                        .read<FavSongProvider>()
                                        .remFav(item.data![index].id);
                                  } else {
                                    context
                                        .read<FavSongProvider>()
                                        .addToFav(item.data![index].id);
                                  }
                                },
                                child: context.watch<FavSongProvider>().isFav(
                                          item.data![index].id,
                                        )
                                    ? const Icon(
                                        Icons.favorite,
                                        color: Colors.pink,
                                        size: 30,
                                      )
                                    : const Icon(
                                        Icons.favorite_outline_rounded,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                              ),
                            ),
                          );
                        }
                        if (_searchingController.text == '') {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white10,
                            ),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            child: ListTile(
                              onTap: () {
                                context
                                    .read<FavSongProvider>()
                                    .isFav(item.data![index].id);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                    builder: (context) => PlayMusicScreen(
                                      songModel: item.data![index],
                                      audioPlayer: _audioPlayer,
                                    ),
                                  ),
                                );
                                // playSong(item.data![index].uri);
                              },
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: QueryArtworkWidget(
                                  id: item.data![index].id,
                                  type: ArtworkType.AUDIO,
                                  artworkHeight: 50,
                                  artworkWidth: 50,
                                  nullArtworkWidget: Image.asset(
                                    'assets/icons/music.png',
                                    height: 50,
                                    width: 50,
                                  ),
                                ),
                              ),
                              title: Text(
                                item.data![index].displayNameWOExt,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                '${item.data![index].artist}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white60,
                                ),
                              ),
                              trailing: InkWell(
                                onTap: () {
                                  if (context.read<FavSongProvider>().isFav(
                                        item.data![index].id,
                                      )) {
                                    context
                                        .read<FavSongProvider>()
                                        .remFav(item.data![index].id);
                                  } else {
                                    context
                                        .read<FavSongProvider>()
                                        .addToFav(item.data![index].id);
                                  }
                                },
                                child: context.watch<FavSongProvider>().isFav(
                                          item.data![index].id,
                                        )
                                    ? const Icon(
                                        Icons.favorite,
                                        color: Colors.pink,
                                        size: 30,
                                      )
                                    : const Icon(
                                        Icons.favorite_outline_rounded,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                              ),
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// class showMusic extends StatelessWidget {
//
//   int index;
//
//    showMusic({Key? key,required this.index}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//
//     final AudioPlayer _audioPlayer = AudioPlayer();
//     final OnAudioQuery audioQuery = OnAudioQuery();
//
//     bool isFavorite = false;
//
//
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: Colors.white10,
//       ),
//       margin: const EdgeInsets.symmetric(
//         horizontal: 10,
//         vertical: 4,
//       ),
//       child: ListTile(
//         onTap: () {
//           context
//               .read<SongModelProvider>()
//               .setId(item.data![index].id);
//           Navigator.push(
//             context,
//             MaterialPageRoute<dynamic>(
//               builder: (context) => PlayMusicScreen(
//                 songModel: item.data![index],
//                 audioPlayer: _audioPlayer,
//               ),
//             ),
//           );
//           // playSong(item.data![index].uri);
//         },
//         leading: ClipRRect(
//           borderRadius: BorderRadius.circular(10),
//           child: QueryArtworkWidget(
//             id: item.data![index].id,
//             type: ArtworkType.AUDIO,
//             artworkHeight: 50,
//             artworkWidth: 50,
//             nullArtworkWidget: Image.asset(
//               'assets/icons/music.png',
//               height: 50,
//               width: 50,
//             ),
//           ),
//         ),
//         title: Text(
//           item.data![index].displayNameWOExt,
//           style: const TextStyle(
//             fontSize: 15,
//             color: Colors.white,
//           ),
//         ),
//         subtitle: Text(
//           '${item.data![index].artist}',
//           style: const TextStyle(
//             fontSize: 13,
//             color: Colors.white60,
//           ),
//         ),
//         trailing: InkWell(
//           onTap: () {
//             if (context
//                 .read<FavSongProvider>()
//                 .isFav(item.data![index].id)) {
//               context
//                   .read<FavSongProvider>()
//                   .remFav(item.data![index].id);
//             } else {
//               context
//                   .read<FavSongProvider>()
//                   .addToFav(item.data![index].id);
//             }
//           },
//           child: context
//               .watch<FavSongProvider>()
//               .isFav(item.data![index].id)
//               ? const Icon(
//             Icons.favorite,
//             color: Colors.pink,
//             size: 30,
//           )
//               : const Icon(
//             Icons.favorite_outline_rounded,
//             color: Colors.white,
//             size: 30,
//           ),
//         ),
//       ),
//     );
//
//   }
// }
