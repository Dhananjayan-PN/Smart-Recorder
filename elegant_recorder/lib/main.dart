import 'package:flutter/material.dart';
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
  @override
  _RecordState createState() => _RecordState();
}

class _RecordState extends State<Record> {
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xff000428), Color(0xff004e92)]),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 470),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xff004e92),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 5.0,
                    spreadRadius: 5.0,
                  )
                ],
              ),
              child: IconButton(
                splashColor: Colors.cyan,
                iconSize: 50,
                icon: Icon(
                  Icons.mic,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    if (_isRecording == true) _isRecording = false;
                    if (_isRecording == false) _isRecording = true;
                  });
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
