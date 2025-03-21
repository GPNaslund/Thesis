package se.lnu.wearable_health

import android.content.Context
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.StepsRecord

class HealthConnectManager(private val context: Context?) {
    private var healthConnectClient: HealthConnectClient? = null
    private val permissions = setOf(HealthPermission.getReadPermission(StepsRecord::class))
    private var availabilityStatus: Int? = null

    init {
        initializeHealthConnectClient()
    }

    private fun checkContext(): Boolean {
        return context != null
    }

    private fun initializeHealthConnectClient() {
        if (!checkContext()) {
            return
        }
        val availabilityStatus = HealthConnectClient.getSdkStatus(this.context!!)
        if (availabilityStatus == HealthConnectClient.SDK_AVAILABLE) {
            this.healthConnectClient = HealthConnectClient.getOrCreate(this.context)
        }
        this.availabilityStatus = availabilityStatus
    }

    suspend fun hasAllPermissions(): Boolean {
        return healthConnectClient?.permissionController?.getGrantedPermissions()?.containsAll(permissions) ?: false
    }


    fun getAvailabilityStatus(): Int {
        return this.availabilityStatus ?: MANAGER_NOT_INITIALIZED
    }

    companion object {
        const val MANAGER_NOT_INITIALIZED = 99
        const val PERMISSION_REQUEST_CODE = 100
    }
}