import 'package:flutter/material.dart';
import 'dart:math';
import 'package:file/file.dart';
import 'package:file/local.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: GradientAppBar(
          leading: Padding(
            padding: EdgeInsets.only(left: 20, top: 5),
            child: Icon(
              Icons.mic,
              size: 30,
            ),
          ),
          elevation: 30,
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff000428), Color(0xff004e92)]),
          title: Text(
            'Elegant Recorder',
            style: TextStyle(fontSize: 20),
          ),
          actions: <Widget>[
            PopupMenuButton(
              offset: Offset(0, 50),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  child: Text('Settings'),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Text('Rate the app'),
                )
              ],
              onSelected: (value) {
                if (value == 1) {
                  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: Settings()));
                }
                if (value == 2) {}
              },
            )
          ],
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                text: 'Record',
              ),
              Tab(
                text: 'Recordings',
              )
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Record(),
            Recordings(),
          ],
        ),
      ),
    );
  }
}

class Record extends StatefulWidget {
  final LocalFileSystem localFileSystem;
  Record({localFileSystem}) : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  _RecordState createState() => _RecordState();
}

class _RecordState extends State<Record> with SingleTickerProviderStateMixin {
  Recording _recording = new Recording();
  Icon _buttonIcon = Icon(Icons.mic, color: Colors.white);
  bool _isRecording = false;
  AnimationController animationController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: 1,
      ),
    )..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _recordOrStopButton();
        }
      });
    animation = CurvedAnimation(parent: animationController, curve: Curves.easeInBack);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void _recordOrStopButton() {
    switch (_isRecording) {
      case (false):
        {
          _buttonIcon = Icon(Icons.stop, color: Colors.red);
          print('recording');
          _start();
        }
        break;
      case (true):
        {
          _buttonIcon = Icon(Icons.mic, color: Colors.white);
          print('stopping');
          _stop();
        }
        break;
    }
    animationController.reset();
  }

  _start() async {
    try {
      if (await AudioRecorder.hasPermissions) {
        await AudioRecorder.start(path: "test", audioOutputFormat: AudioOutputFormat.WAV);
        bool isRecording = await AudioRecorder.isRecording;
        setState(() {
          _recording = Recording(duration: Duration(), path: "test");
          _isRecording = isRecording;
        });
      } else {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text("You must accept the permissions")));
        setState(() {
          _buttonIcon = Icon(Icons.mic, color: Colors.white);
        });
        print('stopping');
      }
    } catch (e) {
      print(e);
    }
  }

  _stop() async {
    var recording = await AudioRecorder.stop();
    print("Stop recording: ${recording.path}");
    bool isRecording = await AudioRecorder.isRecording;
    File file = widget.localFileSystem.file(recording.path);
    print("  File length: ${await file.length()}");
    setState(() {
      _recording = recording;
      _isRecording = isRecording;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xff000428), Color(0xff004e92)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 460),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.lightBlue[900],
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 5.0,
                    spreadRadius: 5.0,
                  )
                ],
              ),
              child: AnimatedBuilder(
                animation: animationController,
                builder: (BuildContext context, Widget _widget) {
                  return RotationTransition(
                    turns: animation,
                    child: IconButton(
                      splashColor: Colors.cyan,
                      iconSize: 45,
                      icon: _buttonIcon,
                      onPressed: () {
                        setState(
                          () {
                            animationController.forward();
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Recordings extends StatefulWidget {
  @override
  _RecordingsState createState() => _RecordingsState();
}

class _RecordingsState extends State<Recordings> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xff000428), Color(0xff004e92)]),
      ),
    );
  }
}

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 30,
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff000428), Color(0xff004e92)]),
        title: Text(
          'Settings',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xff000428), Color(0xff004e92)]),
        ),
      ),
    );
  }
}
