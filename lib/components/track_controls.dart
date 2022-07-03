// ignore_for_file: avoid_init_to_null

import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import '../io/app_data_manager.dart';
import '../io/resource_provider.dart';
import '../io/track_data.dart';
import '../io/track_manager.dart';

final colorizeColors = [
  Colors.grey,
  Colors.grey.shade500,
  Colors.grey.shade700,
  Colors.grey.shade300
];

const colorizeTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

final List<Track> controlsInitializedTracks = [];

class TrackControls extends StatefulWidget {
  const TrackControls({Key? key}) : super(key: key);

  @override
  State<TrackControls> createState() => TrackControlsState();
}

class TrackControlsState extends State<TrackControls> {
  late Track? track = null;
  double currentPosition = 0;
  Duration? maxDuration = const Duration(seconds: 0);
  String currentPositionText = "0:0";
  bool shuffleOn = false;
  int repeatType = 0; // 0 - off, 1 - repeat to and fro, 2 - repeat current

  IconData getRepeatIcon() {
    if (repeatType == 1) {
      return Icons.repeat_on_outlined;
    } else if (repeatType == 2) {
      return Icons.repeat_one_on_outlined;
    }
    return Icons.repeat;
  }

  void toggleRepeatType() {
    setState(() {
      if (repeatType != 2) {
        repeatType++;
      } else {
        repeatType = 0;
      }
      appSettingsStore.put('repeat-type', repeatType);
    });
  }

  void listen(Track track) {
    this.track = track;

    appSettingsStore.put('last-active-track', jsonDecode(track.toString()));

    maxDuration = track.trackPlayerService.duration as Duration;
    if (!controlsInitializedTracks.contains(track)) {
      track.trackPlayerService.onPlayerStateChangedList.add((event) {
        rebuild();
      });
      track.trackPlayerService.onPlayerCompleteList.add(() {
        if (repeatType == 2) {
          track.trackPlayerService.replay();
        } else if (repeatType == 1) {
          int index = tracks.indexOf(track);
          if (index == tracks.length - 1) {
            putToView(tracks.first);
          } else if (index < tracks.length - 1) {
            shiftTowardsNextTrack(track);
          }
        }
        rebuild();
      });
      track.trackPlayerService.onPositionChangedList.add((event) async {
        currentPosition = event.inSeconds.toDouble();
        currentPositionText =
            await track.trackPlayerService.getCurrentPosition();
        rebuild();
      });
      controlsInitializedTracks.add(track);
    }
    this.track?.trackPlayerService.play();
  }

  void rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (track == null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade800.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Image(
                          image: appIcon120,
                          width: 60,
                          height: 60,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Image(
                          image: micIcon60,
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Heart Tunes",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "v1.0",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Proudly Hosted on GitHub",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Written with 💕 by",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AnimatedTextKit(
                      animatedTexts: [
                        ColorizeAnimatedText(
                          '@omegaui',
                          textStyle: colorizeTextStyle,
                          colors: colorizeColors,
                        ),
                      ],
                      isRepeatingAnimation: true,
                      repeatForever: true,
                      onTap: () {
                        // opening my GitHub profile
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
    maxDuration = track?.trackPlayerService.duration;
    maxDuration ??= const Duration(seconds: 0);
    if (appSettingsStore != null) {
      dynamic repeatTypeProperty = appSettingsStore.get('repeat-type');
      if (repeatTypeProperty != null) {
        repeatType = repeatTypeProperty as int;
      }
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: track?.trackPlayerService.playing as bool
              ? Colors.blue.shade900.withOpacity(0.1)
              : Colors.grey.shade800.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 150,
                child: SliderTheme(
                  data: SliderThemeData(
                    thumbColor: track?.trackPlayerService.playing as bool
                        ? Colors.white
                        : Colors.grey.shade400,
                    thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 8),
                    activeTrackColor: track?.trackPlayerService.playing as bool
                        ? Colors.grey
                        : Colors.grey.shade600,
                    activeTickMarkColor: Colors.white,
                    overlayColor: Colors.white.withOpacity(0.2),
                    valueIndicatorColor: Colors.white,
                    valueIndicatorTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                    trackHeight: 2,
                  ),
                  child: Slider(
                    label: "Volume ${track?.trackPlayerService.getVolumeLevel()}",
                    max: 1,
                    min: 0,
                    value: track?.trackPlayerService.volume as double,
                    onChanged: (value) {
                      setState(() {
                        track?.trackPlayerService.setVolume(value);
                      });
                    },
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image(
                    image: track?.trackMetaDataService.getArtworkImage(),
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    track?.trackMetaDataService.getTitle() as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => (shuffleOn
                              ? const LinearGradient(
                                  colors: [Colors.green, Colors.blue])
                              : LinearGradient(colors: [
                                  Colors.grey.shade200,
                                  Colors.grey.shade700
                                ]))
                          .createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            shuffleOn = !shuffleOn;
                            if (shuffleOn) {
                              shuffle();
                            } else {
                              rebase();
                            }
                          });
                        },
                        icon: Icon(shuffleOn
                            ? Icons.shuffle_on_outlined
                            : Icons.shuffle),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if(repeatType == 2){
                          track?.trackPlayerService.replay();
                          return;
                        }
                        shiftTowardsPreviousTrack(track as Track);
                      },
                      icon: const Icon(
                        Icons.arrow_left,
                        color: Colors.white,
                      ),
                      iconSize: 30,
                      splashRadius: 30,
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          track?.trackPlayerService.togglePlay();
                        });
                      },
                      icon: Icon(
                        track?.trackPlayerService.playing as bool
                            ? Icons.pause_circle_outline_rounded
                            : Icons.play_circle_outline_rounded,
                        color: Colors.white,
                      ),
                      iconSize: 30,
                      splashRadius: 30,
                    ),
                    IconButton(
                      onPressed: () {
                        if(repeatType == 2){
                          track?.trackPlayerService.replay();
                          return;
                        }
                        shiftTowardsNextTrack(track as Track);
                      },
                      icon: const Icon(
                        Icons.arrow_right,
                        color: Colors.white,
                      ),
                      iconSize: 30,
                      splashRadius: 30,
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) => (repeatType != 0
                              ? const LinearGradient(
                                  colors: [Colors.orange, Colors.purple])
                              : LinearGradient(colors: [
                                  Colors.grey.shade200,
                                  Colors.grey.shade700
                                ]))
                          .createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child: IconButton(
                        onPressed: () {
                          toggleRepeatType();
                        },
                        icon: Icon(getRepeatIcon()),
                      ),
                    ),
                  ],
                ),
                Text(
                  "$currentPositionText/${track?.trackPlayerService.durationString}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SliderTheme(
                  data: SliderThemeData(
                    thumbColor: track?.trackPlayerService.playing as bool
                        ? Colors.green
                        : Colors.grey.shade400,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8),
                    activeTrackColor: track?.trackPlayerService.playing as bool
                        ? Colors.blue
                        : Colors.grey.shade400,
                    activeTickMarkColor: Colors.white,
                    overlayColor: Colors.white.withOpacity(0.2),
                    valueIndicatorColor: Colors.white,
                    valueIndicatorTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                    trackHeight: 2,
                  ),
                  child: Slider(
                    label: currentPositionText,
                    max: maxDuration?.inSeconds.toDouble() as double,
                    value: currentPosition,
                    onChanged: (value) {
                      setState(() {
                        currentPosition = value;
                        track?.trackPlayerService.seek(value.toInt());
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
