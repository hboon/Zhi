// swiftlint:disable file_length
//
//  StyleParser.swift
//  Zhi
//
//  Created by Hwee-Boon Yar on Dec/11/17.
//  Copyright © 2017 Hwee-Boon Yar. All rights reserved.
//

import Foundation
import UIKit

public extension Zhi {
	// swiftlint:disable:next type_body_length
	class StyleParser {
		let relationCharacterSet = CharacterSet(charactersIn: "<>=")
		let constantOperatorCharacterSet = CharacterSet(charactersIn: "+-")
		let multiplierOperatorCharacterSet = CharacterSet(charactersIn: "*/")
		let priorityOperatorCharacterSet = CharacterSet(charactersIn: "@")
		let identifierMarkerCharacterSet = CharacterSet(charactersIn: "#")
		lazy var leftOperandTerminatingCharacterSet: CharacterSet = {
			var cs = CharacterSet.whitespacesAndNewlines
			cs.formUnion(relationCharacterSet)
			return cs
		}()
		lazy var rightOperandTerminatingCharacterSet: CharacterSet = {
			var cs = CharacterSet.whitespacesAndNewlines
			cs.formUnion(constantOperatorCharacterSet)
			cs.formUnion(multiplierOperatorCharacterSet)
			cs.formUnion(priorityOperatorCharacterSet)
			cs.formUnion(identifierMarkerCharacterSet)
			return cs
		}()
		let attributes: [String: NSLayoutAttribute] = [
			"left": .left,
			"right": .right,
			"top": .top,
			"bottom": .bottom,
			"leading": .leading,
			"trailing": .trailing,
			"width": .width,
			"height": .height,
			"centerX": .centerX,
			"centerY": .centerY,
			"baseline": .lastBaseline,
			"lastBaseline": .lastBaseline,
			"firstBaseline": .firstBaseline,
			"leftMargin": .leftMargin,
			"rightMargin": .rightMargin,
			"topMargin": .topMargin,
			"bottomMargin": .bottomMargin,
			"leadingMargin": .leadingMargin,
			"trailingMargin": .trailingMargin,
			"centerXWithinMargins": .centerXWithinMargins,
			"centerYWithinMargins": .centerYWithinMargins
		]
		let relations: [String: NSLayoutRelation] = [
			"=": .equal,
			"<=": .lessThanOrEqual,
			">=": .greaterThanOrEqual
		]
		let contentModes: [String: UIViewContentMode] = [
			"scaleToFill": .scaleToFill,
			"scaleAspectFit": .scaleAspectFit,
			"scaleAspectFill": .scaleAspectFill,
			"redraw": .redraw,
			"center": .center,
			"top": .top,
			"bottom": .bottom,
			"left": .left,
			"right": .right,
			"topLeft": .topLeft,
			"topRight": .topRight,
			"bottomLeft": .bottomLeft,
			"bottomRight": .bottomRight
		]
		let colors: [String: UIColor] = [
			"black": .black,
			"blue": .blue,
			"brown": .brown,
			"clear": .clear,
			"cyan": .cyan,
			"darkGray": .darkGray,
			"gray": .gray,
			"green": .green,
			"lightGray": .lightGray,
			"magenta": .magenta,
			"orange": .orange,
			"purple": .purple,
			"red": .red,
			"white": .white,
			"yellow": .yellow
		]
		let fontTextStyles: [String: UIFontTextStyle] = [
			"body": .body,
			"callout": .callout,
			"caption1": .caption1,
			"caption2": .caption2,
			"footnote": .footnote,
			"headline": .headline,
			"subheadline": .subheadline,
			"largeTitle": .largeTitle,
			"title1": .title1,
			"title2": .title2,
			"title3": .title3
		]

		let style: String
		let views: [String: UIView]

		init(style: String, views: [String: UIView]) {
			self.style = style
			self.views = views
		}

		func parse() -> NSLayoutConstraint? {
			guard let values = parse(style: style) else { return nil }
			let viewName = values.leftObject
			let property = values.leftAttribute
			if let view = views[viewName], values.relation == "=" {
				let value = values.constant
				// Leaky! Refers to "progress" and "numberOfLines"
				//if value > 0 || (value == 0 && (values.leftAttribute == "progress" || values.leftAttribute)) {
				if value > 0 || (value == 0 && (["progress", "numberOfLines"].contains { $0 == values.leftAttribute })) {
					let validProperty = set(view: view, property: property, double: value)
					if validProperty {
						return nil
					}
				} else {
					let value = values.rhs
					if !value.isEmpty {
						let validProperty = set(view: view, property: property, string: value)
						if validProperty {
							return nil
						}
					}
				}
			}
			return convertToConstraint(values)
		}

