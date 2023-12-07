package kent.chien.flutter_tappay_sdk

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import tech.cherri.tpdirect.api.TPDCard
import tech.cherri.tpdirect.api.TPDServerType
import tech.cherri.tpdirect.api.TPDSetup

/** FlutterTapPaySdkPlugin */
class FlutterTapPaySdkPlugin : FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_tappay_sdk")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "sdkVersion" -> result.success(TPDSetup.getVersion())

      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")

      "initPayment" -> {
        val appId = call.argument<Int?>("appId")
        val appKey = call.argument<String?>("appKey")
        val isSandbox = call.argument<Boolean?>("isSandbox")

        initTapPay(appId, appKey, isSandbox) {
          result.success(it)
        }
      }

      "isValidCard" -> {
        val carNumber = call.argument<String?>("cardNumber")
        val expiryMonth = call.argument<String?>("mm")
        val expiryYear = call.argument<String?>("yy")
        val cvv = call.argument<String?>("cvv")

        result.success(validateCard(carNumber, expiryMonth, expiryYear, cvv))
      }

      "getPrimeByCardInfo" -> {
        val carNumber: String? = call.argument<String?>("cardNumber")
        val expiryMonth: String? = call.argument<String?>("mm")
        val expiryYear: String? = call.argument<String?>("yy")
        val cvv: String? = call.argument<String?>("cvv")

        createTokenByCardInfo(carNumber, expiryMonth, expiryYear, cvv, onResult = {
          result.success(it)
        })
      }

      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  /**
   * Initialize TapPay SDK
   */
  private fun initTapPay(
    appId: Int?, appKey: String?, isSandbox: Boolean?,
    onResult: (HashMap<String, Any?>) -> (Unit)
  ) {
    if (appId == null || appKey == null) {
      val error = HashMap<String, Any?>()
      error["success"] = false
      error["message"] = "\"appId\" and \"appKey\" are required."
      onResult(error)
      return
    }

    val serverType: TPDServerType = if (isSandbox == true) {
      TPDServerType.Sandbox
    } else {
      TPDServerType.Production
    }

    TPDSetup.initInstance(context, appId, appKey, serverType)
    val result = HashMap<String, Any?>()
    result["success"] = true
    result["message"] = ""

    onResult(result)
  }

  /**
   * Validate card
   */
  private fun validateCard(
    cardNumber: String?, expiryMonth: String?, expiryYear: String?,
    cvv: String?
  ): Boolean {
    if (cardNumber.isNullOrEmpty() || expiryMonth.isNullOrEmpty() || expiryYear.isNullOrEmpty() ||
      cvv.isNullOrEmpty()
    ) {
      return false
    }

    val result = TPDCard.validate(
      StringBuffer(cardNumber), StringBuffer(expiryMonth),
      StringBuffer(expiryYear), StringBuffer(cvv)
    )
    return result.isCardNumberValid && result.isExpiryDateValid && result.isCCVValid
  }

  /**
   * Create token (prime)
   */
  private fun createTokenByCardInfo(
    cardNumber: String?, expiryMonth: String?, expiryYear: String?,
    cvv: String?, onResult: (HashMap<String, Any?>) -> (Unit)
  ) {
    if (cardNumber.isNullOrEmpty() || expiryMonth.isNullOrEmpty() || expiryYear.isNullOrEmpty() ||
      cvv.isNullOrEmpty()
    ) {
      onResult(
        generateTokenResult(
          false,
          null,
          "Missing required parameters for \"getPrimeByCardInfo\" method.",
          null
        )
      )
      return
    }

    val tpdCard = TPDCard(
      context, StringBuffer(cardNumber), StringBuffer(expiryMonth),
      StringBuffer(expiryYear), StringBuffer(cvv)
    ).onSuccessCallback { prime, _, _, _ ->
      onResult(generateTokenResult(true, null, null, prime))
    }.onFailureCallback { status, reportMsg ->
      onResult(generateTokenResult(false, status, reportMsg, null))
    }

    tpdCard.createToken("UNKNOWN")
  }

  /**
   * Generate token result
   */
  private fun generateTokenResult(
    success: Boolean, status: Int?, message: String?,
    prime: String?
  ): HashMap<String, Any?> {
    val result = HashMap<String, Any?>()

    result["success"] = success
    result["status"] = status
    result["message"] = message ?: ""
    result["prime"] = prime ?: ""

    return result
  }
}
