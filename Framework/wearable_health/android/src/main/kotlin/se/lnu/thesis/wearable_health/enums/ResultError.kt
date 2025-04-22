package se.lnu.thesis.wearable_health.enums

enum class ResultError(val errorCode: String, val errorMessage: String) {
    HEALTH_CONNECT_CLIENT_NOT_INITIALIZED("healthConnectClientNotInitialized", "The health connect client is not initialized."),

}