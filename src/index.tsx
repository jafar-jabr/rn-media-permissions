import RnMediaPermissions from './NativeRnMediaPermissions';

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

export function requestCameraPermission(): Promise<PermissionStatus> {
  return RnMediaPermissions.requestCameraPermission();
}

export function getCameraPermissionStatus(): Promise<PermissionStatus> {
  return RnMediaPermissions.getCameraPermissionStatus();
}

export function requestPhotoLibraryPermission(): Promise<PermissionStatus> {
  return RnMediaPermissions.requestPhotoLibraryPermission();
}

export function getPhotoLibraryPermissionStatus(): Promise<PermissionStatus> {
  return RnMediaPermissions.getPhotoLibraryPermissionStatus();
}

export function requestMicrophonePermission(): Promise<PermissionStatus> {
  return RnMediaPermissions.requestMicrophonePermission();
}

export function getMicrophonePermissionStatus(): Promise<PermissionStatus> {
  return RnMediaPermissions.getMicrophonePermissionStatus();
}

export function openAppSettings(): Promise<boolean> {
  return RnMediaPermissions.openAppSettings();
}

export function checkMultiplePermissions(): Promise<MultiplePermissionsResult> {
  return RnMediaPermissions.checkMultiplePermissions();
}
