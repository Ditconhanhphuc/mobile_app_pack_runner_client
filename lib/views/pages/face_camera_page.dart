import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class FaceCameraPage extends StatefulWidget {
  final CameraDescription camera;
  const FaceCameraPage({required this.camera, Key? key}) : super(key: key);

  @override
  State<FaceCameraPage> createState() => _FaceCameraPageState();
}

class _FaceCameraPageState extends State<FaceCameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.low); // Thử độ phân giải thấp hơn
    _initializeControllerFuture = _controller.initialize().then((_) {
      print('Camera initialized successfully: ${widget.camera.name}');
    }).catchError((e) {
      print('Camera initialization failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera initialization failed: $e')),
      );
      return Future.error(e);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Face ID Login')),
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              print('FutureBuilder error: ${snapshot.error}');
              return Center(child: Text('Camera error: ${snapshot.error}'));
            }
            if (_controller.value.isInitialized) {
              return CameraPreview(_controller);
            }
            return Center(child: Text('Camera not initialized'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!_controller.value.isInitialized) {
            print('Camera not ready');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Camera not ready')),
            );
            return;
          }

          try {
            final image = await _controller.takePicture();
            print('Image taken: ${image.path}');
            Navigator.pop(context, image);
          } catch (e) {
            print('Error taking picture: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to take picture: $e')),
            );
          }
        },
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}