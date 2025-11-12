# 🎯 rn-media-permissions

> Lightweight, zero-configuration **React Native TurboModule** for handling media-related permissions under the **New Architecture**.

`rn-media-permissions` provides a unified, Promise-based API for requesting and checking camera, microphone, and photo-library permissions - without any manual native configuration.

---

## 🚀 Features

- 🧩 **TurboModule** implementation - built for the **New Architecture**
- ⚡ **Zero native setup** - works out of the box
- 📸 Supports **Camera**, **Microphone**, and **Photo Library** permissions
- 🧠 Simple, type-safe, Promise-based API
- 🛠 Includes utility methods for checking multiple permissions
- ⚙️ Provides `openAppSettings()` helper to jump to system settings

---

## 📦 Installation

```bash
yarn add rn-media-permissions
# or
npm install rn-media-permissions
```

> Requires **React Native 0.71+** with the **New Architecture (TurboModules)** enabled.

---

## 🧠 Usage

```tsx
import * as RnMediaPermissions from 'rn-media-permissions';

async function requestPermissions() {
  const camera = await RnMediaPermissions.requestCameraPermission();
  const mic = await RnMediaPermissions.requestMicrophonePermission();

  console.log('Camera:', camera);
  console.log('Microphone:', mic);
}
```

---

## 📘 API Reference

### PermissionStatus

```ts
type PermissionStatus =
  | 'granted'
  | 'denied'
  | 'restricted'
  | 'not_determined'
  | 'limited'
  | 'unknown';
```

### Methods

| Method | Description | Returns |
|--------|--------------|----------|
| `requestCameraPermission()` | Ask for camera access | `Promise<PermissionStatus>` |
| `getCameraPermissionStatus()` | Check current camera permission | `Promise<PermissionStatus>` |
| `requestPhotoLibraryPermission()` | Ask for photo-library access | `Promise<PermissionStatus>` |
| `getPhotoLibraryPermissionStatus()` | Check current photo-library permission | `Promise<PermissionStatus>` |
| `requestMicrophonePermission()` | Ask for microphone access | `Promise<PermissionStatus>` |
| `getMicrophonePermissionStatus()` | Check current microphone permission | `Promise<PermissionStatus>` |
| `openAppSettings()` | Open device app-settings page | `Promise<boolean>` |
| `checkMultiplePermissions()` | Return statuses for all supported permissions | `Promise<Record<string, PermissionStatus>>` |

---

## 🧩 Example

```tsx
import * as RnMediaPermissions from 'rn-media-permissions';

async function checkAll() {
  const results = await RnMediaPermissions.checkMultiplePermissions();
  console.log(results);
}
```

Example output:

```json
{
  "camera": "granted",
  "microphone": "denied",
  "photoLibrary": "not_determined"
}
```

---

## 🧱 iOS Setup

Add the following to your app's `ios/<AppName>/Info.plist` if not already present:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to capture photos and videos</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for audio recording</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to save and select media</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need photo library access to save photos</string>
```

---

## 🧱 Supported Platforms

| Platform | Supported | Notes |
|-----------|------------|-------|
| iOS | ✅ | Uses native `AVCaptureDevice` and `PHPhotoLibrary` |
| Android | ✅ | Uses `Manifest.permission.*` APIs |
| Web | ❌ | Not supported |

---

## ⚙️ Native Setup

None required.
This library registers itself automatically as a **TurboModule** during initialization - no changes to `Info.plist` or `AndroidManifest.xml` are needed (except for the privacy usage keys listed above).

---

## 🧪 Example Project

A runnable example app is included in the repository at [`example/`](./example):

```bash
cd example
yarn install
yarn android
# or
yarn ios
```

---

## 💡 Motivation

Existing libraries like `react-native-permissions` require manual native configuration and platform-specific setup.
`rn-media-permissions` was created to simplify the most common media-permission workflows and work natively with the **React Native New Architecture**.

---

## 📄 License

MIT © Jafar Jabr

