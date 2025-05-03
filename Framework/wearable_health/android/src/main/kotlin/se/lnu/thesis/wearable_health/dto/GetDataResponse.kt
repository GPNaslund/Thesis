package se.lnu.thesis.wearable_health.dto

class GetDataResponse(private val result: List<Map<String, Any?>>){
    fun toMap(): Map<String, Any?> {
        return mapOf(
            "result" to result
        )
    }
}