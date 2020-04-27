import 'package:flutter/material.dart';
import 'package:flutter_sound/flauto.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_sound/flutter_sound_recorder.dart';
import 'dart:io';
import 'package:flutter_sound/flutter_sound_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

getAppDirectory() async {
  _appDir = await getApplicationDocumentsDirectory();
  return _appDir.path;
}

createAndGetRecordingDir() async {
  _recordings = Directory('$appDirPath/recordings/');
  if (await _recordings.exists()) {
    return _recordings.path;
  } else {
    _recordings = await _recordings.create();
    return _recordings.path;
  }
}

getAudioFiles() async {
  return Directory('$recordingsDirPath').listSync();
}

Directory _appDir;
Directory _recordings;
String appDirPath = getAppDirectory();
String recordingsDirPath = createAndGetRecordingDir();
List audioFiles = getAudioFiles();

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
            'Smart Recorder',
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
  @override
  _RecordState createState() => _RecordState();
}

class _RecordState extends State<Record> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _controller = TextEditingController();
  FlutterSoundRecorder flutterSoundRecorder = FlutterSoundRecorder();
  FlutterSoundPlayer flutterSoundPlayer = FlutterSoundPlayer();
  Icon _buttonIcon = Icon(Icons.mic, color: Colors.white, size: 50);
  bool _isRecording = false;
  AnimationController animationController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    flutterSoundRecorder.initialize();
    flutterSoundPlayer.initialize();
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
    flutterSoundRecorder.release();
    flutterSoundPlayer.release();
    animationController.dispose();
    super.dispose();
  }

  void _recordOrStopButton() {
    switch (_isRecording) {
      case (false):
        {
          _buttonIcon = Icon(
            Icons.stop,
            color: Colors.red,
            size: 50,
          );
          print('recording');
          _isRecording = true;
          _startRecording();
        }
        break;
      case (true):
        {
          _stopRecording();
          _buttonIcon = Icon(
            Icons.mic,
            color: Colors.white,
            size: 50,
          );
          print('stopping');
          _isRecording = false;
        }
        break;
    }
    animationController.reset();
  }

  _startRecording() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    File outputFile = File('$recordingsDirPath/flutter_sound-tmp.aac');
    String result = await flutterSoundRecorder.startRecorder(uri: outputFile.path, codec: t_CODEC.CODEC_AAC);
  }

  _stopRecording() async {
    String result = await flutterSoundRecorder.stopRecorder();
    _userCheck();
  }

  _userCheck() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 24.0,
          backgroundColor: Color(0xff001448),
          title: Text(
            'New Recording',
            style: TextStyle(color: Colors.white),
          ),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 0.0),
                ),
                labelText: 'File Name',
                labelStyle: TextStyle(color: Colors.white54),
              ),
              style: TextStyle(color: Colors.white),
              validator: (value) {
                return value.isEmpty ? 'File name is rquired to save' : null;
              },
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                _delete();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'Save',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                final form = _formKey.currentState;
                if (form.validate()) {
                  print('form is valid');
                  _rename(_controller.text);
                  Navigator.of(context).pop();
                } else
                  print('form is invalid');
              },
            ),
          ],
        );
      },
    );
  }

  _delete() {
    var myFile = File('$recordingsDirPath/flutter_sound-tmp.aac');
    myFile.delete();
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text('Recording Deleted'),
      ),
    );
  }

  _rename(String filename) {
    var myFile = File('$recordingsDirPath/flutter_sound-tmp.aac');
    myFile.rename('$recordingsDirPath/$filename.aac');
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text('Recording Saved'),
      ),
    );
    getAudioFiles();
    print(audioFiles);
  }

  _startPlaying() async {
    String result2 = await flutterSoundPlayer.startPlayer('$recordingsDirPath/flutter_sound-tmp.aac');
  }

  _stopPlaying() async {}

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xff000428), Color(0xff004e92)]),
      ),
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 460),
            child: AnimatedBuilder(
              animation: animationController,
              builder: (BuildContext context, Widget _widget) {
                return RotationTransition(
                  turns: animation,
                  child: RawMaterialButton(
                    padding: EdgeInsets.all(10.0),
                    fillColor: Colors.lightBlue[900],
                    elevation: 20,
                    shape: CircleBorder(),
                    splashColor: Colors.cyan,
                    child: _buttonIcon,
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
