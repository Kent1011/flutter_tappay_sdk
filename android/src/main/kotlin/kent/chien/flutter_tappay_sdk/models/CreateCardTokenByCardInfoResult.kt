package kent.chien.flutter_tappay_sdk.models

data class CreateCardTokenByCardInfoResult(
  val success: Boolean,
  val status: Int?,
  val message: String?,
  val prime: String?,
) {
  fun toHashMap(): HashMap<String, Any?> {
    val result = HashMap<String, Any?>()
    result["success"] = success
    result["status"] = status
    result["message"] = message ?: ""
    result["prime"] = prime ?: ""

    return result
  }
}
