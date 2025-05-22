//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<device_info_plus/FPPDeviceInfoPlusPlugin.h>)
#import <device_info_plus/FPPDeviceInfoPlusPlugin.h>
#else
@import device_info_plus;
#endif

#if __has_include(<health/HealthPlugin.h>)
#import <health/HealthPlugin.h>
#else
@import health;
#endif

#if __has_include(<health_plus/HealthPlusPlugin.h>)
#import <health_plus/HealthPlusPlugin.h>
#else
@import health_plus;
#endif

#if __has_include(<integration_test/IntegrationTestPlugin.h>)
#import <integration_test/IntegrationTestPlugin.h>
#else
@import integration_test;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FPPDeviceInfoPlusPlugin registerWithRegistrar:[registry registrarForPlugin:@"FPPDeviceInfoPlusPlugin"]];
  [HealthPlugin registerWithRegistrar:[registry registrarForPlugin:@"HealthPlugin"]];
  [HealthPlusPlugin registerWithRegistrar:[registry registrarForPlugin:@"HealthPlusPlugin"]];
  [IntegrationTestPlugin registerWithRegistrar:[registry registrarForPlugin:@"IntegrationTestPlugin"]];
}

@end