		// Parsing code using Scanner is derived from https://github.com/marcoarment/CompactConstraint
		// swiftlint:disable function_body_length
		private func parse(style: String) -> ParsedStyle? {
			let scanner = Scanner(string: style)
			scanner.charactersToBeSkipped = .whitespacesAndNewlines

			var leftOperandStr: NSString?
			_ = scanner.scanUpToCharacters(from: leftOperandTerminatingCharacterSet, into: &leftOperandStr)
			//print("leftOperandStr: \(String(describing: leftOperandStr))")

			let (leftObject, leftAttribute) = split(operand: leftOperandStr!)

			var relationStr: NSString?
			_ = scanner.scanCharacters(from: relationCharacterSet, into: &relationStr)
			//print("relationStr: \(String(describing: relationStr))")
			guard let operatorNSStr = relationStr else {
				Styler.log("Missing relation in style: \(style)")
				return nil
			}
			let relation = operatorNSStr as String
			let rhs = scannerStringRemainder(scanner: scanner)

			var constant = Double(0)
			let noRightObjectAndAttribute = scanner.scanDouble(&constant)
			var rightObject = ""
			var rightAttribute = ""

			if noRightObjectAndAttribute {
				return ParsedStyle(leftObject: leftObject, leftAttribute: leftAttribute, relation: relation, rightObject: rightObject, rightAttribute: rightAttribute, multiplier: 1, constant: constant, rhs: rhs)
			}

			var rightOperandStr: NSString?
			_ = scanner.scanUpToCharacters(from: rightOperandTerminatingCharacterSet, into: &rightOperandStr)
			//print("rightOperandStr: \(String(describing: rightOperandStr))")
			(rightObject, rightAttribute) = split(operand: rightOperandStr!)

			var multiplierOperator: NSString?
			var multiplier = Double(1)
			if scanner.scanCharacters(from: multiplierOperatorCharacterSet, into: &multiplierOperator) {
				//print("multiplierOperatomultiplierOperator: \(String(describing: multiplierOperator))")
				if !scanner.scanDouble(&multiplier) {
					var rightValueStr: NSString?
					let hasMultiplierAfterOperator = scanner.scanUpToCharacters(from: rightOperandTerminatingCharacterSet, into: &rightValueStr)
					if !hasMultiplierAfterOperator {
						Styler.log("No multiplier provided after \(String(describing: multiplierOperator)): \(style)")
					}
					//print("rightValueStr: \(String(describing: rightValueStr))")
				}

				if multiplierOperator == "/" {
					multiplier = 1.0 / multiplier
				}
				//print("multiplier: \(String(describing: multiplier))")
			}

			var constantOperator: NSString?
			constant = Double(0)
			if scanner.scanCharacters(from: constantOperatorCharacterSet, into: &constantOperator) {
				//print(constantOperator)
				if !scanner.scanDouble(&constant) {
					var rightValueStr: NSString?
					let hasConstantAfterOperator = scanner.scanUpToCharacters(from: rightOperandTerminatingCharacterSet, into: &rightValueStr)
					if !hasConstantAfterOperator {
						Styler.log("No constant provided after \(String(describing: constantOperator)): \(style)")
					}
				}

				if constantOperator == "-" {
					constant = -constant
				}
	//			print("constant: \(String(describing: constant))")
			}

			return ParsedStyle(leftObject: leftObject, leftAttribute: leftAttribute, relation: relation, rightObject: rightObject, rightAttribute: rightAttribute, multiplier: multiplier, constant: constant, rhs: rhs)
		}
		// swiftlint:enable function_body_length

		private func scannerStringRemainder(scanner: Scanner) -> String {
			let index = scanner.string.index(scanner.string.startIndex, offsetBy: scanner.scanLocation)
			return String(scanner.string.suffix(from: index).trimmingCharacters(in: .whitespaces))
		}

		private func split(operand: NSString) -> (String, String) {
			let values = operand.components(separatedBy: ".")
			if values.count == 1 {
				return (values[0], "")
			}
			return (values[0], values[1])
		}

