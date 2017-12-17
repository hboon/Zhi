//
//  StylesParser.swift
//  Zhi
//
//  Created by Hwee-Boon Yar on Dec/12/17.
//  Copyright © 2017 Hwee-Boon Yar. All rights reserved.
//

import Foundation
import UIKit

public extension Zhi {
	class StylesParser {
		let metricsPrefix = "##"
		let commentPrefix = "#"

		func parse(styles: [String], views: [String: UIView], metrics: [String: Any]=[:], keepTranslateAutoResizingMask: UIView?=nil) -> [NSLayoutConstraint] {
			var results = [NSLayoutConstraint]()
			var metrics = metrics
			for each in styles {
				let each = each.trimmingCharacters(in: .whitespacesAndNewlines)
				if each.isEmpty {
					continue
				}
				if each.hasPrefix(metricsPrefix) {
					metrics = parseMetric(each, metrics: metrics)
				} else if isInVisualLangaugeFormat(each) {
					let constraints = parseVisualFormatLanguage(each, views: views, metrics: metrics)
					results.append(contentsOf: constraints)
				} else if !each.hasPrefix(commentPrefix) {
					if let constraint = parseEquation(each, views: views) {
						results.append(constraint)
					}
				}
			}
			switchOffTranslateAutoresizingMaskIntoConstraints(results, exceptView: keepTranslateAutoResizingMask)
			return results
		}

		private func parseMetric(_ line: String, metrics: [String: Any]) -> [String: Any] {
			var metrics = metrics
			let values = line.components(separatedBy: "=").map { $0.trimmingCharacters(in: .whitespaces) }
			if values.count == 2 {
				let name = (values[0] as NSString).substring(from: metricsPrefix.count) as String
				if let value = Double(values[1]) {
					metrics[name] = CGFloat(value)
				} else {
					Styler.log("Invalid metric: \(line)")
				}
			} else {
				Styler.log("Invalid metric: \(line)")
			}
			return metrics
		}

		private func parseVisualFormatLanguage(_ line: String, views: [String: UIView], metrics: [String: Any]) -> [NSLayoutConstraint] {
			return NSLayoutConstraint.constraints(withVisualFormat: line, options: [], metrics: metrics, views: views)
		}

		private func parseEquation(_ line: String, views: [String: UIView]) -> NSLayoutConstraint? {
			let parser = StyleParser(style: line, views: views)
			return parser.parse()
		}

		private func isInVisualLangaugeFormat(_ line: String) -> Bool {
			return line.hasPrefix("H:") || line.hasPrefix("V:")
		}

		private func switchOffTranslateAutoresizingMaskIntoConstraints(_ constraints: [NSLayoutConstraint], exceptView excludedView: UIView?) {
			for each in constraints {
				if let view = each.firstItem as? UIView, view != excludedView {
					view.translatesAutoresizingMaskIntoConstraints = false
				}
				if let view = each.secondItem as? UIView, view != excludedView {
					view.translatesAutoresizingMaskIntoConstraints = false
				}
			}
		}
	}
}
