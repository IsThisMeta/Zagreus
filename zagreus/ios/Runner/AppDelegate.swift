import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Set up method channel for notification permissions
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "app.zagreus/notifications",
                                        binaryMessenger: controller.binaryMessenger)
      
      channel.setMethodCallHandler { (call, result) in
        switch call.method {
        case "requestPermission":
          self.requestNotificationPermission { granted in
            result(granted)
          }
        case "checkPermission":
          self.checkNotificationPermission { allowed in
            result(allowed)
          }
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
    print("Zagreus: Requesting notification permission")
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        print("Zagreus: Permission granted: \(granted), error: \(String(describing: error))")
        DispatchQueue.main.async {
          if granted {
            print("Zagreus: Registering for remote notifications")
            UIApplication.shared.registerForRemoteNotifications()
          }
          completion(granted)
        }
      }
    } else {
      let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      UIApplication.shared.registerUserNotificationSettings(settings)
      UIApplication.shared.registerForRemoteNotifications()
      completion(true)
    }
  }
  
  private func checkNotificationPermission(completion: @escaping (Bool) -> Void) {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        completion(settings.authorizationStatus == .authorized)
      }
    } else {
      completion(UIApplication.shared.currentUserNotificationSettings?.types != [])
    }
  }
  
  // Handle receiving the device token
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    print("Zagreus: Received device token: \(token)")
    
    // Send token to Flutter
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "app.zagreus/notifications",
                                        binaryMessenger: controller.binaryMessenger)
      channel.invokeMethod("onToken", arguments: token)
      print("Zagreus: Sent token to Flutter")
    } else {
      print("Zagreus: Failed to get FlutterViewController")
    }
  }
  
  // Handle registration failure
  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("Failed to register for remote notifications: \(error)")
  }
}