		private func convertToConstraint(_ parsedTokens: ParsedStyle) -> NSLayoutConstraint {
			let (v1, v2) = convertViewNamesToViews(parsedTokens: parsedTokens, views: views)
			let (a1, a2) = convertAttributes(parsedTokens: parsedTokens)
			let op = convertRelation(parsedTokens: parsedTokens)
			let multiplier = convertMultiplier(parsedTokens: parsedTokens)
			let constant = convertConstant(parsedTokens: parsedTokens)
			return convertConstraint(v1: v1, a1: a1, relation: op, v2: v2, a2: a2, multiplier: multiplier, constant: constant)
		}

		private func convertViewNamesToViews(parsedTokens: ParsedStyle, views: [String: UIView]) -> (UIView?, UIView?) {
			let v1 = parsedTokens.leftObject
			let v2 = parsedTokens.rightObject
			return (views[v1], views[v2])
		}

		private func convertAttributes(parsedTokens: ParsedStyle) -> (NSLayoutAttribute?, NSLayoutAttribute?) {
			let a1 = parsedTokens.leftAttribute
			let a2 = parsedTokens.rightAttribute
			if let a2 = attributes[a2] {
				return (attributes[a1], a2)
			} else {
				return (attributes[a1], .notAnAttribute)
			}
		}

		private func convertRelation(parsedTokens: ParsedStyle) -> NSLayoutRelation? {
			let op = parsedTokens.relation as String
			return relations[op]
		}

		private func convertMultiplier(parsedTokens: ParsedStyle) -> CGFloat? {
			let value = parsedTokens.multiplier
			return CGFloat(value)
		}

		private func convertConstant(parsedTokens: ParsedStyle) -> CGFloat? {
			let value = parsedTokens.constant
			return CGFloat(value)
		}

		// swiftlint:disable identifier_name
		// swiftlint:disable:next function_parameter_count
		private func convertConstraint(v1: UIView?, a1: NSLayoutAttribute?, relation: NSLayoutRelation?, v2: UIView?, a2: NSLayoutAttribute?, multiplier: CGFloat?, constant: CGFloat?) -> NSLayoutConstraint {
			// swiftlint:enable identifier_name
			return NSLayoutConstraint(item: v1 as Any, attribute: a1!, relatedBy: relation!, toItem: v2, attribute: a2!, multiplier: multiplier!, constant: constant!)
		}

		// swiftlint:disable:next cyclomatic_complexity
		private func set(view: UIView, property: String, double value: Double) -> Bool {
			switch property {
			case "fontSize":
				if let button = view as? UIButton, let label = button.titleLabel {
					label.font = label.font.withSize(CGFloat(value))
				} else if let view = view as? UILabel {
					view.font = view.font.withSize(CGFloat(value))
				} else if let view = view as? UITextField {
					if let font = view.font {
						view.font = font.withSize(CGFloat(value))
					} else {
						view.font = UIFont.systemFont(ofSize: CGFloat(value))
					}
				} else if let view = view as? UITextView {
					if let font = view.font {
						view.font = font.withSize(CGFloat(value))
					} else {
						view.font = UIFont.systemFont(ofSize: CGFloat(value))
					}
				}
			case "numberOfLines":
				if let label = view as? UILabel {
					label.numberOfLines = Int(value)
				}
			case "progress":
				if let view = view as? UIProgressView {
					view.progress = Float(value)
				}
			case "value":
				if let view = view as? UISlider {
					view.value = Float(value)
				}
			default:
				return false
			}
			return true
		}

