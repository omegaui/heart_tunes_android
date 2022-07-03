import 'package:flutter/material.dart';
import 'package:heart_tunes_android/components/track_tile.dart';
import 'package:heart_tunes_android/main.dart';

import '../io/track_manager.dart';

class TrackPanelList extends StatefulWidget {
  const TrackPanelList({Key? key}) : super(key: key);

  @override
  State<TrackPanelList> createState() => TrackPanelListState();
}

class TrackPanelListState extends State<TrackPanelList> {
  List<TrackTile> trackTiles = [];

  void rebuild() {
    setState(() {
      // just triggering rebuild
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade900,
      child: Column(
        children: (homeScreenKey.currentState?.searchMode as bool ? tracks : originallyOrderedTrackList).map((track) => TrackTile(track: track))
            .toList(),
      ),
    );
  }
}
