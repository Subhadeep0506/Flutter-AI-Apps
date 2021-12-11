// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:captions_generator/live_camera.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import './buttons/button.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  String resultText = 'Fetching results...';
  late File image;
  final pickerImage = ImagePicker();

  // Image picker from Gallery
  pickImageFromGallery() async {
    var image = await pickerImage.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        this.image = File(image.path);
        _loading = false;
      });

      var response = getResponse(this.image);
    }
  }

  // Image picker from Camera
  captureImageWithCamera() async {
    var image = await pickerImage.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        this.image = File(image.path);
        _loading = false;
      });

      var response = getResponse(this.image);
    }
  }

  // this fuction is made nullable using '?'
  Future<Map<String, dynamic>?> getResponse(File imageFile) async {
    // checking the MIME type data
    final typeData = lookupMimeType(imageFile.path, headerBytes: [0xFF, 0xD8])!.split('/');

    // posting the image to the API url
    final imageUploadRequest = http.MultipartRequest("POST", Uri.parse("http://max-image-caption-generator-test1.2886795294-80-hazel04.environments.katacoda.com/model/predict"));

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

  final appBar = AppBar(
    title: const Text('Captions Generator'),
    elevation: 6,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Image.asset('assets/image.jpg').image,
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.black12,
            // borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.05),
                blurRadius: 7,
                spreadRadius: 5,
              )
            ],
          ),
          child: Column(
            children: <Widget>[
              Center(
                // if loading is true, UI is displayed
                child: _loading
                    ? Container(
                        height: MediaQuery.of(context).size.height - (appBar.preferredSize.height + MediaQuery.of(context).padding.top),
                        child: Column(
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Button(
                                  buttonText: 'LIVE CAMERA',
                                  buttonIcon: Icons.camera,
                                  buttonPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => LiveCamera()));
                                  },
                                ),
                                Button(
                                  buttonText: 'GALLERY',
                                  buttonIcon: Icons.photo,
                                  buttonPressed: pickImageFromGallery,
                                ),
                                Button(
                                  buttonText: 'CAMERA',
                                  buttonIcon: Icons.camera_alt,
                                  buttonPressed: captureImageWithCamera,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.only(top: 30),
                        child: Column(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Container(
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          resultText = "Fetching result...";
                                          _loading = true;
                                        });
                                      },
                                      icon: Icon(
                                        Icons.arrow_back,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x54000000),
                                          spreadRadius: 4,
                                          blurRadius: 20,
                                        ),
                                      ],
                                    ),
                                    width: MediaQuery.of(context).size.width - 200,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          image,
                                          fit: BoxFit.fill,
                                        )),
                                  ),
                                  Container(
                                    width: 50,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Container(
                              child: Text(
                                resultText,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 20),
                              ),
                            )
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