		// swiftlint:disable cyclomatic_complexity
		// swiftlint:disable:next function_body_length
		private func set(view: UIView, property: String, string value: String) -> Bool {
			switch property {
			case "backgroundColor":
				if let color = convertColor(string: value) {
					view.backgroundColor = color
				}
			case "clipsToBounds":
				if let value = Bool(value) {
					view.clipsToBounds = value
				}
			case "color":
				if let color = convertColor(string: value) {
					if let button = view as? UIButton {
						button.setTitleColor(color, for: .normal)
					} else if let view = view as? UIActivityIndicatorView {
						view.color = color
					} else if let view = view as? UILabel {
						view.textColor = color
					} else if let view = view as? UITextField {
						view.textColor = color
					} else if let view = view as? UITextView {
						view.textColor = color
					}
				}
			case "contentMode":
				if let contentMode = contentModes[value] {
					view.contentMode = contentMode
				}
			case "fontName":
				if let button = view as? UIButton, let label = button.titleLabel {
					label.font = UIFont(name: value, size: label.font.pointSize)
				} else if let label = view as? UILabel {
					label.font = UIFont(name: value, size: label.font.pointSize)
				} else if let view = view as? UITextField {
					if let font = view.font {
						view.font = UIFont(name: value, size: font.pointSize)
					} else {
						view.font = UIFont(name: value, size: UIFont.labelFontSize)
					}
				} else if let view = view as? UITextView {
					if let font = view.font {
						view.font = UIFont(name: value, size: font.pointSize)
					} else {
						view.font = UIFont(name: value, size: UIFont.labelFontSize)
					}
				}
			case "hidden":
				if let value = Bool(value) {
					view.isHidden = value
				}
			case "isHidden":
				if let value = Bool(value) {
					view.isHidden = value
				}
			case "image":
				if let view = view as? UIImageView, let value = UIImage(named: value) {
					view.image = value
				}
			case "enabled":
				if let view = view as? UIControl, let value = Bool(value) {
					view.isEnabled = value
				} else if let view = view as? UILabel, let value = Bool(value) {
					view.isEnabled = value
				}
			case "on":
				if let view = view as? UISwitch, let value = Bool(value) {
					view.isOn = value
				}
			case "isOn":
				if let view = view as? UISwitch, let value = Bool(value) {
					view.isOn = value
				}
			case "placeholder":
				if let view = view as? UISearchBar {
					view.placeholder = value
				} else if let view = view as? UITextField {
					view.placeholder = value
				}
			case "prompt":
				if let view = view as? UISearchBar {
					view.prompt = value
				}
			case "text":
				if let view = view as? UITextField {
					view.text = value
				} else if let view = view as? UILabel {
					view.text = value
				} else if let view = view as? UISearchBar {
					view.text = value
				} else if let button = view as? UIButton {
					button.setTitle(value, for: .normal)
				}
			case "textStyle":
				if let button = view as? UIButton, let label = button.titleLabel, let textStyle = fontTextStyles[value] {
					label.font = UIFont.preferredFont(forTextStyle: textStyle)
				} else if let label = view as? UILabel, let textStyle = fontTextStyles[value] {
					label.font = UIFont.preferredFont(forTextStyle: textStyle)
				} else if let view = view as? UITextField, let textStyle = fontTextStyles[value] {
					view.font = UIFont.preferredFont(forTextStyle: textStyle)
				} else if let view = view as? UITextView, let textStyle = fontTextStyles[value] {
					view.font = UIFont.preferredFont(forTextStyle: textStyle)
				}
			case "title":
				if let button = view as? UIButton {
					button.setTitle(value, for: .normal)
				}
			case "tintColor":
				if let color = convertColor(string: value) {
					view.tintColor = color
				}
			default:
				return false
			}
			return true
		}
		// swiftlint:enable cyclomatic_complexity

		private func convertColor(string: String) -> UIColor? {
			if string.hasPrefix("rgb(") && string.hasSuffix(")") {
				return convertColor(rgbString: string)
			} else if string.hasPrefix("rgba(") && string.hasSuffix(")") {
				return convertColor(rgbaString: string)
			} else {
				return colors[string]
			}
		}

		private func convertColor(rgbString rgb: String) -> UIColor? {
			var string = rgb
			string.removeFirst("rgb(".count)
			string.removeLast()
			let components = string.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
			guard components.count == 3 else {
				Styler.log("Invalid color: \(rgb)")
				return nil
			}
			guard let r = Float(components[0]), let g = Float(components[1]), let b = Float(components[2]) else {
				Styler.log("Invalid color: \(rgb)")
				return nil
			}
			return UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: 1)
		}

		private func convertColor(rgbaString rgba: String) -> UIColor? {
			var string = rgba
			string.removeFirst("rgba(".count)
			string.removeLast()
			let components = string.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
			guard components.count == 4 else {
				Styler.log("Invalid color: \(rgba)")
				return nil
			}
			guard let r = Float(components[0]), let g = Float(components[1]), let b = Float(components[2]), let a = Float(components[3]) else {
				Styler.log("Invalid color: \(rgba)")
				return nil
			}
			return UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: CGFloat(a))
		}
	}

	private struct ParsedStyle {
		let leftObject: String
		let leftAttribute: String
		let relation: String
		let rightObject: String
		let rightAttribute: String
		let multiplier: Double
		let constant: Double
		let rhs: String
	}
}
