//
//  FlashView.swift
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

extension FlashView {
    /// The flash view configuration.
    @MainActor
    public struct Configuration {

        /// The flash view's alignment, relative to its parent view.
        public var alignment: Configuration.Alignment

        /// The image-text spacing.
        public var spacing: CGFloat

        /// The flash view's layout insets, relative to its parent view.
        public var insets: UIEdgeInsets

        /// The flash view's inner content insets.
        public var contentInsets: UIEdgeInsets

        /// The background properties.
        public var backgroundProperties: Configuration.BackgroundProperties

        /// The image properties.
        public var imageProperties: Configuration.ImageProperties

        /// The title text properties.
        public var titleProperties: Configuration.TitleProperties

        /// A Boolean value that determines whether the flash view plays haptic feedback when shown.
        public var playsHaptics: Bool

        /// A Boolean value that determines whether the flash view is dismissed when tapped.
        public var tapToDismiss: Bool

        /// A Boolean value that determines whether the flash view attempts to inset automatically to avoid overlapping navigation UI.
        public var appliesAdditionalInsetsAutomatically: Bool

        /// The flash view animator.
        public var animator: FlashAnimator

        /// Creates a new flash view configuration using the supplied properties.
        ///
        /// Use this initiazer if you want to create a flash view configuration from scratch.
        /// If you only want to change one or two properties while otherwise keeping the default configuration intact,
        /// consider creating a configuration using ``FlashView/Configuration-swift.struct/defaultConfiguration()`` and changing that as needed.
        ///
        /// - Parameters:
        ///   - alignment: The flash view ``alignment-swift.property``.
        ///   - spacing: The image-text ``spacing``.
        ///   - insets: The layout ``insets``.
        ///   - contentInsets: The ``contentInsets``.
        ///   - backgroundProperties: The ``backgroundProperties-swift.property``.
        ///   - imageProperties: The ``imageProperties-swift.property``.
        ///   - titleProperties: The title text ``titleProperties-swift.property``.
        ///   - playsHaptics: A boolean, ``playsHaptics`` determines whether the flash view plays haptic feedback when shown.
        ///   - tapToDismiss: A boolean, ``tapToDismiss``  determines whether the flash view is dismissed when tapped.
        ///   - appliesAdditionalInsetsAutomatically: A Boolean ``appliesAdditionalInsetsAutomatically`` determines whether the flash view attempts to inset automatically.
        ///   - animator: The ``animator``.
        public init(
            alignment: Configuration.Alignment? = nil,
            spacing: CGFloat? = nil,
            insets: UIEdgeInsets? = nil,
            contentInsets: UIEdgeInsets? = nil,
            backgroundProperties: Configuration.BackgroundProperties? = nil,
            imageProperties: Configuration.ImageProperties? = nil,
            titleProperties: Configuration.TitleProperties? = nil,
            playsHaptics: Bool? = nil,
            tapToDismiss: Bool? = nil,
            appliesAdditionalInsetsAutomatically: Bool? = nil,
            animator: FlashAnimator? = nil
        ) {
            self.alignment = alignment ?? .top
            self.spacing = spacing ?? 0
            self.insets = insets ?? .zero
            self.contentInsets = contentInsets ?? .zero
            self.backgroundProperties = backgroundProperties ?? .init(color: .clear, cornerRadius: 0)
            self.imageProperties = imageProperties ?? .init(tintColor: .tintColor)
            self.titleProperties =
                titleProperties
                ?? .init(
                    textColor: .label,
                    font: .preferredFont(forTextStyle: .body),
                    numberOfLines: 0)
            self.playsHaptics = playsHaptics ?? false
            self.tapToDismiss = tapToDismiss ?? false
            self.appliesAdditionalInsetsAutomatically = appliesAdditionalInsetsAutomatically ?? false
            self.animator = animator ?? DefaultAnimator()
        }
    }
}

extension FlashView.Configuration {
    /// The flash view alignment, relative to its parent.
    public enum Alignment {
        /// Top alignment.
        case top

        /// Bottom alignment.
        case bottom
    }

    /// The flash view's background properties.
    public struct BackgroundProperties {
        /// The background color.
        public var color: UIColor

        /// The corner radius.
        public var cornerRadius: CGFloat
    }

    /// The flash view image properties.
    public struct ImageProperties {
        /// The image tint color.
        public var tintColor: UIColor
    }

    /// The flash view title text properties.
    public struct TitleProperties {
        /// The title text color.
        public var textColor: UIColor

        /// The title text font.
        public var font: UIFont

        /// The number of lines to show. A value of `0` will show as many lines as possible.
        public var numberOfLines: Int
    }
}

extension FlashView.Configuration {

    /// The shared configuration.
    ///
    /// Use this static property to configure the shared configuration used by all flash views.
    /// If you only want to customize the appearance of a single flash view, consider passing a ``FlashView/Configuration-swift.struct`` instance to
    /// ``FlashView/init(text:image:configuration:)`` instead.
    @MainActor
    public static var shared: FlashView.Configuration = .defaultConfiguration()

