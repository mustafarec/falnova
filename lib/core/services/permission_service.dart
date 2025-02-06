import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
      Permission.photos,
    ].request();

    if (statuses[Permission.camera]!.isDenied) {
      await openAppSettings();
    }
  }

  static Future<bool> checkCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  static Future<bool> checkStoragePermission() async {
    return await Permission.storage.isGranted;
  }

  static Future<bool> checkPhotosPermission() async {
    return await Permission.photos.isGranted;
  }
}
