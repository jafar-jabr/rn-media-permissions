#import "RnMediaPermissions.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>

@implementation RnMediaPermissions
#pragma mark - Helper Methods

- (NSString *)mapCameraAuthorizationStatus:(AVAuthorizationStatus)status {
  switch (status) {
    case AVAuthorizationStatusAuthorized: return @"granted";
    case AVAuthorizationStatusDenied: return @"denied";
    case AVAuthorizationStatusRestricted: return @"restricted";
    case AVAuthorizationStatusNotDetermined: return @"not_determined";
    default: return @"unknown";
  }
}

- (NSString *)mapPhotoLibraryAuthorizationStatus:(PHAuthorizationStatus)status {
  switch (status) {
    case PHAuthorizationStatusAuthorized: return @"granted";
    case PHAuthorizationStatusLimited: return @"limited";
    case PHAuthorizationStatusDenied: return @"denied";
    case PHAuthorizationStatusRestricted: return @"restricted";
    case PHAuthorizationStatusNotDetermined: return @"not_determined";
    default: return @"unknown";
  }
}

#pragma mark - Camera Permission Methods

- (void)requestCameraPermission:(RCTPromiseResolveBlock)resolve
                         reject:(RCTPromiseRejectBlock)reject
{
  dispatch_async(dispatch_get_main_queue(), ^{
#if TARGET_OS_SIMULATOR
    resolve(@"simulator");
#else
    AVCaptureDeviceDiscoverySession *discoverySession =
      [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera]
                                                            mediaType:AVMediaTypeVideo
                                                             position:AVCaptureDevicePositionUnspecified];

    NSArray<AVCaptureDevice *> *devices = discoverySession.devices;
    if (devices.count == 0) {
      resolve(@"unavailable");
      return;
    }

    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
      [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                               completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
          resolve(granted ? @"granted" : @"denied");
        });
      }];
    } else {
      resolve([self mapCameraAuthorizationStatus:authStatus]);
    }
#endif
  });
}

- (void)getCameraPermissionStatus:(RCTPromiseResolveBlock)resolve
                           reject:(RCTPromiseRejectBlock)reject
{
  dispatch_async(dispatch_get_main_queue(), ^{
#if TARGET_OS_SIMULATOR
    resolve(@"simulator");
#else
    AVCaptureDeviceDiscoverySession *discoverySession =
      [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera]
                                                            mediaType:AVMediaTypeVideo
                                                             position:AVCaptureDevicePositionUnspecified];

    NSArray<AVCaptureDevice *> *devices = discoverySession.devices;
    if (devices.count == 0) {
      resolve(@"unavailable");
      return;
    }

    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    resolve([self mapCameraAuthorizationStatus:authStatus]);
#endif
  });
}

#pragma mark - Photo Library Permission Methods

- (void)requestPhotoLibraryPermission:(RCTPromiseResolveBlock)resolve
                               reject:(RCTPromiseRejectBlock)reject
{
  dispatch_async(dispatch_get_main_queue(), ^{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];

    if (status == PHAuthorizationStatusNotDetermined) {
      if (@available(iOS 14, *)) {
        [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite
                                                   handler:^(PHAuthorizationStatus status) {
          dispatch_async(dispatch_get_main_queue(), ^{
            resolve([self mapPhotoLibraryAuthorizationStatus:status]);
          });
        }];
      } else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
          dispatch_async(dispatch_get_main_queue(), ^{
            resolve([self mapPhotoLibraryAuthorizationStatus:status]);
          });
        }];
      }
    } else {
      resolve([self mapPhotoLibraryAuthorizationStatus:status]);
    }
  });
}

- (void)getPhotoLibraryPermissionStatus:(RCTPromiseResolveBlock)resolve
                                 reject:(RCTPromiseRejectBlock)reject
{
  dispatch_async(dispatch_get_main_queue(), ^{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    resolve([self mapPhotoLibraryAuthorizationStatus:status]);
  });
}

#pragma mark - Microphone Permission Methods

- (void)requestMicrophonePermission:(RCTPromiseResolveBlock)resolve
                             reject:(RCTPromiseRejectBlock)reject
{
  dispatch_async(dispatch_get_main_queue(), ^{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];

    if (authStatus == AVAuthorizationStatusNotDetermined) {
      [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio
                               completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
          resolve(granted ? @"granted" : @"denied");
        });
      }];
    } else {
      resolve([self mapCameraAuthorizationStatus:authStatus]);
    }
  });
}

- (void)getMicrophonePermissionStatus:(RCTPromiseResolveBlock)resolve
                               reject:(RCTPromiseRejectBlock)reject
{
  dispatch_async(dispatch_get_main_queue(), ^{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    resolve([self mapCameraAuthorizationStatus:authStatus]);
  });
}

#pragma mark - App Settings

- (void)openAppSettings:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject
{
  dispatch_async(dispatch_get_main_queue(), ^{
    NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:settingsURL]) {
      [[UIApplication sharedApplication] openURL:settingsURL
                                         options:@{}
                               completionHandler:^(BOOL success) {
        resolve(@(success));
      }];
    } else {
      reject(@"UNAVAILABLE", @"Cannot open settings", nil);
    }
  });
}

#pragma mark - Multiple Permissions

- (void)checkMultiplePermissions:(RCTPromiseResolveBlock)resolve
                          reject:(RCTPromiseRejectBlock)reject
{
  dispatch_async(dispatch_get_main_queue(), ^{
    NSMutableDictionary *permissions = [NSMutableDictionary dictionary];

    // Camera
#if !TARGET_OS_SIMULATOR
    AVCaptureDeviceDiscoverySession *discoverySession =
      [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera]
                                                            mediaType:AVMediaTypeVideo
                                                             position:AVCaptureDevicePositionUnspecified];

    if (discoverySession.devices.count > 0) {
      AVAuthorizationStatus cameraStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
      permissions[@"camera"] = [self mapCameraAuthorizationStatus:cameraStatus];
    } else {
      permissions[@"camera"] = @"unavailable";
    }
#else
    permissions[@"camera"] = @"simulator";
#endif

    // Photo Library
    PHAuthorizationStatus photoStatus = [PHPhotoLibrary authorizationStatus];
    permissions[@"photoLibrary"] = [self mapPhotoLibraryAuthorizationStatus:photoStatus];

    // Microphone
    AVAuthorizationStatus micStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    permissions[@"microphone"] = [self mapCameraAuthorizationStatus:micStatus];

    resolve(permissions);
  });
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeRnMediaPermissionsSpecJSI>(params);
}

+ (NSString *)moduleName
{
  return @"RnMediaPermissions";
}

@end
