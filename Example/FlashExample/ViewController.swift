//
//  ViewController.swift
//  FlashExample
//
//  Created by Conor Mulligan on 09/07/2022.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import Flash

class ViewController: UIViewController {

    let alertButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Show Alert", comment: ""), for: .normal)
        button.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.layer.cornerRadius = 10
        button.layer.cornerCurve = .continuous
        return button
    }()

    let errorButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Show Error", comment: ""), for: .normal)
        button.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.layer.cornerRadius = 10
        button.layer.cornerCurve = .continuous
        return button
    }()

    // MARK: - Initialization

    required init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        view.addSubview(alertButton)
        view.addSubview(errorButton)

        alertButton.addAction(UIAction { [unowned self] _ in
            self.showFlashAlert()
        }, for: .touchUpInside)

        errorButton.addAction(UIAction { [unowned self] _ in
            self.showFlashError()
        }, for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        alertButton.sizeToFit()
        errorButton.sizeToFit()

        let spacing: CGFloat = 15
        let margins = view.layoutMargins
        let safeArea = view.bounds.inset(by: margins)

        let alertHeight = alertButton.frame.size.height + 10
        alertButton.frame = CGRect(
            x: margins.left,
            y: ((safeArea.size.height - spacing) / 2) - alertHeight,
            width: safeArea.size.width,
            height: alertHeight
        )

        let errorHeight = errorButton.frame.size.height + 10
        errorButton.frame = CGRect(
            x: margins.left,
            y: alertButton.frame.maxY + spacing,
            width: safeArea.size.width,
            height: errorHeight
        )
    }

    func showFlashAlert() {
        let flash = FlashView(
            text: NSLocalizedString("This is a flash message!", comment: ""),
            image: UIImage(systemName: "info.circle.fill")
        )
        flash.show(in: self.view)
    }

    func showFlashError() {
        let flash = FlashView(
            text: NSLocalizedString("This is a flash error!", comment: ""),
            image: UIImage(systemName: "exclamationmark.triangle.fill")
        )
        flash.backgroundColor = .systemRed
        flash.textLabel.textColor = .white
        flash.tintColor = .white.withAlphaComponent(0.6)
        flash.show(in: self.view)
    }
}
