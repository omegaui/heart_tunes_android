

import 'package:flutter/material.dart';
import 'package:heart_tunes_android/io/app_data_manager.dart';

import '../components/track_controls.dart';
import '../components/track_panel_list.dart';
import '../io/track_manager.dart';

final GlobalKey<TrackPanelListState> trackListPanelKey = GlobalKey();
final GlobalKey<TrackControlsState> trackControlsKey = GlobalKey();

final TextEditingController searchFieldController = TextEditingController();

class HomeScreen extends StatefulWidget{
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {

  bool searchMode = false;
  bool autoplayEnabled = false;

  void rebuild(){
    setState(() {
      // just triggering widget rebuild
    });
  }

  @override
  Widget build(BuildContext context) {
    if(appSettingsStore != null) {
      dynamic autoplayOnProperty = appSettingsStore.get('autoplay');
      if (autoplayOnProperty != null) {
        autoplayEnabled = autoplayOnProperty as bool;
      }
    }
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Material(
                  color: Colors.transparent,
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(colors: [Colors.grey.shade500, Colors.grey.shade800]).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          searchMode = !searchMode;
                          if(!searchMode){
                            rebase();
                            trackListPanelKey.currentState?.rebuild();
                          }
                        });
                      },
                      icon: const Icon(
                        Icons.search,
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade700]).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: IconButton(
                      onPressed: () async {
                        await showTrackPickerDialog();
                      },
                      icon: const Icon(Icons.add_circle),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(colors: [autoplayEnabled ? Colors.white : Colors.grey, Colors.grey.shade700]).createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: const Text(
                    "Hotshot Autoplay",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Switch(
                  onChanged: (value) {
                    setState(() {
                      autoplayEnabled = value;
                      appSettingsStore.put('autoplay', autoplayEnabled);
                    });
                  },
                  value: autoplayEnabled,
                ),
              ],
            ),
            Expanded(child: SingleChildScrollView(primary: true, child: TrackPanelList(key: trackListPanelKey))),
            SizedBox(
              height: 180,
              child: TrackControls(key: trackControlsKey),
            ),
          ],
        ),
        Visibility(
          visible: !searchMode,
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(colors: [Colors.grey.shade300, Colors.grey]).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: const Text(
                      "Heart Tunes",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    "Multi Track Music Player",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: searchMode,
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 50, 0, 0),
              child: SizedBox(
                width: 200,
                height: 30,
                child: TextField(
                  controller: searchFieldController,
                  focusNode: FocusNode(
                    onKey: (node, key) {
                      searchFor(searchFieldController.text);
                      trackListPanelKey.currentState?.rebuild();
                      return KeyEventResult.ignored;
                    },
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  cursorColor: Colors.grey,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.transparent)),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.transparent)),
                    disabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.transparent)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.transparent)),
                    hintText: "Search Tracks",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
