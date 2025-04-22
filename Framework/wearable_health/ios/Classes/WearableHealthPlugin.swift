import CallType
import Flutter
import UIKit

public class WearableHealthPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "wearable_health", binaryMessenger: registrar.messenger())
        let instance = WearableHealthPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let callType: CallType = CallType.fromString(call.method)

        if callType == null {
            result(FlutterMethodNotImplemented)
        }

        switch callType {
        case .getPlatformVersion:
            result("iOS " + UIDevice.current.systemVersion)
        case .hasPermission:
            throw NotImplementedError()
        case .requestPermission:
            throw NotImplementedError()
        case .dataStoreAvailability:
            throw NotImplementedError()
        }
    }
}
