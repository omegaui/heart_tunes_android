
// ignore_for_file: avoid_init_to_null

import 'package:heart_tunes_android/io/app_data_manager.dart';
import 'package:heart_tunes_android/io/file_provider.dart';
import 'package:heart_tunes_android/io/track_data.dart';

import '../screens/home_screen.dart';

Track? _currentlyPlayingTrack = null;

List<Track> originallyOrderedTrackList = [
  // Original ordered list of added tracks
];

List<Track> tracks = [
  // List of added tracks
];

void shuffle(){
  rebase();
  tracks.shuffle();
}

void rebase(){
  tracks.clear();
  tracks.addAll(originallyOrderedTrackList);
}

Future<void> showTrackPickerDialog() async {
  List<Track> txs = await pickTracks();
  if(txs.isNotEmpty){
    for (var track in txs) {
      addTrack(track);
    }
    trackListPanelKey.currentState?.rebuild();
  }
}

void onlyPlay(Track track){
  for(var track in tracks){
    track.trackPlayerService.stop();
  }
  putToView(track);
}

void putToView(Track track){
  if(_currentlyPlayingTrack == track){
    if(!track.trackPlayerService.playing) {
      track.trackPlayerService.play();
    }
    return;
  }
  _currentlyPlayingTrack = track;
  trackControlsKey.currentState?.listen(track);
}

void shiftTowardsPreviousTrack(Track track){
  int index = tracks.indexOf(track);
  track.trackPlayerService.stop();
  if(index > 0){
    putToView(tracks.elementAt(index - 1));
  }
  else{
    track.trackPlayerService.replay();
  }
}

void shiftTowardsNextTrack(Track track){
  int index = tracks.indexOf(track);
  track.trackPlayerService.stop();
  if(index < tracks.length - 1){
    putToView(tracks.elementAt(index + 1));
  }
  else{
    track.trackPlayerService.replay();
  }
}

void searchFor(String text){
  if(text.isEmpty){
    rebase();
    return;
  }
  List<Track> results = [];
  for(var track in originallyOrderedTrackList){
    if(track.trackMetaDataService.getTitle().contains(text)){
      results.add(track);
    }
  }
  tracks.clear();
  tracks.addAll(results);
}

