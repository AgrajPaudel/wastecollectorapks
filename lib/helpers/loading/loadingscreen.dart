import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wastecollector/helpers/loading/loadingscreen_controller.dart';

class Loadingscreen {
  //singleton:only 1 instance class, everywhere this instance is used.
  factory Loadingscreen() => _shared;
  static final Loadingscreen _shared = Loadingscreen._sharedInstances();
  Loadingscreen._sharedInstances();

  LoadingScreenController? controller;

  void show({
    required BuildContext context,
    required String text,
  }) {
    if (controller?.update(text) ?? false) {
      return;
    } else {
      controller = showoverlay(
        context: context,
        text: text,
      );
    }
  }

  void hide() {
    controller?.close();
    controller = null;
  }

  //overlay displays over another function, useful for loading screens
  LoadingScreenController showoverlay({
    required BuildContext context,
    required String text,
  }) {
    final _text = StreamController<String>();
    _text.add(text); //adds text to controller.
    final state = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final overlay = OverlayEntry(builder: (context) {
      return Material(
        color:
            Colors.black.withAlpha(150), //blurs background when loading pops up
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: size.width * 0.8, //80% of width and 35% of height.
              maxHeight: size.height * 0.85,
              minWidth: size.width * 0.5,
              minHeight: size.height * 0.3,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                //to scroll if the content overflows loading screen.
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    StreamBuilder(
                        stream: _text.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data as String,
                              textAlign: TextAlign.center,
                            );
                          } else {
                            return Container();
                          }
                        })
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });

    state.insert(overlay);
    return LoadingScreenController(close: () {
      _text.close();
      overlay.remove();
      return true;
    }, update: (text) {
      _text.add(text);
      return true;
    });
  }
}
