//
//  BackgroundView.swift
//  Flash
//
//  Created by Conor Mulligan on 15/05/2023.
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

/// The background view.
class BackgroundView: UIView {

    /// The background fill color.
    var fillColor = UIColor.black

    /// The background shape corner radius.
    var cornerRadius: CGFloat = 5

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Drawing

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        ctx.saveGState()

        let x: CGFloat = (frame.width  - rect.width) / 2
        let y: CGFloat = (frame.height - rect.height) / 2

        let rect = CGRect(x: x, y: y, width: rect.width, height: rect.height)
        let clipPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath

        ctx.addPath(clipPath)
        ctx.setFillColor(fillColor.cgColor)

        ctx.closePath()
        ctx.fillPath()
        ctx.restoreGState()
    }
}
