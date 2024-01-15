//
//  CounterManager.swift
//  LiveObjectDetection
//
//  Created by deq on 13/01/24.
//

import Foundation
import UIKit

import Foundation

@objc(SwiftReactModule)
class SwiftReactModule: NSObject {
  
  @objc
  static func requiresMainQueueSetup() -> Bool {
    return true
  }
    
  @objc func liveTextDetection() {
    DispatchQueue.main.async {
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let vc = storyboard.instantiateViewController(withIdentifier: "TextDetector") as! UIViewController
      UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true, completion: nil)
    }
  }
    
  @objc func liveObjectDetection() {
    DispatchQueue.main.async {
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let vc = storyboard.instantiateViewController(withIdentifier: "ObjectDetector") as! UIViewController
      UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true, completion: nil)
    }
  }
}
