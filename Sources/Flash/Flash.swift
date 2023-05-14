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

/// A flash message view.
public class FlashView: UIView {

    /// The flash view alignment.
    public enum Alignment {
        case top
        case bottom
    }

    // MARK: - Properties

    /// The toast text.
    public var text: String {
        didSet { updateText(text) }
    }

    /// The toast image.
    public var image: UIImage? {
        didSet { updateImage(image) }
    }

    /// The alignment.
    public var alignment: Alignment = .top {
        didSet { setNeedsLayout() }
    }

    /// The image-text spacing.
    public var spacing: CGFloat = 8 {
        didSet { setNeedsLayout() }
    }

    /// The insets used to layout a flash view within its superview.
    public var insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16) {
        didSet { setNeedsLayout() }
    }

    /// The content insets.
    public var contentInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12) {
        didSet { setNeedsLayout() }
    }

    /// Plays haptic feedback when appearing.
    public var playsHaptics = true
    
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
                alignment: Alignment? = nil,
                animator: FlashAnimator? = nil ) {
        self.text = text
        self.image = image
        self.insets = insets ?? self.insets
        self.alignment = alignment ?? self.alignment
        self.animator = animator ?? FadeAnimator()
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

        // Layout subviews.

        let contentFrame = establishContentFrame(for: superview)
        let contentBounds = CGRect(origin: .zero, size: contentFrame.size).inset(by: contentInsets)

        let distance = (image != nil) ? image!.size.width + spacing : 0
        var (f1, f2) = contentBounds.divided(atDistance: distance, from: .minXEdge)

        let textSize = textLabel.sizeThatFits(f2.size)
        f2.size = textSize
        f1.size = CGSize(width: image?.size.width ?? 0, height: f2.size.height)

        imageView.frame = f1
        textLabel.frame = f2

        // Layout self.

        bounds.size = CGSize(
            width: (f2.maxX + contentInsets.right).rounded(),
            height: (f2.maxY + contentInsets.bottom).rounded()
        )

        switch alignment {
        case .top:
            center = CGPoint(x: superview.center.x, y: contentFrame.minY + (bounds.size.height / 2))
        case .bottom:
            center = CGPoint(x: superview.center.x, y: contentFrame.maxY - (bounds.size.height / 2))
        }
    }

    // MARK: - Layout
    
    /// Calculate the content frame within the supplied superview.
    /// This frame accounts for the superview's safe area insets, and the flash view's `insets` property.
    /// - Parameter superview: The superview.
    /// - Returns: The content frame.
    private func establishContentFrame(for superview: UIView) -> CGRect {
        let safeArea = superview.bounds.inset(by: superview.safeAreaInsets)
        return safeArea
            .inset(by: additionalInsets(for: superview))
            .inset(by: insets)
    }

    /// Calculates the additional insets needed to layout the flash view between ancestral navigation bars and tab bars.
    /// - Parameter superview: The superview.
    /// - Returns: The additional edge insets.
    private func additionalInsets(for superview: UIView) -> UIEdgeInsets {
        var additionalInsets = UIEdgeInsets.zero

        let topPoint = CGPoint(x: 5, y: superview.safeAreaInsets.top + 5)
        if let hitTest = superview.hitTest(topPoint, with: nil),
           let navigationBar: UINavigationBar = firstAncestralView(in: hitTest) {
            additionalInsets.top = navigationBar.frame.maxY - superview.safeAreaInsets.top
        }

        let bottomPoint = CGPoint(x: 5, y: superview.frame.maxY - superview.safeAreaInsets.bottom - 5)
        if let hitTest = superview.hitTest(bottomPoint, with: nil),
           let tabBar: UITabBar = firstAncestralView(in: hitTest) {
            additionalInsets.bottom = superview.frame.maxY - tabBar.frame.minY - superview.safeAreaInsets.bottom
        }

        return additionalInsets
    }

    /// Walk the view hierachy to find if the supplied view, or one of its ancestors, is a view of type `V`.
    /// - Parameter view: The view who's hierachy to walk back from.
    /// - Returns: A `V` instance if found, otherwise `nil`.
    private func firstAncestralView<V: UIView>(in view: UIView) -> V? {
        var ancestralView: V?
        var currentView: UIView? = view

        while ancestralView == nil {
            if currentView is V {
                ancestralView = currentView as? V
            } else {
                currentView = currentView?.superview
            }
        }

        return ancestralView
    }

    /// Hides all existing flash messages in the supplied view.
    /// - Parameter view: The view.
    private func hideExistingViews(in view: UIView) {
        let views = view.subviews.compactMap { $0 as? FlashView }
        views.forEach { $0.hide() }
    }

    /// Plays a light impact haptic feedback.
    private func playHaptics() {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
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

extension FlashView {
    
    // MARK: - Presentation

    /// Show the flash message in the supplised view.
    /// - Parameters:
    ///   - view: The view to show the flash message in.
    ///   - duration: The flash message duration.
    public func show(in view: UIView? = nil, duration: TimeInterval = 2) {
        var view = view
        if view == nil {
            view = UIApplication.shared.windows.first(where: \.isKeyWindow)
        }
        guard let view = view else { return }

        hideExistingViews(in: view)

        view.addSubview(self)
        setNeedsLayout()

        animator.animateIn(self) {
            self.addTimer(duration: duration)
        }
        
        if playsHaptics {
            playHaptics()
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

}
