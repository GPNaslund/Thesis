import android.content.Context
import androidx.activity.result.contract.ActivityResultContract
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController

class HealthConnectPermissionManager(
    private val context: Context,
    private val healthConnectClient: HealthConnectClient
) {

    suspend fun hasPermissions(permissions: Set<String>): Boolean {
        val granted = healthConnectClient.permissionController.getGrantedPermissions()
        return permissions.all { it in granted }
    }

    fun createRequestPermissionContract(): ActivityResultContract<Set<String>, Set<String>> {
        return PermissionController.createRequestPermissionResultContract()
    }

}