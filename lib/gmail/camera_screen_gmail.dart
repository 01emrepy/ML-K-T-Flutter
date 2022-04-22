import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'detail_screen_gmail.dart';

class CameraScreenGmail extends StatefulWidget {
  const CameraScreenGmail({Key? key}) : super(key: key);

  @override
  _CameraScreenGmailState createState() => _CameraScreenGmailState();
}

class _CameraScreenGmailState extends State<CameraScreenGmail> {
  late CameraController _controller;
  void _initializeCamera() async {
    final CameraController cameraController = CameraController(
      cameras[0],
      ResolutionPreset.max,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    _controller = cameraController;

    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  Future<String?> _takePicture() async {
    if (!_controller.value.isInitialized) {
      print("Controller is not initialized");
      return null;
    }

    String? imagePath;

    if (_controller.value.isTakingPicture) {
      print("Processing is progress ...");
      return null;
    }

    try {
      _controller.setFlashMode(FlashMode.off);
      final XFile file = await _controller.takePicture();
      imagePath = file.path;
    } on CameraException catch (e) {
      print("Camera Exception: $e");
      return null;
    }

    return imagePath;
  }

  @override
  void initState() {
    _initializeCamera();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _controller.value.isInitialized
          ? Stack(
              children: <Widget>[
                CameraPreview(_controller),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.camera),
                      label: const Text("Click"),
                      onPressed: () async {
                        await _takePicture().then((String? path) {
                          if (path != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailScreenGmail(
                                  imagePath: path,
                                ),
                              ),
                            );
                          } else {
                            print('Image path not found!');
                          }
                        });
                      },
                    ),
                  ),
                )
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
