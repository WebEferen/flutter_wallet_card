package com.flutter.wallet_card

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull
import com.google.android.gms.pay.Pay
import com.google.android.gms.pay.PayApiAvailabilityStatus
import com.google.android.gms.pay.PayClient
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.io.File

/** FlutterWalletCardPlugin */
class FlutterWalletCardPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: Activity? = null
    private var payClient: PayClient? = null
    private var pendingResult: Result? = null

    companion object {
        private const val SAVE_PASSES_REQUEST_CODE = 1001
        private const val CHANNEL_NAME = "flutter_wallet_card"
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "isGoogleWalletAvailable" -> {
                checkGoogleWalletAvailability(result)
            }
            "isGoogleWalletCardAdded" -> {
                val objectId = call.argument<String>("objectId")
                if (objectId != null) {
                    checkCardAdded(objectId, result)
                } else {
                    result.error("INVALID_ARGUMENT", "objectId is required", null)
                }
            }
            "addGoogleWalletCard" -> {
                val path = call.argument<String>("path")
                if (path != null) {
                    addCardToWallet(path, result)
                } else {
                    result.error("INVALID_ARGUMENT", "path is required", null)
                }
            }
            "viewGoogleWalletCard" -> {
                val objectId = call.argument<String>("objectId")
                if (objectId != null) {
                    viewCardInWallet(objectId, result)
                } else {
                    result.error("INVALID_ARGUMENT", "objectId is required", null)
                }
            }
            "saveGoogleWalletPassWithJwt" -> {
                val jwt = call.argument<String>("jwt")
                if (jwt != null) {
                    savePassWithJwt(jwt, result)
                } else {
                    result.error("INVALID_ARGUMENT", "jwt is required", null)
                }
            }
            "createGoogleWalletPassLink" -> {
                val passData = call.arguments as? Map<String, Any>
                if (passData != null) {
                    createPassLink(passData, result)
                } else {
                    result.error("INVALID_ARGUMENT", "passData is required", null)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun getPayClient(): PayClient {
        if (payClient == null) {
            payClient = Pay.getClient(activity!!)
        }
        return payClient!!
    }

    private fun checkGoogleWalletAvailability(result: Result) {
        try {
            getPayClient().getPayApiAvailabilityStatus(PayClient.RequestType.SAVE_PASSES)
                .addOnSuccessListener { status ->
                    result.success(status == PayApiAvailabilityStatus.AVAILABLE)
                }
                .addOnFailureListener {
                    result.success(false)
                }
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun checkCardAdded(objectId: String, result: Result) {
        // Google Wallet API doesn't provide a direct method to check if a specific pass is added
        // This functionality should be implemented through your backend service
        result.success(false)
    }

    private fun addCardToWallet(filePath: String, result: Result) {
        try {
            val file = File(filePath)
            if (!file.exists()) {
                result.error("FILE_NOT_FOUND", "File does not exist: $filePath", null)
                return
            }

            val jsonContent = file.readText()

            pendingResult = result

            getPayClient().savePasses(jsonContent, activity!!, SAVE_PASSES_REQUEST_CODE)

        } catch (e: Exception) {
            result.error("ADD_CARD_ERROR", "Failed to add card: ${e.message}", null)
            pendingResult = null
        }
    }

    private fun viewCardInWallet(objectId: String, result: Result) {
        try {
            // Open Google Wallet app or web interface
            val intent = Intent(Intent.ACTION_VIEW).apply {
                data = Uri.parse("https://pay.google.com/gp/v/save/$objectId")
            }

            if (intent.resolveActivity(activity!!.packageManager) != null) {
                activity?.startActivity(intent)
                result.success(true)
            } else {
                result.success(false)
            }
        } catch (e: Exception) {
            result.error("VIEW_CARD_ERROR", "Failed to view card: ${e.message}", null)
        }
    }

    private fun savePassWithJwt(jwt: String, result: Result) {
        try {
            pendingResult = result

            getPayClient().savePassesJwt(jwt, activity!!, SAVE_PASSES_REQUEST_CODE)

        } catch (e: Exception) {
            result.error("SAVE_JWT_ERROR", "Failed to save pass with JWT: ${e.message}", null)
            pendingResult = null
        }
    }

    private fun createPassLink(passData: Map<String, Any>, result: Result) {
        try {
            // Create a Google Wallet save link
            // This is a simplified implementation
            val baseUrl = "https://pay.google.com/gp/v/save/"
            val objectId = passData["objectId"] as? String ?: "unknown"
            val link = "$baseUrl$objectId"

            result.success(link)
        } catch (e: Exception) {
            result.error("CREATE_LINK_ERROR", "Failed to create pass link: ${e.message}", null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        when (requestCode) {
            SAVE_PASSES_REQUEST_CODE -> {
                val success = resultCode == Activity.RESULT_OK
                pendingResult?.success(success)
                pendingResult = null
                return true
            }
        }
        return false
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
