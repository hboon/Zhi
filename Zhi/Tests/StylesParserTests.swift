//
//  StylesParserTests.swift
//  Zhi
//
//  Created by Hwee-Boon Yar on Dec/13/17.
//  Copyright © 2017 Hwee-Boon Yar. All rights reserved.
//

import XCTest

class StylesParserTests: XCTestCase {
	let stylesParser = Zhi.StylesParser()
	let vv = UIView()
	let celf = UIView()
	
	override func setUp() {
        super.setUp()
		Zhi.Styler.logEnabled = true
		//I wish there's a better place to just call this once
		vv.addSubview(celf)
    }
	
    override func tearDown() {
        super.tearDown()
    }
	
    func testBasic() {
		let constraints = stylesParser.parse(styles: ["celf.left = vv.left*1 + 10"], views: mapping())
		XCTAssert(constraints.count == 1)
		XCTAssertEqual(constraints[0].firstItem as! UIView, celf)
		XCTAssertEqual(constraints[0].firstAttribute, .left)
		XCTAssertEqual(constraints[0].secondItem as! UIView, vv)
		XCTAssertEqual(constraints[0].secondAttribute, .left)
		XCTAssertEqual(constraints[0].multiplier, 1)
		XCTAssertEqual(constraints[0].constant, 10)
    }
	
	func testBasicDivision() {
		let constraints = stylesParser.parse(styles: ["celf.left = vv.left/2 + 10"], views: mapping())
		XCTAssert(constraints.count == 1)
		XCTAssertEqual(constraints[0].firstItem as! UIView, celf)
		XCTAssertEqual(constraints[0].firstAttribute, .left)
		XCTAssertEqual(constraints[0].secondItem as! UIView, vv)
		XCTAssertEqual(constraints[0].secondAttribute, .left)
		XCTAssertEqual(constraints[0].multiplier, 0.5)
		XCTAssertEqual(constraints[0].constant, 10)
	}
	
	func testBasicNegativeConstant() {
		let constraints = stylesParser.parse(styles: ["celf.left = vv.left*1 - 20"], views: mapping())
		XCTAssert(constraints.count == 1)
		XCTAssertEqual(constraints[0].firstItem as! UIView, celf)
		XCTAssertEqual(constraints[0].firstAttribute, .left)
		XCTAssertEqual(constraints[0].secondItem as! UIView, vv)
		XCTAssertEqual(constraints[0].secondAttribute, .left)
		XCTAssertEqual(constraints[0].multiplier, 1)
		XCTAssertEqual(constraints[0].constant, -20)
	}

	func testMultiplier() {
		let constraints = stylesParser.parse(styles: ["celf.left = vv.left*3.2"], views: mapping())
		XCTAssert(constraints.count == 1)
		XCTAssertEqual(constraints[0].firstItem as! UIView, celf)
		XCTAssertEqual(constraints[0].firstAttribute, .left)
		XCTAssertEqual(constraints[0].secondItem as! UIView, vv)
		XCTAssertEqual(constraints[0].secondAttribute, .left)
		XCTAssertEqual(constraints[0].multiplier, 3.2, accuracy: 0.0000001)
		XCTAssertEqual(constraints[0].constant, 0)
	}

	func testNoConstant() {
		let constraints = stylesParser.parse(styles: ["celf.left = vv.left*1"], views: mapping())
		XCTAssert(constraints.count == 1)
		XCTAssertEqual(constraints[0].firstItem as! UIView, celf)
		XCTAssertEqual(constraints[0].firstAttribute, .left)
		XCTAssertEqual(constraints[0].secondItem as! UIView, vv)
		XCTAssertEqual(constraints[0].secondAttribute, .left)
		XCTAssertEqual(constraints[0].multiplier, 1)
		XCTAssertEqual(constraints[0].constant, 0)
	}

