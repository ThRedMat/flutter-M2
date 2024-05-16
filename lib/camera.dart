import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late Future<CameraController> _cameraInitializationFuture;
  late List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    _cameraInitializationFuture = initializeCamera();
  }

  // Initialiser la caméra
  Future<CameraController> initializeCamera() async {
    cameras = await availableCameras();
    final controller = CameraController(cameras[0], ResolutionPreset.medium);
    await controller.initialize();
    return controller;
  }

  @override
  void dispose() {
    _cameraInitializationFuture.then((controller) => controller.dispose());
    super.dispose();
  }

  void _onCaptureButtonPressed() async {
    final CameraController controller = await _cameraInitializationFuture;
    try {
      final XFile file = await controller.takePicture();

      // Faites quelque chose avec le fichier, par exemple l'afficher dans une nouvelle page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CapturedImagePreview(imagePath: file.path),
        ),
      );
    } catch (e) {
      // Gérer les erreurs liées à la capture d'image
      print('Erreur lors de la capture d\'image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR Code'),
      ),
      body: FutureBuilder<CameraController>(
        future: _cameraInitializationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // La caméra est initialisée, afficher la prévisualisation si snapshot.data n'est pas null
            if (snapshot.hasData) {
              return CameraPreview(snapshot.data!);
            } else {
              // Gérer le cas où snapshot.data est null
              return const Center(
                  child: Text('La caméra n\'a pas pu être initialisée.'));
            }
          } else {
            // Afficher un indicateur de chargement pendant l'initialisation
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCaptureButtonPressed,
        child: const Icon(Icons.camera),
      ),
    );
  }
}

class CapturedImagePreview extends StatelessWidget {
  final String imagePath;

  const CapturedImagePreview({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Capturée'),
      ),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}
