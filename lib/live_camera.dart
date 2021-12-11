// ignore_for_file: avoid_unnecessary_containers, sized_box_for_whitespace

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class LiveCamera extends StatefulWidget {
  const LiveCamera({Key? key}) : super(key: key);

  @override
  _LiveCameraState createState() => _LiveCameraState();
}

class _LiveCameraState extends State<LiveCamera> {
  bool takePicture = false;
  String resultText = 'Fetching results...';

  List<CameraDescription>? cameras;
  CameraController? cameraController;

  Future<void>? detectCameras() async {
    cameras = await availableCameras();
  }

  @override
  void initState() {
    super.initState();
    takePicture = true;

    detectCameras()!.then((value) {
      initializeControllers();
    });
  }

  @override
  void dispose() {
    super.dispose();

    cameraController!.dispose();
  }

  void initializeControllers() {
    cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      }
      if (takePicture) {
        const interval = Duration(seconds: 6);
        Timer.periodic(interval, (Timer t) => startCapturingPictures());
      }
    });
  }

  startCapturingPictures() async {
    String timeNameForPicture = DateTime.now().microsecondsSinceEpoch.toString();

    final Directory directory = await getApplicationDocumentsDirectory();
    final String dirPath = "${directory.path}/Pictures/flutter_test";

    await Directory(dirPath).create(recursive: true);
    final String filePath = "$dirPath/{$timeNameForPicture}.png";

    if (takePicture) {
      cameraController!.takePicture(filePath).then((value) {
        if (takePicture) {
          File imageFile = File(filePath);
          getResponse(imageFile);
        } else {
          return;
        }
      });
    }
  }

  Future<Map<String, dynamic>?> getResponse(File imageFile) async {
    // checking the MIME type data
    final typeData = lookupMimeType(imageFile.path, headerBytes: [0xFF, 0xD8])!.split('/');

    // posting the image to the API url
    final imageUploadRequest = http.MultipartRequest("POST", Uri.parse("http://max-image-caption-generator-test1.2886795306-80-hazel05.environments.katacoda.com/model/predict"));

    final file = await http.MultipartFile.fromPath("image", imageFile.path, contentType: MediaType(typeData[0], typeData[1]));

    imageUploadRequest.fields["ext"] = typeData[1];
    imageUploadRequest.files.add(file);

    try {
      // sending the request
      final responseUpload = await imageUploadRequest.send();

      // recieving the response
      final response = await http.Response.fromStream(responseUpload);

      // the json is decoded
      final Map<String, dynamic> responseData = json.decode(response.body);

      parseResponse(responseData);

      return responseData;
    } catch (e) {
      print(e);
      return null;
    }
  }

  parseResponse(var response) {
    String result = "";
    var predictions = response["predictions"];

    for (var pred in predictions) {
      var caption = pred["caption"];
      var probability = pred["probability"];

      result = result + caption + "\n\n";
    }

    setState(() {
      resultText = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Image.asset('assets/image.jpg').image,
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 30),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () {
                  setState(() {
                    takePicture = false;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            (cameraController!.value.isInitialized)
                ? Center(
                    child: createCameraView(),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  // livecam prediction Widget
  Widget createCameraView() {
    var size = MediaQuery.of(context).size.width / 1.2;
    return Column(
      children: <Widget>[
        Container(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 30),
              Container(
                height: size,
                width: size,
                child: CameraPreview(cameraController!),
              ),
              const SizedBox(height: 30),
              const Text(
                'Prediction: ',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.w400,
                  fontSize: 10,
                ),
              ),
              Text(
                resultText,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ],
    );
  }
}
