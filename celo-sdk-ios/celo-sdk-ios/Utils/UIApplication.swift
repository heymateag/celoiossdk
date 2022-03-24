//
//  UIApplication.swift
//   
//
//    .
//   .
//

import UIKit
extension UIWindow {
    static func getTopViewControllerwindow() -> UIViewController? {
        if #available(iOS 13, *){
            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            
            if var topController = keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                return topController
            }
        } else {
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                return topController
            }
        }
        return nil
    }
}
extension UIApplication {
    /// EZSE: Run a block in background after app resigns activity
    public func runInBackground(_ closure: @escaping () -> Void, expirationHandler: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let taskID: UIBackgroundTaskIdentifier
            if let expirationHandler = expirationHandler {
                taskID = self.beginBackgroundTask(expirationHandler: expirationHandler)
            } else {
                taskID = self.beginBackgroundTask(expirationHandler: {})
            }
            closure()
            self.endBackgroundTask(taskID)
        }
    }
    
    public class func getTopMostViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        } else {
            return nil
        }
    }

    /// EZSE: Get the top most view controller from the base view controller;
    /// default param is UIWindow's rootViewController
    public class func topViewController(_ base: UIViewController? =
                                            UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }

    public class func topNavigationController() -> UINavigationController? {
        return UIApplication.topViewController()?.navigationController
    }
}
