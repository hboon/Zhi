//
//  ViewController2ViewController.swift
//  Zhi
//
//  Created by Hwee-Boon Yar on Dec/14/17.
//  Copyright © 2017 Hwee-Boon Yar. All rights reserved.
//

import UIKit

class ViewController2: UIViewController {
	let mainView = UIView()
	// swiftlint:disable:next identifier_name
	let v1 = UIView()
	// swiftlint:disable:next identifier_name
	let v2 = UIView()
	let searchBar = UISearchBar()
	let label = UILabel()
	let progress = UIProgressView()
	let sandwich = UISwitch()
	let slider = UISlider()
	let stepper = UIStepper()
	lazy var styler = zhiCreateStyler()

    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .purple
		createViews()

		styler.views = ["celf": mainView, "v1": v1, "v2": v2, "sb": searchBar, "l": label, "p": progress, "s": sandwich, "sl": slider, "st": stepper]
		styler.keepTranslateAutoResizingMaskForView = mainView
		styler.liveReload(view: view)

		view.setNeedsUpdateConstraints()
    }

	func createViews() {
		mainView.frame = view.bounds
		mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		view.addSubview(mainView)

		mainView.addSubview(v1)
		mainView.addSubview(v2)
		mainView.addSubview(searchBar)
		mainView.addSubview(label)
		mainView.addSubview(progress)
		mainView.addSubview(sandwich)
		mainView.addSubview(slider)
		mainView.addSubview(stepper)
	}

	override func updateViewConstraints() {
		styler.style(view: mainView)
		super.updateViewConstraints()
	}
}