    /// The default configuration.
    public static func defaultConfiguration() -> FlashView.Configuration {
        .init(
            alignment: .top,
            spacing: 4,
            insets: .init(top: 16, left: 16, bottom: 16, right: 16),
            contentInsets: .init(top: 8, left: 12, bottom: 8, right: 12),
            backgroundProperties: .init(color: .systemGray5, cornerRadius: 10),
            imageProperties: .init(tintColor: .label.withAlphaComponent(0.8)),
            titleProperties: .init(
                textColor: .label,
                font: .preferredFont(forTextStyle: .body),
                numberOfLines: 2),
            playsHaptics: true,
            tapToDismiss: true,
            appliesAdditionalInsetsAutomatically: true,
            animator: DefaultAnimator())
    }
}

/// A flash message view.
///
///
public class FlashView: UIView {

    // MARK: - Properties

    /// The title text.
    public var text: String {
        didSet { updateText(text) }
    }

    /// The image.
    public var image: UIImage? {
        didSet { updateImage(image) }
    }

    /// The flash configuration.
    public var configuration: Configuration {
        didSet { updateConfiguration(configuration) }
    }

    /// The visibility duration timer.
    private var timer: Timer?

    /// The tap gesture recognizer.
    private var tapGestureRecognizer: UITapGestureRecognizer?

    /// The background view.
    private lazy var backgroundView: BackgroundView = {
        let backgroundView = BackgroundView(frame: bounds)
        backgroundView.fillColor = .systemGray5
        backgroundView.cornerRadius = 10
        return backgroundView
    }()

    /// The image view.
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    /// The text label.
    private lazy var textLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 10
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    // MARK: - Initialization

    /// Creates a new flash view.
    ///
    /// - Parameters:
    ///   - text: The title text.
    ///   - image: An optional image. If empty, only the title text is displayed.
    ///   - configuration: The flash view configuration. If omitted, the flash view will use the shared configuration.
    public init(
        text: String,
        image: UIImage? = nil,
        configuration: Configuration? = nil
    ) {
        self.text = text
        self.image = image
        self.configuration = configuration ?? Configuration.shared
        super.init(frame: .zero)

        for view in [backgroundView, imageView, textLabel] {
            addSubview(view)
        }

        updateText(text)
        updateImage(image)
        updateConfiguration(self.configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        layoutIfNeeded()
        reposition()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 0.2) {
                self.reposition()
            }
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        guard let superview else { return }

        // Layout subviews.

        let contentFrame = establishContentFrame(for: superview)

        let contentBounds = CGRect(origin: .zero, size: contentFrame.size)
            .inset(by: configuration.contentInsets)

        let distance = (image != nil) ? image!.size.width + configuration.spacing : 0
        var (f1, f2) = contentBounds.divided(atDistance: distance, from: .minXEdge)

        let textBounds = textLabel.textRect(
            forBounds: f2,
            limitedToNumberOfLines: configuration.titleProperties.numberOfLines)

        f2.size = textBounds.size
        f1.size = CGSize(width: image?.size.width ?? 0, height: f2.size.height)

        imageView.frame = f1
        textLabel.frame = f2
    }

    private func reposition() {
        guard let superview else { return }
        let contentFrame = establishContentFrame(for: superview)

        bounds.size = CGSize(
            width: (textLabel.frame.maxX + configuration.contentInsets.right).rounded(),
            height: (textLabel.frame.maxY + configuration.contentInsets.bottom).rounded()
        )

        backgroundView.frame = bounds

        switch configuration.alignment {
        case .top:
            center = CGPoint(x: superview.center.x, y: contentFrame.minY + (bounds.size.height / 2))
        case .bottom:
            center = CGPoint(x: superview.center.x, y: contentFrame.maxY - (bounds.size.height / 2))
        }
    }

    override public func didMoveToSuperview() {
        super.didMoveToSuperview()

        layoutIfNeeded()
        reposition()
    }

    // MARK: - Layout

    /// Calculate the content frame within the supplied superview.
    ///
    /// This frame accounts for the superview's safe area insets, and the flash view's `insets` property.
    ///
    /// - Parameter superview: The superview.
    /// - Returns: The content frame.
    private func establishContentFrame(for superview: UIView) -> CGRect {
        // Inset from the parent view's safe area.
        var frame = superview.bounds.inset(by: superview.safeAreaInsets)

        // If automatic insetting is enabled, apply additional insets.
        if configuration.appliesAdditionalInsetsAutomatically {
            frame = frame.inset(by: additionalInsets(for: superview))
        }

        // Apply the configuration's insets.
        frame = frame.inset(by: configuration.insets)

        return frame
    }