	func testNoMultiplierNoConstant() {
		let constraints = stylesParser.parse(styles: ["celf.left = vv.left"], views: mapping())
		XCTAssert(constraints.count == 1)
		XCTAssertEqual(constraints[0].firstItem as! UIView, celf)
		XCTAssertEqual(constraints[0].firstAttribute, .left)
		XCTAssertEqual(constraints[0].secondItem as! UIView, vv)
		XCTAssertEqual(constraints[0].secondAttribute, .left)
		XCTAssertEqual(constraints[0].multiplier, 1)
		XCTAssertEqual(constraints[0].constant, 0)
	}

	func testNoMultiplierHasConstant() {
		let constraints = stylesParser.parse(styles: ["celf.left = vv.left + 10"], views: mapping())
		XCTAssert(constraints.count == 1)
		XCTAssertEqual(constraints[0].firstItem as! UIView, celf)
		XCTAssertEqual(constraints[0].firstAttribute, .left)
		XCTAssertEqual(constraints[0].secondItem as! UIView, vv)
		XCTAssertEqual(constraints[0].secondAttribute, .left)
		XCTAssertEqual(constraints[0].multiplier, 1)
		XCTAssertEqual(constraints[0].constant, 10)
	}
	
	func testNoOtherItemOnlyPositiveConstant() {
		let constraints = stylesParser.parse(styles: ["celf.width = 10"], views: mapping())
		XCTAssert(constraints.count == 1)
		XCTAssertEqual(constraints[0].firstItem as! UIView, celf)
		XCTAssertEqual(constraints[0].firstAttribute, .width)
		XCTAssertNil(constraints[0].secondItem)
		XCTAssertEqual(constraints[0].secondAttribute, .notAnAttribute)
		XCTAssertEqual(constraints[0].multiplier, 1)
		XCTAssertEqual(constraints[0].constant, 10)
	}
	
	func testNoOtherItemOnlyNegativeConstant() {
		let constraints = stylesParser.parse(styles: ["celf.width = -10"], views: mapping())
		XCTAssert(constraints.count == 1)
		XCTAssertEqual(constraints[0].firstItem as! UIView, celf)
		XCTAssertEqual(constraints[0].firstAttribute, .width)
		XCTAssertNil(constraints[0].secondItem)
		XCTAssertEqual(constraints[0].secondAttribute, .notAnAttribute)
		XCTAssertEqual(constraints[0].multiplier, 1)
		XCTAssertEqual(constraints[0].constant, -10)
	}
	
	func testMissingMultiplierAfterOperator() {
		let constraints = stylesParser.parse(styles: ["celf.left = vv.left*"], views: mapping())
		XCTAssert(constraints.count == 1)
		XCTAssertEqual(constraints[0].firstItem as! UIView, celf)
		XCTAssertEqual(constraints[0].firstAttribute, .left)
		XCTAssertEqual(constraints[0].secondItem as! UIView, vv)
		XCTAssertEqual(constraints[0].secondAttribute, .left)
		XCTAssertEqual(constraints[0].multiplier, 1)
		XCTAssertEqual(constraints[0].constant, 0)
		XCTAssertEqual(Zhi.Styler.lastLog, "No multiplier provided after Optional(*): celf.left = vv.left*")
	}
	
	func testMissingConstantAfterOperator() {
		let constraints = stylesParser.parse(styles: ["celf.left = vv.left*2 + "], views: mapping())
		XCTAssert(constraints.count == 1)
		XCTAssertEqual(constraints[0].firstItem as! UIView, celf)
		XCTAssertEqual(constraints[0].firstAttribute, .left)
		XCTAssertEqual(constraints[0].secondItem as! UIView, vv)
		XCTAssertEqual(constraints[0].secondAttribute, .left)
		XCTAssertEqual(constraints[0].multiplier, 2)
		XCTAssertEqual(constraints[0].constant, 0)
		XCTAssertEqual(Zhi.Styler.lastLog, "No constant provided after Optional(+): celf.left = vv.left*2 +")
	}

	func mapping() -> [String:UIView] {
		return ["celf" : celf, "vv" : vv]
	}
}
