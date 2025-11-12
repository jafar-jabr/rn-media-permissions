import { TurboModuleRegistry } from 'react-native';
import * as RnMediaPermissions from '../index';

jest.mock('react-native', () => {
  const actual = jest.requireActual('react-native');

  const originalGetEnforcing = actual.TurboModuleRegistry.getEnforcing.bind(
    actual.TurboModuleRegistry
  );

  actual.TurboModuleRegistry.getEnforcing = jest.fn((name: string) => {
    if (name === 'RnMediaPermissions') {
      return {
        requestCameraPermission: jest.fn(async () => 'granted'),
        getCameraPermissionStatus: jest.fn(async () => 'granted'),
        requestPhotoLibraryPermission: jest.fn(async () => 'denied'),
        getPhotoLibraryPermissionStatus: jest.fn(async () => 'not_determined'),
        requestMicrophonePermission: jest.fn(async () => 'granted'),
        getMicrophonePermissionStatus: jest.fn(async () => 'granted'),
        openAppSettings: jest.fn(async () => true),
        checkMultiplePermissions: jest.fn(async () => ({
          camera: 'granted',
          microphone: 'granted',
          photoLibrary: 'denied',
        })),
      };
    }

    return originalGetEnforcing(name);
  });

  return actual;
});

describe('RnMediaPermissions TurboModule', () => {
  it('should call and return permission statuses correctly', async () => {
    const cameraStatus = await RnMediaPermissions.requestCameraPermission();
    const micStatus = await RnMediaPermissions.getMicrophonePermissionStatus();
    const all = await RnMediaPermissions.checkMultiplePermissions();

    expect(cameraStatus).toBe('granted');
    expect(micStatus).toBe('granted');
    expect(all).toEqual({
      camera: 'granted',
      microphone: 'granted',
      photoLibrary: 'denied',
    });

    expect(TurboModuleRegistry.getEnforcing).toHaveBeenCalledWith(
      'RnMediaPermissions'
    );
  });
});
