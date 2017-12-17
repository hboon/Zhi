//
//  UIViewController+Styler.swift
//  Zhi
//
//  Created by Hwee-Boon Yar on Dec/14/17.
//  Copyright © 2017 Hwee-Boon Yar. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
	func zhiCreateStyler(directory: String?=nil) -> Zhi.Styler {
		var dir = directory
		if dir == nil {
			dir = Bundle.main.infoDictionary?["STYLES_DIRECTORY"] as? String
		}
		return Zhi.Styler(name: String(describing: type(of: self)), directory: dir)
	}
}
