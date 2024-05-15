package com.waterself.poselandmark

import android.content.Context
import android.net.Uri
import android.util.Log
import kotlinx.coroutines.*
import androidx.annotation.VisibleForTesting
import androidx.lifecycle.Lifecycle
import com.google.mediapipe.tasks.vision.core.RunningMode
//import java.util.concurrent.Executors
//import java.util.concurrent.ScheduledExecutorService

class LandmarkDetector(
    private val context: Context
) {
    private val helper : PoseLandmarkerHelper = PoseLandmarkerHelper(
        context = context,
        runningMode = RunningMode.VIDEO,
        minPoseDetectionConfidence = 0.5F,
        minPoseTrackingConfidence = 0.5F,
        minPosePresenceConfidence = 0.5F,
        currentModel = 2,
        currentDelegate=0 )
    // Log.d("Model", "Loded")
    //private var backgroundExecutor : ScheduledExecutorService
//    List<List<List<List<Double>>>>?
    @VisibleForTesting
    fun detectLandmarksFromVideo(videoUri: Uri, inferenceIntervalMs: Long): HashMap<String, Double>{

        val resultBundles = helper.detectVideoFileFrame(videoUri)
            ?: // Handle error or return an empty list if an error occurred during detection.
//            Log.d("kps", "resultBundles is Null")
            return HashMap<String, Double>().apply{
                put("ResultBundlesError", 0.0)
            }
        Log.i("results", resultBundles?.results.toString())

        // TODO: landmarkResultList의 길이는 프레임수
        // TODO: landmarkResult -> frame 단위의 리스트
        // TODO: eachFrame의 길이가 0이면 NULL 리스트(1,33,5)를 삽입
        // TODO: eachFrame 안에는 각 관절의 x,y,z가 있음
        // TODO: eachPoint에서 y,-x,-z,vis,pre를 리스트로 수집
        // TODO: 위 리스트 (33,5)의 리스트를 (1,33,5)로 수집
        // TODO: (1,33,5)의 리스트를 프레임 단위로 수집
        // TODO: 반환

        // Each Frames
        val keypointsFrames = mutableListOf<List<List<List<Double>>>>()
        val invalidindex = mutableListOf<Int>()
        Log.i("bundles result size", resultBundles.results.size.toString())
        for (resultBundle in resultBundles.results) {
            val worldLandmarksList = resultBundle.worldLandmarks()
            worldLandmarksList.forEach { eachFrame ->
                val kpsWrapperList = mutableListOf<List<List<Double>>>()
                val keypointsList = mutableListOf<List<Double>>()
                eachFrame.forEach { eachPoint ->
                    val kps = mutableListOf<Double>()
                    kps.add(eachPoint.y().toDouble())
                    kps.add(-eachPoint.x().toDouble())
                    kps.add(-eachPoint.z().toDouble())
                    if (eachPoint.visibility() != null && eachPoint.visibility().isPresent) {
                        kps.add(eachPoint.visibility().get().toDouble())
                    } else {
                        kps.add(0.0)
                    }

                    if (eachPoint.presence() != null && eachPoint.presence().isPresent) {
                        kps.add(eachPoint.presence().get().toDouble())
                    } else {
                        kps.add(0.0)
                    }
                    keypointsList.add(kps)
                    //Log.d("kps", kps.toString())
                } // end of point(5)
                kpsWrapperList.add(keypointsList)
//                Log.d("kps", kpsWrapperList.toString())
                //end of each point(33,5)
                keypointsFrames.add(kpsWrapperList)
//                Log.d("kps", keypointsFrames.toString())
            }
        }
        //Log.d("kps", keypointsFrames.toString())
        var keypointsFramesMapped = convertToListToMap(keypointsFrames)
        //Log.d("kps", keypointsFrames.toString())
        //Log.d("kps", keypointsFramesMapped["[0][0][0][0]"].toString())
        //Log.d("kps", keypointsFrames[0][0][0][0].toString())
        Log.i("kps", keypointsFrames.size.toString())

        helper.clearPoseLandmarker();
        return keypointsFramesMapped
    }
    fun convertToListToMap(inputList: List<List<List<List<Double>>>>): HashMap<String, Double> {
        val resultMap = HashMap<String, Double>()

        for (i in inputList.indices) {
            for (j in inputList[0].indices) {
                for (k in inputList[0][0].indices) {
                    for (l in inputList[0][0][0].indices) {
                        val key = "[$i][$j][$k][$l]"
                        val value = inputList[i][j][k][l]
                        resultMap[key] = value
                    }
                }
            }
        }

        return resultMap
    }
}


