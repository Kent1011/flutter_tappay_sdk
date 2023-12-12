package kent.chien.flutter_tappay_sdk

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.common.api.Status
import com.google.android.gms.wallet.AutoResolveHelper
import com.google.android.gms.wallet.PaymentData
import com.google.android.gms.wallet.TransactionInfo
import com.google.android.gms.wallet.WalletConstants
import io.flutter.plugin.common.PluginRegistry
import kent.chien.flutter_tappay_sdk.models.TapPaySdkCommonResult
import tech.cherri.tpdirect.api.TPDCard
import tech.cherri.tpdirect.api.TPDConsumer
import tech.cherri.tpdirect.api.TPDGooglePay
import tech.cherri.tpdirect.api.TPDMerchant
import tech.cherri.tpdirect.callback.TPDGetPrimeFailureCallback
import tech.cherri.tpdirect.callback.TPDGooglePayGetPrimeSuccessCallback

class GooglePayHandler(
  private val context: Context
) : PluginRegistry.ActivityResultListener, PluginRegistry.RequestPermissionsResultListener {

  companion object {
    const val REQUEST_READ_PHONE_STATE: Int = 101
    const val LOAD_GOOGLE_PAY_DATA_REQUEST_CODE: Int = 102

    interface GooglePayCheckCallback {
      fun onGooglePayCheck(result: TapPaySdkCommonResult)
    }

    interface GooglePayPaymentCallback {
      fun onGooglePayResult(result: GooglePayPaymentResult)
    }

    data class GooglePayPaymentResult(
      val success: Boolean,
      val message: String?,
      val prime: String?,
    ) {
      fun toHashMap(): HashMap<String, Any?> {
        val resultHashMap = HashMap<String, Any?>()
        resultHashMap["success"] = success
        resultHashMap["message"] = message
        resultHashMap["prime"] = prime
        return resultHashMap
      }
    }
  }

  private lateinit var activity: Activity
  private lateinit var tpdGooglePay: TPDGooglePay

  private var merchantName: String = ""
  private var cardTypes: List<String> = emptyList()
  private var authMethods: List<String> = emptyList()
  private var isPhoneNumberRequired: Boolean = false
  private var isBillingAddressRequired: Boolean = false
  private var isEmailRequired: Boolean = false
  private var googlePayCheckCallback: GooglePayCheckCallback? = null
  private var googlePayPaymentCallback: GooglePayPaymentCallback? = null

  private var hasPermission: Boolean = false
  private var isGooglePayAvailable: Boolean = false

  fun setActivity(activity: Activity) {
    this.activity = activity
  }

  fun isAvailable(): Boolean {
    return isGooglePayAvailable
  }

  fun initGooglePay(
    merchantName: String?,
    cardTypes: List<String>? = arrayOf(
      "visa",
      "masterCard",
      "amex",
      "jcb",
      "unionPay"
    ).toList(),
    authMethods: List<String>? = arrayOf(
      "cryptogram3DS",
      "panOnly"
    ).toList(),
    isPhoneNumberRequired: Boolean? = false,
    isBillingAddressRequired: Boolean? = false,
    isEmailRequired: Boolean? = false,
    googlePayCallback: GooglePayCheckCallback?
  ) {
    if (merchantName != null) {
      this.merchantName = merchantName
    }
    if (cardTypes != null) {
      this.cardTypes = cardTypes
    }
    if (authMethods != null) {
      this.authMethods = authMethods
    }
    if (isPhoneNumberRequired != null) {
      this.isPhoneNumberRequired = isPhoneNumberRequired
    }
    if (isBillingAddressRequired != null) {
      this.isBillingAddressRequired = isBillingAddressRequired
    }
    if (isEmailRequired != null) {
      this.isEmailRequired = isEmailRequired
    }
    this.googlePayCheckCallback = googlePayCallback

    if (checkGooglePayPermission()) {
      if (merchantName.isNullOrEmpty()) {
        triggerCallback(
          TapPaySdkCommonResult(
            false,
            "Missing required parameters \"merchantName\" for \"initGooglePay\" method."
          )
        )
        return
      }

      val supportCardTypes = convertCardTypes(cardTypes)
      if (supportCardTypes.isEmpty()) {
        triggerCallback(
          TapPaySdkCommonResult(
            false,
            "Missing required parameters \"cardTypes\" for \"initGooglePay\" method."
          )
        )
        return
      }

      val supportAuthMethods = convertAuthMethods(authMethods)
      if (supportAuthMethods.isEmpty()) {
        triggerCallback(
          TapPaySdkCommonResult(
            false,
            "Missing required parameters \"authMethods\" for \"initGooglePay\" method."
          )
        )
        return
      }

      val storeName = merchantName
      val isNeedEmail = isEmailRequired ?: false
      val isNeedPhone = isPhoneNumberRequired ?: false
      val isNeedBillingAddress = isBillingAddressRequired ?: false

      val tpdMerchant = TPDMerchant().apply {
        this.supportedNetworks = supportCardTypes
        this.merchantName = storeName
        this.supportedAuthMethods = supportAuthMethods
      }

      val tpdConsumer = TPDConsumer().apply {
        this.isPhoneNumberRequired = isNeedPhone
        this.isShippingAddressRequired = isNeedBillingAddress
        this.isEmailRequired = isNeedEmail
      }

      tpdGooglePay = TPDGooglePay(activity, tpdMerchant, tpdConsumer)
      tpdGooglePay.isGooglePayAvailable { isReady, message ->
        if (isReady) {
          Log.d("GooglePayHandler", "Google Pay is available")
          triggerCallback(TapPaySdkCommonResult(true, "Google Pay is available"))
        } else {
          Log.d("GooglePayHandler", "Google Pay is unavailable: $message")
          triggerCallback(TapPaySdkCommonResult(false, "Google Pay is unavailable: $message"))
        }
      }
    }
  }

  fun requestPayment(
    price: Double,
    currencyCode: String,
    googlePayPaymentCallback: GooglePayPaymentCallback
  ) {
    this.googlePayPaymentCallback = googlePayPaymentCallback

    tpdGooglePay.requestPayment(
      TransactionInfo.newBuilder()
        .setTotalPriceStatus(WalletConstants.TOTAL_PRICE_STATUS_FINAL)
        .setTotalPrice(price.toString())
        .setCurrencyCode(currencyCode)
        .build(),
      LOAD_GOOGLE_PAY_DATA_REQUEST_CODE
    )
  }

  private fun checkGooglePayPermission(): Boolean {
    if (hasPermission) {
      return true
    }

    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      requestGooglePayPermission()
      false
    } else {
      true
    }
  }

  private fun requestGooglePayPermission() {
    if (ContextCompat.checkSelfPermission(
        context,
        Manifest.permission.READ_PHONE_STATE
      ) == PackageManager.PERMISSION_GRANTED
    ) {
      hasPermission = true

      initGooglePay(
        merchantName,
        cardTypes,
        authMethods,
        isPhoneNumberRequired,
        isBillingAddressRequired,
        isEmailRequired,
        googlePayCheckCallback
      )
    } else {
      ActivityCompat.requestPermissions(
        activity,
        arrayOf(Manifest.permission.READ_PHONE_STATE),
        REQUEST_READ_PHONE_STATE
      )
    }
  }

  override fun onRequestPermissionsResult(
    requestCode: Int,
    permissions: Array<out String>,
    grantResults: IntArray
  ): Boolean {
    if (requestCode == REQUEST_READ_PHONE_STATE) {
      if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
        hasPermission = true

        initGooglePay(
          merchantName,
          cardTypes,
          authMethods,
          isPhoneNumberRequired,
          isBillingAddressRequired,
          isEmailRequired,
          googlePayCheckCallback
        )
      } else {
        Log.w("GooglePayHandler", "READ_PHONE_STATE PERMISSION DENIED")
        googlePayCheckCallback?.onGooglePayCheck(TapPaySdkCommonResult(false, "PERMISSION DENIED"))
      }
      return true
    }
    return false
  }

  private fun triggerCallback(result: TapPaySdkCommonResult) {
    this.isGooglePayAvailable = result.success
    googlePayCheckCallback?.onGooglePayCheck(result)
  }

  private fun convertCardTypes(cardTypes: List<String>?): Array<TPDCard.CardType> {
    return cardTypes?.mapNotNull { mapCardType(it) }?.toTypedArray() ?: emptyArray()
  }

  private fun mapCardType(cardTypeString: String): TPDCard.CardType? {
    return when (cardTypeString) {
      "visa" -> TPDCard.CardType.Visa
      "masterCard" -> TPDCard.CardType.MasterCard
      "amex" -> TPDCard.CardType.AmericanExpress
      "jcb" -> TPDCard.CardType.JCB
      "unionPay" -> TPDCard.CardType.UnionPay
      else -> null
    }
  }

  private fun convertAuthMethods(authMethods: List<String>?): Array<TPDCard.AuthMethod> {
    return authMethods?.mapNotNull { mapAuthMethod(it) }?.toTypedArray() ?: emptyArray()
  }

  private fun mapAuthMethod(authMethodString: String): TPDCard.AuthMethod? {
    return when (authMethodString) {
      "cryptogram3DS" -> TPDCard.AuthMethod.Cryptogram3DS
      "panOnly" -> TPDCard.AuthMethod.PanOnly
      else -> null
    }
  }

  private fun requestGooglePayPayment(paymentData: PaymentData) {
    val successCallback =
      TPDGooglePayGetPrimeSuccessCallback { prime, _, _ ->
        Log.d("GooglePayHandler", "prime: $prime")
        googlePayPaymentCallback?.onGooglePayResult(
          GooglePayPaymentResult(
            true,
            null,
            prime,
          )
        )
      }

    val failureCallback =
      TPDGetPrimeFailureCallback { status, reportMsg ->
        Log.d("GooglePayHandler", "status: $status, reportMsg: $reportMsg")
        googlePayPaymentCallback?.onGooglePayResult(
          GooglePayPaymentResult(
            false,
            "($status) $reportMsg",
            null
          )
        )
      }

    tpdGooglePay.getPrime(
      paymentData, successCallback, failureCallback
    )
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean =
    when (requestCode) {
      LOAD_GOOGLE_PAY_DATA_REQUEST_CODE -> {
        when (resultCode) {

          // The request ran successfully. Process the result.
          Activity.RESULT_OK -> {
            if (data == null) {
              googlePayPaymentCallback?.onGooglePayResult(
                GooglePayPaymentResult(
                  false,
                  "PaymentData is null",
                  null,
                )
              )
            } else {
              val paymentData: PaymentData? = PaymentData.getFromIntent(data)
              if (paymentData == null) {
                googlePayPaymentCallback?.onGooglePayResult(
                  GooglePayPaymentResult(
                    false,
                    "PaymentData is null",
                    null,
                  )
                )
              } else {
                requestGooglePayPayment(paymentData)
              }
            }
            true
          }

          Activity.RESULT_CANCELED -> {
            googlePayPaymentCallback?.onGooglePayResult(
              GooglePayPaymentResult(
                false,
                "User canceled",
                null,
              )
            )
            true
          }

          AutoResolveHelper.RESULT_ERROR -> {
            val status: Status? = AutoResolveHelper.getStatusFromIntent(data)
            googlePayPaymentCallback?.onGooglePayResult(
              GooglePayPaymentResult(
                false,
                "(${status?.statusCode}) ${status?.statusMessage}",
                null,
              )
            )
            true
          }

          else -> false
        }
      }

      else -> false
    }
}