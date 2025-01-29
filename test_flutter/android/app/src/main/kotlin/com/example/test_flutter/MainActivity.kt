package com.example.test_flutter

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

// Importa el SDK del archivo AAR
import br.com.koin.android_sdk.KoinFingerprinter

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.test_flutter/fingerprint"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getFingerprintSession") {
                val applicationContext = applicationContext
                val ORGANIZATION_ID = "TU_ORGANIZATION_ID"  // Reemplázalo con tu ID real

                // Registrar el Fingerprinter
                KoinFingerprinter.register(applicationContext, ORGANIZATION_ID)

                // Obtener session ID
                val sessionID = KoinFingerprinter.profile(applicationContext)

                result.success(sessionID)
            } else {
                result.notImplemented()
            }
        }
    }
}
