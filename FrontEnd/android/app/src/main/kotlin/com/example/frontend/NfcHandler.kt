package com.example.frontend

import android.app.Activity
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.MethodChannel
import java.lang.Exception
import java.lang.StringBuilder

class NfcHandler(private val activity: Activity, private val channel: MethodChannel) : NfcAdapter.ReaderCallback {

    private var nfcAdapter: NfcAdapter? = NfcAdapter.getDefaultAdapter(activity)

    fun isNfcSupported(): Boolean {
        return nfcAdapter != null
    }

    fun isNfcEnabled(): Boolean {
        return nfcAdapter?.isEnabled == true
    }

    @RequiresApi(Build.VERSION_CODES.KITKAT)
    fun startNfc() {
        if (isNfcEnabled()) {
            nfcAdapter?.enableReaderMode(
                activity,
                this,
                NfcAdapter.FLAG_READER_NFC_A or NfcAdapter.FLAG_READER_SKIP_NDEF_CHECK,
                null
            )
        }
    }

    @RequiresApi(Build.VERSION_CODES.KITKAT)
    fun stopNfc() {
        nfcAdapter?.disableReaderMode(activity)
    }

    override fun onTagDiscovered(tag: Tag?) {
        try {
            val uid = tag?.id
            if (uid != null) {
                val hexUid = bytesToHexString(uid)
                activity.runOnUiThread {
                    channel.invokeMethod("onNfcTagDetected", mapOf("uuid" to hexUid))
                }
            }
        } catch (e: Exception) {
            activity.runOnUiThread {
                channel.invokeMethod("onNfcError", mapOf("error" to e.localizedMessage))
            }
        }
    }

    private fun bytesToHexString(bytes: ByteArray): String {
        val stringBuilder = StringBuilder()
        for (b in bytes) {
            stringBuilder.append(String.format("%02X", b))
        }
        return stringBuilder.toString()
    }
} 