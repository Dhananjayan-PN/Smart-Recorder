import 'package:flutter/material.dart';
import 'package:flutter_sound/flauto.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_sound/flutter_sound_recorder.dart';
import 'dart:io';
import 'dart:async';
import 'package:share/share.dart';
import 'package:flutter_sound/flutter_sound_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

Directory appDir;
List audioFiles = List();

void main() {
  runApp(MyApp());
}

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
  getData() async {
    appDir = await getApplicationDocumentsDirectory();
    List files = Directory(appDir.path).listSync();
    for (var i = 0; i < files.length; i++) {
      if (files.elementAt(i).path.split('.').last == 'aac') {
        audioFiles.add(files.elementAt(i));
      }
    }
    audioFiles.toSet().toList();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

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

class _RecordState extends State<Record> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<Record> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _controller = TextEditingController();
  FlutterSoundRecorder flutterSoundRecorder = FlutterSoundRecorder();
  Icon _buttonIcon = Icon(Icons.mic, color: Colors.white, size: 50);
  bool _isRecording = false;
  AnimationController animationController;
  AnimationController animationController2;
  Animation<double> animation;
  String stopWatchTime = "00:00:00";
  var stopWatch = Stopwatch();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    flutterSoundRecorder.initialize();
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
    animationController.dispose();
    super.dispose();
  }

  _updateAudioFiles() {
    audioFiles = List();
    List files = Directory(appDir.path).listSync();
    for (var i = 0; i < files.length; i++) {
      if (files.elementAt(i).path.split('.').last == 'aac') {
        audioFiles.add(files.elementAt(i));
      }
    }
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

  void startTimer() {
    Timer(Duration(seconds: 1), keepRunning);
  }

  void keepRunning() {
    if (stopWatch.isRunning) startTimer();
    setState(() {
      stopWatchTime = stopWatch.elapsed.inHours.toString().padLeft(2, "0") +
          ":" +
          (stopWatch.elapsed.inMinutes % 60).toString().padLeft(2, "0") +
          ":" +
          (stopWatch.elapsed.inSeconds % 60).toString().padLeft(2, "0");
    });
  }

  _startRecording() async {
    File outputFile = File('${appDir.path}/flutter_sound-tmp.aac');
    String result = await flutterSoundRecorder.startRecorder(uri: outputFile.path, codec: t_CODEC.CODEC_AAC);
    stopWatch.start();
    startTimer();
    setState(() {
      _isRecording = true;
    });
  }

  _stopRecording() async {
    String result = await flutterSoundRecorder.stopRecorder();
    stopWatch.stop();
    stopWatch.reset();
    stopWatchTime = "00:00:00";
    _userCheck();
    print(audioFiles);
    setState(() {
      _isRecording = false;
    });
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
    var myFile = File('${appDir.path}/flutter_sound-tmp.aac');
    myFile.delete();
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text('Recording Deleted'),
      ),
    );
    _updateAudioFiles();
  }

  _rename(String filename) {
    var myFile = File('${appDir.path}/flutter_sound-tmp.aac');
    myFile.rename('${appDir.path}/$filename.aac');
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text('Recording Saved'),
      ),
    );
    _updateAudioFiles();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xff000428), Color(0xff004e92)]),
      ),
      child: ListView(
        children: <Widget>[
          if (_isRecording == false)
            Padding(
              padding: EdgeInsets.only(top: 170),
              child: Container(
                child: CustomPaint(
                  painter: VisualizerPainter1(),
                  child: Container(
                    child: Center(
                      child: Text(
                        '00:00:00',
                        style: TextStyle(
                          fontSize: 50,
                          color: Colors.black,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_isRecording == true)
            Padding(
              padding: EdgeInsets.only(top: 170),
              child: Container(
                child: CustomPaint(
                  painter: VisualizerPainter2(),
                  child: Container(
                    child: Center(
                      child: Text(
                        stopWatchTime,
                        style: TextStyle(
                          fontSize: 50,
                          color: Colors.red,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(top: 240),
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

class _RecordingsState extends State<Recordings> with SingleTickerProviderStateMixin {
  FlutterSoundPlayer flutterSoundPlayer = FlutterSoundPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    flutterSoundPlayer.initialize();s
  }

  @override
  void dispose() {
    flutterSoundPlayer.release();
    super.dispose();
  }

  _updateAudioFiles() {
    audioFiles = List();
    List files = Directory(appDir.path).listSync();
    for (var i = 0; i < files.length; i++) {
      if (files.elementAt(i).path.split('.').last == 'aac') {
        audioFiles.add(files.elementAt(i));
      }
    }
  }

  _startPlaying(String filename) async {
    String result = await flutterSoundPlayer.startPlayer('${appDir.path}/$filename.aac');
  }

  _stopPlaying() async {
    String result = await flutterSoundPlayer.stopPlayer();
  }

  _delete(String filename) {
    var myFile = File('${appDir.path}/$filename.aac');
    myFile.delete();
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text('Recording Deleted'),
      ),
    );
    _updateAudioFiles();
  }

  OverlayEntry player = OverlayEntry(builder: (context) {
    final size = MediaQuery.of(context).size;
    print(size.width);
    return Positioned(
      width: size.width,
      height: 150,
      top: size.height - 150,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.rectangle, color: Color(0xff000428)),
        ),
      ),
    );
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xff000428), Color(0xff004e92)]),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 10),
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: audioFiles.length,
          itemBuilder: (context, index) {
            return Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: 35,
                  ),
                  title: Text(
                    audioFiles.elementAt(index).path.split('/').last.split('.').first,
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Wrap(
                    children: <Widget>[
                      IconButton(icon: Icon(Icons.share, color: Colors.blue), onPressed: () {}),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _delete(audioFiles.elementAt(index).path.split('/').last.split('.').first);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    if (!_isPlaying) {
                      Overlay.of(context).insert(player);
                      _startPlaying(audioFiles.elementAt(index).path.split('/').last.split('.').first);
                    }
                    if (_isPlaying) {
                      _stopPlaying();
                      player.remove();
                    }
                    setState(() {
                      _isPlaying = !_isPlaying;
                    });
                  },
                ),
                Divider(color: Colors.black54)
              ],
            );
          },
        ),
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

class VisualizerPainter1 extends CustomPainter {
  var wavePaint = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2.0;
    double centerY = size.height / 2.0;
    canvas.drawCircle(Offset(centerX, centerY), 120.0, wavePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class VisualizerPainter2 extends CustomPainter {
  var wavePaint = Paint()
    ..color = Colors.red[700]
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2.0;
    double centerY = size.height / 2.0;
    canvas.drawCircle(Offset(centerX, centerY), 120.0, wavePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
