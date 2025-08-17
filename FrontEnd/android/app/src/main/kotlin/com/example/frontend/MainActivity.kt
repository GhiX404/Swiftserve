package com.example.frontend

import android.os.Build
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.snuggy/nfc"
    private lateinit var channel: MethodChannel
    private var nfcHandler: NfcHandler? = null

    @RequiresApi(Build.VERSION_CODES.KITKAT)
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        nfcHandler = NfcHandler(this, channel)

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isNfcSupported" -> {
                    result.success(nfcHandler?.isNfcSupported() ?: false)
                }
                "startNfcScan" -> {
                    nfcHandler?.startNfc()
                    result.success(null)
                }
                "stopNfcScan" -> {
                    nfcHandler?.stopNfc()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.KITKAT)
    override fun onPause() {
        super.onPause()
        nfcHandler?.stopNfc()
    }

    @RequiresApi(Build.VERSION_CODES.KITKAT)
    override fun onResume() {
        super.onResume()
        nfcHandler?.startNfc()
    }
}
