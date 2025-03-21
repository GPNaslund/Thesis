package se.lnu.wearable_health

import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContracts
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.HeartRateRecord
import androidx.health.connect.client.records.StepsRecord
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.launch

class HealthConnectPermissionActivity : ComponentActivity() {
    private val logTag = "HealthConnectPermissionActivity"

    private val healthConnectClient by lazy { HealthConnectClient.getOrCreate(this) }

    companion object {
        const val PERMISSION_RESULT_KEY = "permission_result"

        val PERMISSIONS = setOf(
            HealthPermission.getReadPermission(StepsRecord::class),
            HealthPermission.getReadPermission(HeartRateRecord::class),
        )
    }

    private val requestPermissionsLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        Log.d(logTag, "Permission request completed with resultCode: ${result.resultCode}")

        checkPermissionsAndFinish()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(logTag, "HealthConnectPermissionActivity onCreate")

        try {
            val availability = HealthConnectClient.getSdkStatus(this)
            Log.d(logTag, "Health Connect availability: $availability")

            if (availability != HealthConnectClient.SDK_AVAILABLE) {
                handleErrorAndFinish("Health Connect not available: $availability")
                return
            }

            checkPermissionsAndProceed()

        } catch (e: Exception) {
            Log.e(logTag, "Error in onCreate", e)
            handleErrorAndFinish("Error: ${e.message}")
        }
    }

    private fun checkPermissionsAndProceed() {
        lifecycleScope.launch {
            try {
                val grantedPermissions = healthConnectClient.permissionController.getGrantedPermissions()
                Log.d(logTag, "Current granted permissions: $grantedPermissions")

                if (grantedPermissions.containsAll(PERMISSIONS)) {
                    Log.d(logTag, "Already have all required permissions")
                    val resultIntent = Intent()
                    resultIntent.putExtra(PERMISSION_RESULT_KEY, true)
                    Log.d(logTag, "Setting result with PERMISSION_RESULT_KEY=$PERMISSION_RESULT_KEY to true")
                    setResult(RESULT_OK, resultIntent)

                    kotlinx.coroutines.delay(100)
                    Log.d(logTag, "Finishing activity with success result")
                    finish()
                } else {
                    Log.d(logTag, "Requesting permissions: $PERMISSIONS")
                    val contract = PermissionController.createRequestPermissionResultContract()
                    val intent = contract.createIntent(applicationContext, PERMISSIONS)
                    requestPermissionsLauncher.launch(intent)
                }
            } catch (e: Exception) {
                Log.e(logTag, "Error checking permissions", e)
                handleErrorAndFinish("Error checking permissions: ${e.message}")
            }
        }
    }

    private fun checkPermissionsAndFinish() {
        lifecycleScope.launch {
            try {
                val grantedPermissions = healthConnectClient.permissionController.getGrantedPermissions()
                val allGranted = grantedPermissions.containsAll(PERMISSIONS)

                Log.d(logTag, "Final permissions check: allGranted=$allGranted, grantedPermissions=$grantedPermissions")

                val resultIntent = Intent()
                resultIntent.putExtra(PERMISSION_RESULT_KEY, allGranted)
                setResult(RESULT_OK, resultIntent)
                finish()
            } catch (e: Exception) {
                Log.e(logTag, "Error in final permissions check", e)
                handleErrorAndFinish("Error checking final permissions: ${e.message}")
            }
        }
    }

    private fun handleErrorAndFinish(message: String) {
        Log.e(logTag, message)
        val resultIntent = Intent()
        resultIntent.putExtra(PERMISSION_RESULT_KEY, false)
        setResult(RESULT_CANCELED, resultIntent)
        finish()
    }
}