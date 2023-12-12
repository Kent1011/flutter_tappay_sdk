package kent.chien.flutter_tappay_sdk.models

data class TapPaySdkCommonResult(
  val success: Boolean,
  val message: String?,
) {
  fun toHashMap(): HashMap<String, Any?> {
    val result = HashMap<String, Any?>()
    result["success"] = success
    result["message"] = message ?: ""

    return result
  }
}
