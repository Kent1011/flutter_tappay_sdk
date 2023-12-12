package kent.chien.flutter_tappay_sdk

import android.app.Activity
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kent.chien.flutter_tappay_sdk.models.CreateCardTokenByCardInfoResult
import kent.chien.flutter_tappay_sdk.models.TapPaySdkCommonResult
import tech.cherri.tpdirect.api.TPDCard
import tech.cherri.tpdirect.api.TPDServerType
import tech.cherri.tpdirect.api.TPDSetup

/** FlutterTapPaySdkPlugin */
class FlutterTapPaySdkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel: MethodChannel

  private lateinit var context: Context
  private lateinit var activity: Activity
  private lateinit var googlePayHandler: GooglePayHandler

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_tappay_sdk")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
    googlePayHandler = GooglePayHandler(context)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    googlePayHandler.setActivity(activity)
    binding.addActivityResultListener(googlePayHandler)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null!!
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
    googlePayHandler.setActivity(activity)
    binding.addActivityResultListener(googlePayHandler)
  }

  override fun onDetachedFromActivity() {
    activity = null!!
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {

      // Get TapPay SDK version
      "sdkVersion" -> result.success(TPDSetup.getVersion())

      // Initialize TapPay SDK
      "initPayment" -> {
        val appId = call.argument<Int?>("appId")
        val appKey = call.argument<String?>("appKey")
        val isSandbox = call.argument<Boolean?>("isSandbox")

        initTapPay(appId, appKey, isSandbox) {
          result.success(it)
        }
      }

      // Validate card
      "isValidCard" -> {
        val carNumber = call.argument<String?>("cardNumber")
        val expiryMonth = call.argument<String?>("mm")
        val expiryYear = call.argument<String?>("yy")
        val cvv = call.argument<String?>("cvv")

        result.success(validateCard(carNumber, expiryMonth, expiryYear, cvv))
      }

      // Create token (prime) by card information
      "getPrimeByCardInfo" -> {
        val carNumber: String? = call.argument<String?>("cardNumber")
        val expiryMonth: String? = call.argument<String?>("mm")
        val expiryYear: String? = call.argument<String?>("yy")
        val cvv: String? = call.argument<String?>("cvv")

        createTokenByCardInfo(carNumber, expiryMonth, expiryYear, cvv, onResult = {
          result.success(it)
        })
      }

      "initGooglePay" -> {
        val merchantName: String? = call.argument<String?>("merchantName")
        val cardTypes: List<String>? = call.argument<List<String>?>("cardTypes")
        val authMethods: List<String>? = call.argument<List<String>?>("authMethods")
        val isPhoneNumberRequired: Boolean? = call.argument<Boolean?>("isPhoneNumberRequired")
        val isBillingAddressRequired: Boolean? =
          call.argument<Boolean?>("isBillingAddressRequired")
        val isEmailRequired: Boolean? = call.argument<Boolean?>("isEmailRequired")

        initGooglePay(
          merchantName,
          cardTypes,
          authMethods,
          isPhoneNumberRequired,
          isBillingAddressRequired,
          isEmailRequired,
          onResult = {
            result.success(it)
          }
        )
      }

      "requestGooglePay" -> {
        val price: Double? = call.argument<Double?>("price")
        val currencyCode: String? = call.argument<String?>("currencyCode")

        requestGooglePay(price, currencyCode, onResult = {
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
      val error = TapPaySdkCommonResult(
        false,
        "\"appId\" and \"appKey\" are required."
      ).toHashMap()
      onResult(error)
      return
    }

    val serverType: TPDServerType = if (isSandbox == true) {
      TPDServerType.Sandbox
    } else {
      TPDServerType.Production
    }

    TPDSetup.initInstance(context, appId, appKey, serverType)
    val result = TapPaySdkCommonResult(
      true,
      ""
    ).toHashMap()

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
        CreateCardTokenByCardInfoResult(
          false,
          null,
          "Missing required parameters for \"getPrimeByCardInfo\" method.",
          null
        ).toHashMap()
      )
      return
    }

    val tpdCard = TPDCard(
      context, StringBuffer(cardNumber), StringBuffer(expiryMonth),
      StringBuffer(expiryYear), StringBuffer(cvv)
    ).onSuccessCallback { prime, _, _, _ ->
      onResult(CreateCardTokenByCardInfoResult(true, null, null, prime).toHashMap())
    }.onFailureCallback { status, reportMsg ->
      onResult(CreateCardTokenByCardInfoResult(false, status, reportMsg, null).toHashMap())
    }

    tpdCard.createToken("UNKNOWN")
  }

  private fun initGooglePay(
    merchantName: String? = null,
    cardTypes: List<String>? = null,
    authMethods: List<String>? = null,
    isPhoneNumberRequired: Boolean? = null,
    isBillingAddressRequired: Boolean? = null,
    isEmailRequired: Boolean? = null,
    onResult: (HashMap<String, Any?>) -> (Unit)
  ) {
    val callback = object : GooglePayHandler.Companion.GooglePayCheckCallback {
      override fun onGooglePayCheck(result: TapPaySdkCommonResult) {
        onResult(
          result.toHashMap()
        )
      }
    }

    googlePayHandler.initGooglePay(
      merchantName,
      cardTypes,
      authMethods,
      isPhoneNumberRequired,
      isBillingAddressRequired,
      isEmailRequired,
      callback
    )
  }

  private fun requestGooglePay(
    price: Double?,
    currencyCode: String?,
    onResult: (HashMap<String, Any?>) -> (Unit)
  ) {
    if (price == null || currencyCode.isNullOrEmpty()) {
      onResult(
        TapPaySdkCommonResult(
          false,
          "Missing required parameters \"priceTotal\" or \"currencyCode\" for \"requestGooglePay\" method."
        ).toHashMap()
      )
      return
    }

    if (googlePayHandler.isAvailable()) {

      val callback = object : GooglePayHandler.Companion.GooglePayPaymentCallback {
        override fun onGooglePayResult(result: GooglePayHandler.Companion.GooglePayPaymentResult) {
          onResult(
            result.toHashMap()
          )
        }
      }

      googlePayHandler.requestPayment(price, currencyCode, callback)
    } else {
      onResult(
        TapPaySdkCommonResult(
          false,
          "Google Pay is not available."
        ).toHashMap()
      )
    }

  }
}
