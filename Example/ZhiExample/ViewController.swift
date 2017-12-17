//
//  ViewController.swift
//  Zhi
//
//  Created by Hwee-Boon Yar on Dec/11/17.
//  Copyright © 2017 Hwee-Boon Yar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	let mainView = UIView()
	// swiftlint:disable:next identifier_name
	let v1 = UIView()
	// swiftlint:disable:next identifier_name
	let v2 = UIView()
	let label = UILabel()
	let button = UIButton(type: .system)
	let imageView = UIImageView()
	lazy var styler = zhiCreateStyler()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .red
		createViews()

		styler.views = ["celf": mainView, "v1": v1, "v2": v2, "b": button, "l": label, "i": imageView]
		styler.metrics = ["m": 100, "k": 50]
		styler.keepTranslateAutoResizingMaskForView = mainView
		styler.liveReload(view: view)

		view.setNeedsUpdateConstraints()
	}

	func createViews() {
		mainView.frame = view.bounds
		mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		view.addSubview(mainView)

		button.setTitle("Hit me", for: .normal)
		button.addTarget(self, action: #selector(openViewController), for: .touchUpInside)

		mainView.addSubview(v1)
		mainView.addSubview(v2)
		mainView.addSubview(label)
		mainView.addSubview(imageView)
		mainView.addSubview(button)
	}

	override func updateViewConstraints() {
		styler.style(view: mainView)

		super.updateViewConstraints()
	}

	@objc func openViewController() {
		show(ViewController2(), sender: nil)
	}
}
