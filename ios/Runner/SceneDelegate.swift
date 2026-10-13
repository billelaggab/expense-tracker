import Flutter
import UIKit
import GoogleMobileAds

class SceneDelegate: FlutterSceneDelegate {
    override func sceneDidBecomeActive(_ scene: UIScene) {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
}
