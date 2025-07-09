package com.example.om

import android.Manifest
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "native_audio"
    private val PERM_REQUEST = 1234

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getSampleRate") {
                    // 1) Check mic permission
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
                        != PackageManager.PERMISSION_GRANTED) {
                        ActivityCompat.requestPermissions(this,
                            arrayOf(Manifest.permission.RECORD_AUDIO),
                            PERM_REQUEST
                        )
                        result.error("PERMISSION", "Microphone permission not granted", null)
                        return@setMethodCallHandler
                    }

                    // 2) Try to create recorder
                    try {
                        val bufSize = AudioRecord.getMinBufferSize(
                            44100,
                            AudioFormat.CHANNEL_IN_MONO,
                            AudioFormat.ENCODING_PCM_16BIT
                        )
                        val recorder = AudioRecord(
                            MediaRecorder.AudioSource.MIC,
                            44100,
                            AudioFormat.CHANNEL_IN_MONO,
                            AudioFormat.ENCODING_PCM_16BIT,
                            bufSize
                        )
                        result.success(recorder.sampleRate)
                    } catch (secEx: SecurityException) {
                        result.error("SECURITY", "SecurityException: ${secEx.message}", null)
                    } catch (e: Exception) {
                        result.error("ERROR", "Error creating AudioRecord: ${e.message}", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int, permissions: Array<out String>, grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }
}