    /// Calculates the additional insets needed to layout the flash view between ancestral navigation bars and tab bars.
    ///
    /// - Parameter superview: The superview.
    /// - Returns: The additional edge insets.
    private func additionalInsets(for superview: UIView) -> UIEdgeInsets {
        var additionalInsets = UIEdgeInsets.zero

        let topPoint = CGPoint(x: 5, y: superview.safeAreaInsets.top + 5)
        if let hitTest = superview.hitTest(topPoint, with: nil),
            let navigationBar: UINavigationBar = firstAncestralView(in: hitTest)
        {
            additionalInsets.top = navigationBar.frame.maxY - superview.safeAreaInsets.top
        }

        let bottomPoint = CGPoint(
            x: superview.frame.size.width / 2,
            y: superview.frame.maxY - superview.safeAreaInsets.bottom - 5
        )
        if let hitTest = superview.hitTest(bottomPoint, with: nil) {
            if let tabBar: UITabBar = firstAncestralView(in: hitTest) {
                additionalInsets.bottom = superview.frame.maxY - tabBar.frame.minY - superview.safeAreaInsets.bottom
            } else if let toolbar: UIToolbar = firstAncestralView(in: hitTest) {
                additionalInsets.bottom = superview.frame.maxY - toolbar.frame.minY - superview.safeAreaInsets.bottom
            }
        }

        return additionalInsets
    }

    /// Walk the view hierachy to determine if the supplied view, or one of its ancestors, is a view of type `V`.
    ///
    /// - Parameter view: The view whose hierachy to walk back from.
    /// - Returns: A `V` instance if found, otherwise `nil`.
    private func firstAncestralView<V: UIView>(in view: UIView) -> V? {
        var ancestralView: V?
        var currentView: UIView? = view

        while ancestralView == nil, currentView != nil {
            if currentView is V {
                ancestralView = currentView as? V
            } else {
                currentView = currentView?.superview
            }
        }

        return ancestralView
    }

    /// Hides all existing flash messages in the supplied view.
    ///
    /// - Parameter view: The view.
    private func hideExistingViews(in view: UIView) {
        let views = view.subviews.compactMap { $0 as? FlashView }
        for view in views {
            view.hide()
        }
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

    private func updateConfiguration(_ configuration: Configuration) {
        backgroundView.fillColor = configuration.backgroundProperties.color
        backgroundView.cornerRadius = configuration.backgroundProperties.cornerRadius

        textLabel.textColor = configuration.titleProperties.textColor
        textLabel.font = configuration.titleProperties.font
        textLabel.numberOfLines = configuration.titleProperties.numberOfLines

        imageView.tintColor = configuration.imageProperties.tintColor

        if configuration.tapToDismiss, tapGestureRecognizer == nil {
            tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismiss(_:)))
            addGestureRecognizer(tapGestureRecognizer!)
        } else if let tapGestureRecognizer {
            removeGestureRecognizer(tapGestureRecognizer)
            self.tapGestureRecognizer = nil
        }

        layoutSubviews()
    }

    @objc private func dismiss(_ sender: AnyObject) {
        hide()
    }

    private func addTimer(duration: TimeInterval) {
        guard timer == nil, duration > 0 else { return }

        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            Task { @MainActor in
                self.hide()
            }
        }
    }
}

extension FlashView {

    // MARK: - Presentation

    private var keyWindow: UIWindow? {
        let foregroundScene =
            UIApplication.shared.connectedScenes
            .first { $0.activationState == .foregroundActive } as? UIWindowScene
        return foregroundScene?.windows.first(where: \.isKeyWindow)
    }

    /// Shows the flash message.
    ///
    /// When a flash view is ready to be displayed, call this method. If you want to show the flash view in a specific view, pass it using the `view` property.
    /// Otherwise, the flash view will be added directly to the key window's view hierarchy.
    ///
    /// The flash view will be animated in using a ``FlashAnimator``.
    /// You can customize the flash animator using the configuration's ``FlashView/Configuration-swift.struct/animator`` property.
    ///
    /// To change the duration for which a flash view is visible, use the `duration` parameter. If you want the flash view to remain visible indefinitely,
    /// set `duration` to `0`.
    ///
    /// To hide the flash message manually, call ``hide()``.
    ///
    /// - Parameters:
    ///   - view: The view to show the flash message in. If a view is omitted, the flash view will be added direclty to the key window's view heirarchy.
    ///   - duration: The flash message duration in seconds. the default value is `2`. Set duration to `0` if you want the flash message to display indefinitely.
    public func show(in view: UIView? = nil, duration: TimeInterval = 2) {
        guard let view = view ?? keyWindow else { return }

        hideExistingViews(in: view)

        view.addSubview(self)

        configuration.animator.animateIn(self) {
            if duration > 0 {
                self.addTimer(duration: duration)
            }
        }

        if configuration.playsHaptics {
            playHaptics()
        }
    }

    /// Hides the flash view.
    ///
    /// If the flash view has been configured to display indefinitely, or you just want to hide it early, use this method to hide it.
    ///
    /// The flash view will be animated in using a ``FlashAnimator``.
    /// You can customize the flash animator using the configuration's ``FlashView/Configuration-swift.struct/animator`` property.
    public func hide() {
        timer?.invalidate()
        timer = nil

        configuration.animator.animationOut(self) {
            self.removeFromSuperview()
        }
    }
}
