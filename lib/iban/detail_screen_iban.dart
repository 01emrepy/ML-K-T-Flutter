import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class DetailScreenIban extends StatefulWidget {
  final String imagePath;

  const DetailScreenIban({required this.imagePath});

  @override
  _DetailScreenIbanState createState() => _DetailScreenIbanState();
}

class _DetailScreenIbanState extends State<DetailScreenIban> {
  late final String _imagePath;
  late final TextDetector _textDetector;
  Size? _imageSize;
  final List<TextElement> _elements = [];

  List<String>? _listEmailStrings;

  Future<void> _getImageSize(File imageFile) async {
    final Completer<Size> completer = Completer<Size>();

    final Image image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    final Size imageSize = await completer.future;
    setState(() {
      _imageSize = imageSize;
    });
  }

  void _recognizeEmails() async {
    _getImageSize(File(_imagePath));
    final inputImage = InputImage.fromFilePath(_imagePath);
    final text = await _textDetector.processImage(inputImage);
    String pattern =
        r"^([A-Z]{2}[ \-]?[0-9]{2})(?=(?:[ \-]?[A-Z0-9]){9,30}$)((?:[ \-]?[A-Z0-9]{3,5}){2,7})([ \-]?[A-Z0-9]{1,3})?$";
    RegExp regEx = RegExp(pattern);
    List<String> emailStrings = [];

    for (TextBlock block in text.blocks) {
      for (TextLine line in block.lines) {
        print('text: ${line.text}');
        if (regEx.hasMatch(line.text)) {
          emailStrings.add(line.text);
          for (TextElement element in line.elements) {
            _elements.add(element);
          }
        }
      }
    }

    setState(() {
      _listEmailStrings = emailStrings;
    });
  }

  @override
  void initState() {
    _imagePath = widget.imagePath;
    _textDetector = GoogleMlKit.vision.textDetector();
    _recognizeEmails();
    super.initState();
  }

  @override
  void dispose() {
    _textDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _imageSize != null
          ? Stack(
              children: [
                Container(
                  width: double.maxFinite,
                  color: Colors.black,
                  child: CustomPaint(
                    foregroundPainter: TextDetectorPainter(
                      _imageSize!,
                      _elements,
                    ),
                    child: AspectRatio(
                      aspectRatio: _imageSize!.aspectRatio,
                      child: Image.file(
                        File(_imagePath),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Card(
                    elevation: 8,
                    color: Colors.yellow,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              "Identified İban",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            height: 60,
                            child: SingleChildScrollView(
                              child: _listEmailStrings != null
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: _listEmailStrings!.length,
                                      itemBuilder: (context, index) =>
                                          Text(_listEmailStrings![index]),
                                    )
                                  : Container(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}

class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(this.absoluteImageSize, this.elements);

  final Size absoluteImageSize;
  final List<TextElement> elements;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    Rect scaleRect(TextElement container) {
      return Rect.fromLTRB(
        container.rect.left * scaleX,
        container.rect.top * scaleY,
        container.rect.right * scaleX,
        container.rect.bottom * scaleY,
      );
    }

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.red
      ..strokeWidth = 2.0;

    for (TextElement element in elements) {
      canvas.drawRect(scaleRect(element), paint);
    }
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return true;
  }
}
