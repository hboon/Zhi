//
//  Styler.swift
//  Zhi
//
//  Created by Hwee-Boon Yar on Dec/13/17.
//  Copyright © 2017 Hwee-Boon Yar. All rights reserved.
//

import Foundation
import UIKit
import KZFileWatchers

public extension Zhi {
	class Styler {
		static var logEnabled = false
		static var lastLog = ""

		let refreshInterval = TimeInterval(1)/60
		var views = [String: UIView]()
		var metrics = [String: Any]()
		var keepTranslateAutoResizingMaskForView: UIView?
		let name: String
		let directory: String?
		var reloadFromLiveVersion = false
		var livePath: String? {
			if let directory = directory {
				return URL(fileURLWithPath: directory, isDirectory: true).appendingPathComponent("\(name).styles").path
			} else {
				return nil
			}
		}
		var bundlePath: String? {
			return Bundle.main.path(forResource: name, ofType: "styles")
		}
		var path: String? {
			if reloadFromLiveVersion {
				return livePath
			} else {
				return bundlePath
			}
		}

		init(name: String, directory: String?=nil) {
			self.name = name
			self.directory = directory
		}

		static func log(_ string: String) {
			if Styler.logEnabled {
				print("[Styler] \(string)")
				Styler.lastLog = string
			}
		}

		func constraints() -> [NSLayoutConstraint] {
			let styles = readStyles()
			return convertToConstraints(styles: styles)
		}

		func liveReload(view: UIView) {
			setUpStylesChangeWatcher(view: view)
		}

		func style(view: UIView) {
			view.removeConstraints(view.constraints)
			view.addConstraints(constraints())
		}

		private func readStyles() -> [String] {
			do {
				if let path = path {
					let contents = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
					return contents.components(separatedBy: "\n")
				} else {
					return []
				}
			} catch let error {
				Styler.log("Error reading style file: \(String(describing: path)) Error: \(error)")
				return []
			}
		}

		private func convertToConstraints(styles: [String]) -> [NSLayoutConstraint] {
			let stylesParser = StylesParser()
			return stylesParser.parse(styles: styles, views: views, metrics: metrics, keepTranslateAutoResizingMask: keepTranslateAutoResizingMaskForView)
		}

		private func setUpStylesChangeWatcher(view: UIView) {
			// Check for directory is still needed despite checking livePath later because we want to be able to not show the Live reloading message when not in development mode (and directory="")
			guard let directory = directory, !directory.isEmpty else { return }
			Styler.log("Live reloading styles from: \(String(describing: livePath))")
			guard let livePath = livePath else { return }
			let watcher = FileWatcher.Local(path: livePath, refreshInterval: refreshInterval)
			do {
				try watcher.start { results in
					switch results {
					case .noChanges:
						break
					case .updated:
						self.reloadFromLiveVersion = true
						Styler.log("Reloading styles for: \(self.name)")
						view.setNeedsUpdateConstraints()
					}
				}
			} catch let error {
				Styler.log("Error watching styles: \(error)")
			}
			//try watcher.stop()
		}
	}
}
