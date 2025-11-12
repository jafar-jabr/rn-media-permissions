import React from 'react';
import { View, StyleSheet, Text, Button } from 'react-native';

import * as NativeMediaPermissions from 'rn-media-permissions';

function App(): React.JSX.Element {
  const [value, setValue] = React.useState<string | null>(null);

  function camera() {
    NativeMediaPermissions?.requestCameraPermission();
  }
  function photo() {
    NativeMediaPermissions?.requestPhotoLibraryPermission();
  }
  function microphone() {
    NativeMediaPermissions?.requestMicrophonePermission();
  }
  function setting() {
    NativeMediaPermissions?.openAppSettings();
  }
  async function checkCamera() {
    const check = await NativeMediaPermissions?.getCameraPermissionStatus();
    setValue(`camera status: ${check}`);
  }
  async function checkLibrary() {
    const check =
      await NativeMediaPermissions?.getPhotoLibraryPermissionStatus();
    setValue(`photo library status: ${check}`);
  }
  async function checkMicrophone() {
    const check = await NativeMediaPermissions?.getMicrophonePermissionStatus();
    setValue(`microphone status: ${check}`);
  }
  async function checkAll() {
    const allCheck = await NativeMediaPermissions?.checkMultiplePermissions();
    setValue(`all status: ${JSON.stringify(allCheck)}`);
  }
  return (
    <View style={styles.container}>
      <Text style={styles.text}>
        Current Media Permissions status: {value ?? 'No Value'}
      </Text>
      <Button title="microphone" onPress={microphone} />
      <Button title="photo" onPress={photo} />
      <Button title="Cemara" onPress={camera} />
      <Button title="setting" onPress={setting} />
      <Button title="checkCamera" onPress={checkCamera} />
      <Button title="checkMicrophone" onPress={checkMicrophone} />
      <Button title="checkLibrary" onPress={checkLibrary} />
      <Button title="checkAll" onPress={checkAll} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    paddingTop: 70,
    flex: 1,
  },
  text: {
    margin: 10,
    fontSize: 20,
    color: 'blue',
  },
});

export default App;
