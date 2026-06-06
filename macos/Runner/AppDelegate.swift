import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
  
  override func application(_ sender: NSApplication, openFile filename: String) -> Bool {
    // 将文件路径传递给 Flutter
    if let controller = mainFlutterWindow?.contentViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "com.markflowy/file_open",
        binaryMessenger: controller.engine.binaryMessenger
      )
      channel.invokeMethod("openFile", arguments: filename)
    }
    return true
  }
  
  override func application(_ sender: NSApplication, openFiles filenames: [String]) {
    for filename in filenames {
      _ = application(sender, openFile: filename)
    }
  }
}
