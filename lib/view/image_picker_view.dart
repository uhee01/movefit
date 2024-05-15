import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movefit_app/features/movefit/utils/extract_features.dart';
import 'package:movefit_app/features/movefit/utils/extract_landmark.dart';
import 'package:movefit_app/features/movefit/utils/model/count_degree_model.dart';
import 'package:movefit_app/features/pose_landmark/pose_landmark.dart';
import 'package:movefit_app/features/pose_landmark/pose_landmark_impl.dart';

class GalleryImagePicker extends StatefulWidget {
  const GalleryImagePicker({super.key});

  @override
  State<GalleryImagePicker> createState() => _GalleryImagePickerState();
}

class _GalleryImagePickerState extends State<GalleryImagePicker> {
  File? videoFile;
  final IPoseLandmark poseLandmark = PoseLandmark();

  void _pickVideo() async {
    XFile? video = await ImagePicker().pickVideo(source: ImageSource.gallery);

    if (video != null) {
      setState(() {
        videoFile = File(video.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Gallery Picker')),
      body: Row(
        children: [
          Container(
              child: videoFile == null
                  ? const Text('No Video Selected')
                  : const Text(
                      // "${videoFile?.path ?? "No Video Selected"}",
                      "videoFileSelected",
                      overflow: TextOverflow.ellipsis,
                    )),
          SizedBox(
              child: ElevatedButton(
                  onPressed: () async {
                    videoFile!.exists();
                    var poseLandmarkResult = await poseLandmark
                        .getPoseLandmark(videoFile!.absolute.path);
                    List<CountDegreeModel> cdmList =
                        getCountDegress(poseLandmarkResult);
                    final extractFeature = ExtractFeature(
                        countDegreeModelList: cdmList, label: 'push_up');
                    int count = extractFeature.getCountWithLabel();
                    final simliarityList = await extractFeature.getSimilarity();

                    print(count);
                    print(simliarityList);
                  },
                  child: const Text('Send')))
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _pickVideo),
    );
  }
}
