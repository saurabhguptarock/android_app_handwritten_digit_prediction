import 'package:flutter/material.dart';
import 'service.dart' show response;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hand Written Digit Prediction',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ByteData imgBytes;
  int res = 0;
  List<Offset> _points = <Offset>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              '$res',
              style: TextStyle(fontSize: 20),
            ),
            Container(
              height: 300,
              width: 300,
              color: Colors.black,
              child: GestureDetector(
                onPanUpdate: (DragUpdateDetails details) {
                  setState(() {
                    RenderBox object = context.findRenderObject();
                    Offset _localPosition =
                        object.globalToLocal(details.localPosition);
                    _points = new List.from(_points)..add(_localPosition);
                  });
                },
                onPanEnd: (DragEndDetails details) => _points.add(null),
                child: CustomPaint(
                  painter: Signature(points: _points),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: RaisedButton(
                    child: Text('Predict'),
                    onPressed: generateImage,
                    color: Colors.green,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: RaisedButton(
                    child: Text('Clear'),
                    onPressed: () => _points.clear(),
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void generateImage() async {
    final recorder = ui.PictureRecorder();
    final canvas =
        Canvas(recorder, Rect.fromPoints(Offset(0.0, 0.0), Offset(200, 200)));

    final stroke = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTWH(0.0, 0.0, 200, 200), stroke);

    final picture = recorder.endRecording();
    final img = await picture.toImage(96, 96);
    final pngBytes = await img.toByteData(format: ImageByteFormat.png);

    Uint8List audioUint8List = pngBytes.buffer
        .asUint8List(pngBytes.offsetInBytes, pngBytes.lengthInBytes);
    List<int> audioListInt = audioUint8List.cast<int>();
    String base64Image = base64Encode(audioListInt);
    print(base64Image);
    response(base64Image).then((vars) {
      setState(() {
        res = json.decode(vars)['prediction'];
      });
    }).catchError((err) {
      print(err);
    });
  }
}

class Signature extends CustomPainter {
  List<Offset> points;
  Signature({this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 15.0;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(Signature oldDelegate) => oldDelegate.points != points;
}
