//
//  Flash.swift
//  Flash
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

/// A flash message animator.
public protocol FlashAnimator {
    /// Animation completion handler.
    typealias CompletionHandler = () -> Void

    /// The animation duration.
    var duration: TimeInterval { get }

    /// Animate in the flash view.
    /// - Parameters:
    ///   - flashView: The flash view to animate in.
    ///   - completion: The completion handler. This must be called when the animation has finished.
    func animateIn(_ flashView: FlashView, completion: @escaping CompletionHandler)

    /// Animate out the flash view.
    /// - Parameters:
    ///   - flashView: The flash view to animate out.
    ///   - completion: The completion handler. This must be called when the animation has finished.
    func animationOut(_ flashView: FlashView, completion: @escaping CompletionHandler)
}

/// A flash message animator that fades in and out.
public struct FadeAnimator: FlashAnimator {

    public private(set) var duration: TimeInterval

    private let timingParameters = UISpringTimingParameters(dampingRatio: 0.42,
                                                            initialVelocity: CGVector(dx: 1.0, dy: 0.2))

    /// Initialize with the supplied animation duration.
    /// - Parameter duration: The animation duration.
    public init(duration: TimeInterval) {
        self.duration = duration
    }

    private func scaleAndOffset(t: CGAffineTransform) -> CGAffineTransform {
        var transform = t.translatedBy(x: 0, y: -15)
        transform = transform.scaledBy(x: 0.95, y: 0.95)
        return transform
    }

    // MARK: - FlashAnimator Conformance

    public func animateIn(_ flashView: FlashView, completion: @escaping CompletionHandler) {
        flashView.alpha = 0
        flashView.transform = scaleAndOffset(t: flashView.transform)

        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: timingParameters)

        animator.addAnimations {
            flashView.alpha = 1
        }
        animator.addAnimations {
            flashView.transform = .identity
        }
        animator.addCompletion { _ in
            completion()
        }

        animator.startAnimation()
    }

    public func animationOut(_ flashView: FlashView, completion: @escaping CompletionHandler) {
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut)

        animator.addAnimations {
            flashView.alpha = 0
        }
        animator.addAnimations {
            flashView.transform = scaleAndOffset(t: flashView.transform)
        }
        animator.addCompletion { _ in
            completion()
        }

        animator.startAnimation()
    }
}

/// A flash message view.
public class FlashView: UIView {

    // MARK: - Properties

    /// The toast text.
    public var text: String {
        didSet { updateText(text) }
    }

    /// The toast image.
    public var image: UIImage? {
        didSet { updateImage(image) }
    }

    /// The insets used to layout a flash view within its superview.
    public var insets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15) {
        didSet { setNeedsLayout() }
    }

    /// The content insets.
    public var contentInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12) {
        didSet { setNeedsLayout() }
    }

    /// The animator.
    public let animator: FlashAnimator

    /// The timer.
    private var timer: Timer?

    /// The toast's image view.
    public private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    /// The toast's text label.
    public private(set) lazy var textLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .callout)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    // MARK: - Initialization

    public init(text: String,
                image: UIImage? = nil,
                insets: UIEdgeInsets? = nil,
                animator: FlashAnimator? = nil ) {
        self.text = text
        self.image = image
        self.insets = insets ?? self.insets
        self.animator = animator ?? FadeAnimator(duration: 0.35)
        super.init(frame: .zero)

        backgroundColor = .systemGray5
        layer.cornerRadius = 10
        layer.cornerCurve = .continuous

        [imageView, textLabel].forEach { addSubview($0) }

        updateText(text)
        updateImage(image)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setNeedsLayout()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        guard let superview = superview else { return }
                
        let safeArea = superview.bounds.inset(by: superview.safeAreaInsets)
        
        var contentBounds = safeArea.inset(by: insets)
        contentBounds.origin = .zero
        contentBounds = contentBounds.inset(by: contentInsets)
        var (f1, f2) = contentBounds.divided(atDistance: image?.size.width ?? 0, from: .minXEdge)

        let textSize = textLabel.sizeThatFits(f2.size)
        f1.size.height = textSize.height
        f2.size = textSize

        bounds.size = CGSize(width: f1.size.width + f2.size.width + contentInsets.left + contentInsets.right,
                            height: f2.size.height + contentInsets.top + contentInsets.bottom)
        center = CGPoint(x: superview.center.x, y: safeArea.minY + (bounds.size.height / 2))

        imageView.frame = f1
        textLabel.frame = f2
    }

    // MARK: - Flash

    /// Show the flash message in the supplised view.
    /// - Parameters:
    ///   - view: The view to show the flash message in.
    ///   - duration: The flash message duration.
    public func show(in view: UIView? = nil, duration: TimeInterval = 2) {
        var view = view
        if view == nil {
            let window = UIApplication.shared.windows.first(where: \.isKeyWindow)
            view = window?.rootViewController?.view
        }
        guard let view = view else { return }
        
        hideExistingViews(in: view)

        view.addSubview(self)
        setNeedsLayout()

        animator.animateIn(self) {
            self.addTimer(duration: duration)
        }
    }

    /// Hides the flash message.
    public func hide() {
        timer?.invalidate()
        timer = nil

        animator.animationOut(self) {
            self.removeFromSuperview()
        }
    }

    /// Hides all existing flash messages in the supplied view.
    /// - Parameter view: The view.
    private func hideExistingViews(in view: UIView) {
        let views = view.subviews.compactMap { $0 as? FlashView }
        views.forEach { $0.hide() }
    }

    // MARK: - State

    private func updateText(_ text: String) {
        textLabel.text = text
    }

    private func updateImage(_ image: UIImage?) {
        imageView.image = image
    }

    private func addTimer(duration: TimeInterval) {
        guard timer == nil else { return }

        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            self.hide()
        }
    }
}
