//
//  SceneDelegate.swift
//  AsciiFilter
//
//  Created by Joshua Homann on 2/29/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = UIHostingController(rootView: FilteredImageView())
      self.window = window
      window.makeKeyAndVisible()
    }
  }

}

