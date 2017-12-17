//
//  AppDelegate.swift
//  ZhiExample
//
//  Created by Hwee-Boon Yar on Dec/15/17.
//  Copyright © 2017 Hwee-Boon Yar. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		Zhi.Styler.logEnabled = true
		return true
	}
}
