package com.rnmediapermissions

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.annotations.ReactModule
import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.WritableNativeMap
import com.facebook.react.modules.core.PermissionAwareActivity
import com.facebook.react.modules.core.PermissionListener

@ReactModule(name = RnMediaPermissionsModule.NAME)
class RnMediaPermissionsModule(reactContext: ReactApplicationContext) :
  NativeRnMediaPermissionsSpec(reactContext), PermissionListener {

  companion object {
    const val NAME = "RnMediaPermissions"
    private const val CAMERA_PERMISSION_REQUEST_CODE = 1001
    private const val PHOTO_LIBRARY_PERMISSION_REQUEST_CODE = 1002
    private const val MICROPHONE_PERMISSION_REQUEST_CODE = 1003
  }

  private var cameraPermissionPromise: Promise? = null
  private var photoLibraryPermissionPromise: Promise? = null
  private var microphonePermissionPromise: Promise? = null

  override fun getName(): String = NAME

  private fun mapPermissionStatus(permission: String): String {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
      return "granted"
    }

    val status = ContextCompat.checkSelfPermission(reactApplicationContext, permission)

    if (status == PackageManager.PERMISSION_GRANTED) {
      return "granted"
    }

    val activity = currentActivity
    if (activity != null && ActivityCompat.shouldShowRequestPermissionRationale(activity, permission)) {
      return "denied"
    }

    return "not_determined"
  }

  override fun requestCameraPermission(promise: Promise) {
    val activity = currentActivity as? PermissionAwareActivity

    if (activity == null) {
      promise.reject("E_ACTIVITY_DOES_NOT_EXIST", "Activity doesn't exist")
      return
    }

    val permission = Manifest.permission.CAMERA
    val status = ContextCompat.checkSelfPermission(reactApplicationContext, permission)

    if (status == PackageManager.PERMISSION_GRANTED) {
      promise.resolve("granted")
      return
    }

    cameraPermissionPromise = promise
    activity.requestPermissions(
      arrayOf(permission),
      CAMERA_PERMISSION_REQUEST_CODE,
      this
    )
  }

  override fun getCameraPermissionStatus(promise: Promise) {
    val status = mapPermissionStatus(Manifest.permission.CAMERA)
    promise.resolve(status)
  }

  override fun requestPhotoLibraryPermission(promise: Promise) {
    val activity = currentActivity as? PermissionAwareActivity

    if (activity == null) {
      promise.reject("E_ACTIVITY_DOES_NOT_EXIST", "Activity doesn't exist")
      return
    }

    val permission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      Manifest.permission.READ_MEDIA_IMAGES
    } else {
      Manifest.permission.READ_EXTERNAL_STORAGE
    }

    val status = ContextCompat.checkSelfPermission(reactApplicationContext, permission)

    if (status == PackageManager.PERMISSION_GRANTED) {
      promise.resolve("granted")
      return
    }

    photoLibraryPermissionPromise = promise
    activity.requestPermissions(
      arrayOf(permission),
      PHOTO_LIBRARY_PERMISSION_REQUEST_CODE,
      this
    )
  }

  override fun getPhotoLibraryPermissionStatus(promise: Promise) {
    val permission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      Manifest.permission.READ_MEDIA_IMAGES
    } else {
      Manifest.permission.READ_EXTERNAL_STORAGE
    }
    val status = mapPermissionStatus(permission)
    promise.resolve(status)
  }

  override fun requestMicrophonePermission(promise: Promise) {
    val activity = currentActivity as? PermissionAwareActivity

    if (activity == null) {
      promise.reject("E_ACTIVITY_DOES_NOT_EXIST", "Activity doesn't exist")
      return
    }

    val permission = Manifest.permission.RECORD_AUDIO
    val status = ContextCompat.checkSelfPermission(reactApplicationContext, permission)

    if (status == PackageManager.PERMISSION_GRANTED) {
      promise.resolve("granted")
      return
    }

    microphonePermissionPromise = promise
    activity.requestPermissions(
      arrayOf(permission),
      MICROPHONE_PERMISSION_REQUEST_CODE,
      this
    )
  }

  override fun getMicrophonePermissionStatus(promise: Promise) {
    val status = mapPermissionStatus(Manifest.permission.RECORD_AUDIO)
    promise.resolve(status)
  }

  override fun openAppSettings(promise: Promise) {
    try {
      val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
        data = Uri.fromParts("package", reactApplicationContext.packageName, null)
        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      }
      reactApplicationContext.startActivity(intent)
      promise.resolve(true)
    } catch (e: Exception) {
      promise.reject("E_FAILED_TO_OPEN_SETTINGS", "Failed to open settings", e)
    }
  }

  override fun checkMultiplePermissions(promise: Promise) {
    val permissions = WritableNativeMap()

    permissions.putString("camera", mapPermissionStatus(Manifest.permission.CAMERA))

    val photoPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      Manifest.permission.READ_MEDIA_IMAGES
    } else {
      Manifest.permission.READ_EXTERNAL_STORAGE
    }
    permissions.putString("photoLibrary", mapPermissionStatus(photoPermission))

    permissions.putString("microphone", mapPermissionStatus(Manifest.permission.RECORD_AUDIO))

    promise.resolve(permissions)
  }

  override fun onRequestPermissionsResult(
    requestCode: Int,
    permissions: Array<String>,
    grantResults: IntArray
  ): Boolean {
    if (grantResults.isEmpty()) {
      return false
    }

    val granted = grantResults[0] == PackageManager.PERMISSION_GRANTED
    val result = if (granted) "granted" else "denied"

    return when (requestCode) {
      CAMERA_PERMISSION_REQUEST_CODE -> {
        cameraPermissionPromise?.resolve(result)
        cameraPermissionPromise = null
        true
      }
      PHOTO_LIBRARY_PERMISSION_REQUEST_CODE -> {
        photoLibraryPermissionPromise?.resolve(result)
        photoLibraryPermissionPromise = null
        true
      }
      MICROPHONE_PERMISSION_REQUEST_CODE -> {
        microphonePermissionPromise?.resolve(result)
        microphonePermissionPromise = null
        true
      }
      else -> false
    }
  }
}
