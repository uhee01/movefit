package com.waterself.poselandmark

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.content.Context
import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.SystemClock
import android.graphics.Color
import android.util.Log

/** PoselandmarkPlugin */
class PoselandmarkPlugin: FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private lateinit var context: Context


    private lateinit var landmarkDetector: LandmarkDetector

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "poselandmark")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        landmarkDetector = LandmarkDetector(context)
        Log.i("attachedToEngine", "attached")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "detectLandmarksFromVideo" -> detectLandmarksFromVideo(call, result)
//            "extractFrameFromVideo" -> extractFrameFromVideo(call, result)
            else -> result.notImplemented()
        }
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun detectLandmarksFromVideo(call: MethodCall, result: Result) {
        Log.i("onMethod", "call")
        try {
            landmarkDetector = LandmarkDetector(context)
            val videoPath: String = call.arguments.toString()
            val videoUri: Uri = Uri.parse(videoPath)

            val landmarkResult = landmarkDetector.detectLandmarksFromVideo(videoUri, 300L)

            result.success(landmarkResult)
        } catch (e: Exception) {
            result.error(e.javaClass.simpleName, e.message, null)
        }

    }
}

//    private fun extractFrameFromVideo(call: MethodCall, result: Result){
//        try {
//            val videoPath : String = call.arguments.toString()
//            var videoUri : Uri = Uri.parse(videoPath)
//
//            val retriever = MediaMetadataRetriever()
//            retriever.setDataSource(context, videoUri)
//            val videoLengthMs =
//                retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
//                    ?.toLong()
//
//            val firstFrame = retriever.getFrameAtTime(0)
//            val width = firstFrame?.width
//            val height = firstFrame?.height
//
//            // If the video is invalid, returns a null detection result
////            if ((videoLengthMs == null) || (width == null) || (height == null)) return null
//            val frames = mutableListOf<List<List<List<Int>>>>()
//            // Next, we'll get one frame every frameInterval ms, then run detection on these frames.
//            val numberOfFrameToRead = Integer.parseInt(retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_FRAME_COUNT))
//            for (i in 0..numberOfFrameToRead-1) {
//                val frameIndex = i
//                val timestampMs = i * 10L // ms
//
//                retriever
//                    .getFrameAtIndex(
//                        frameIndex, // convert from ms to micro-s
//                        MediaMetadataRetriever.BitmapParams()
//                    )
//                    ?.let { frame ->
//                        val frameData = mutableListOf<List<List<Int>>>()
//                        val width = frame.width
//                        val height = frame.height
//                        for (y in 0 until height) {
//                            val row = mutableListOf<List<Int>>()
//                            for (x in 0 until width) {
//                                val pixelColor = frame.getPixel(x, y)
//                                val red = Color.red(pixelColor)
//                                val green = Color.green(pixelColor)
//                                val blue = Color.blue(pixelColor)
//                                val rgb = mutableListOf(red, green, blue)
//                                row.add(rgb)
//                            }
//                            frameData.add(row)
//                        }
//                        frames.add(frameData)
//                        frame.recycle()
//                    }
//            }
//            retriever.release()
//            result.success(frames)
//        }catch (e:Exception){
//            result.error(e.javaClass.simpleName, e.message, null)
//        }
//
//    }
//}
