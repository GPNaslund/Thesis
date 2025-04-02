import android.app.Activity
import android.content.Context
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.health.connect.client.HealthConnectClient
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import se.lnu.thesis.wearable_health.provider.Provider

class GoogleHealthConnectProvider(private val context: Context, private val activity: Activity) : Provider {
    private val healthConnectClient: HealthConnectClient = HealthConnectClient.getOrCreate(context)
    private var healthConnectRequestPermissionLauncher: ActivityResultLauncher<Set<String>>? = null
    private var resultCallback: MethodChannel.Result? = null
    private var replySubmitted = false;

    override fun setupPermissionsLauncher(activity: ComponentActivity) {
        healthConnectRequestPermissionLauncher = activity.registerForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) { grantedPermissions ->
            onHealthConnectPermissionCallback(grantedPermissions.filterValues { it }.keys
            )
        }
    }

    private fun onHealthConnectPermissionCallback(grantedPermissions: Set<String>) {
        if (!replySubmitted) {
            if (grantedPermissions.isEmpty()) {
                resultCallback?.success(false)
            } else {
                resultCallback?.success(true)
            }
            replySubmitted = true
        }
    }

    override fun requestPermissions(permissions: Set<String>, result: MethodChannel.Result) {
        resultCallback = result
        replySubmitted = false
        healthConnectRequestPermissionLauncher?.launch(permissions)
    }

    override fun hasPermissions(permissions: Set<String>): Boolean = runBlocking {
        var result = false
        launch {
            result = healthConnectClient.permissionController.getGrantedPermissions()
        }
    }

    override fun installProviderApp() {
        val uriString =
    }

}