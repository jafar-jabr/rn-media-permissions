import { TurboModuleRegistry, type TurboModule } from 'react-native';

export type PermissionStatus =
  | 'granted'
  | 'denied'
  | 'restricted'
  | 'not_determined'
  | 'limited'
  | 'unknown';

export interface MultiplePermissionsResult {
  [key: string]: PermissionStatus;
}

export interface Spec extends TurboModule {
  requestCameraPermission(): Promise<PermissionStatus>;
  getCameraPermissionStatus(): Promise<PermissionStatus>;

  // Photo Library Permission
  requestPhotoLibraryPermission(): Promise<PermissionStatus>;
  getPhotoLibraryPermissionStatus(): Promise<PermissionStatus>;

  // Microphone Permission
  requestMicrophonePermission(): Promise<PermissionStatus>;
  getMicrophonePermissionStatus(): Promise<PermissionStatus>;

  // Open Settings
  openAppSettings(): Promise<boolean>;

  // Check Multiple Permissions
  checkMultiplePermissions(): Promise<MultiplePermissionsResult>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('RnMediaPermissions');
