//
//  FlashAnimator.swift
//  Flash
//
//  Created by Conor Mulligan on 14/05/2023.
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
///
/// By default, the flash view uses the ``DefaultAnimator`` to animate in and out.
/// If you need finer control over the flash view's animation, create a new type that conforms to `FlashAnimator`.
public protocol FlashAnimator {
    /// The animation completion handler.
    typealias CompletionHandler = () -> Void

    /// Animates in the flash view.
    ///
    /// - Parameters:
    ///   - flashView: The flash view to animate in.
    ///   - completion: The ``CompletionHandler``. This must be called when the animation has finished.
    func animateIn(_ flashView: FlashView, completion: @escaping CompletionHandler)

    /// Animates out the flash view.
    ///
    /// - Parameters:
    ///   - flashView: The flash view to animate out.
    ///   - completion: The ``CompletionHandler`` This must be called when the animation has finished.
    func animationOut(_ flashView: FlashView, completion: @escaping CompletionHandler)
}

extension DefaultAnimator {

    /// The animation configuration.
    public struct Configuration {
        /// The animation duration.
        public var duration: TimeInterval
        
        /// The spring damping ratio.
        public var dampingRatio: CGFloat
        
        /// The initial velocity.
        public var initialVelocity: CGVector
        
        /// The distance in points the view is translated along the y axis when animating.
        public var translateAmount: CGFloat
        
        /// The scale amount. A value of `1` will not scale the view.
        public var scaleCoefficient: CGFloat
        
        /// Creates a new flash animator.
        /// - Parameters:
        ///   - duration: The animation ``duration``.
        ///   - dampingRatio: The spring ``dampingRatio``.
        ///   - initialVelocity: The ``initialVelocity``.
        ///   - translateAmount: The ``translateAmount`` distance in points.
        ///   - scaleCoefficient: The ``scaleCoefficient``.  A value of `1` will not scale the view.
        public init(duration: TimeInterval? = nil,
                    dampingRatio: CGFloat? = nil,
                    initialVelocity: CGVector? = nil,
                    translateAmount: CGFloat? = nil,
                    scaleCoefficient: CGFloat? = nil) {
            self.duration = duration ?? 0
            self.dampingRatio = dampingRatio ?? 1
            self.initialVelocity = initialVelocity ?? .zero
            self.translateAmount = translateAmount ?? 0
            self.scaleCoefficient = scaleCoefficient ?? 1
        }
    }
}

extension DefaultAnimator.Configuration {

    /// The default configuration.
    public static func defaultConfiguration() -> DefaultAnimator.Configuration {
        .init(duration: 0.33,
              dampingRatio: 0.6,
              initialVelocity: .zero,
              translateAmount: 16,
              scaleCoefficient: 0.95
        )
    }
}

/// The default ``FlashAnimator``.
///
/// The flash animator is responsible for animating in a flash view when shown, and animating out when hidden.
///
/// You can adjust the animator's behaviour by creating a custom ``DefaultAnimator/Configuration-swift.struct``.
/// If you need finer control over the flash view's animation beyond what's possible with the default animator, see ``FlashAnimator``.
public struct DefaultAnimator: FlashAnimator {

    // MARK: - Properties

    /// The animation configuration.
    public let configuration: Configuration

    // MARK: - Initialization

    /// Creates a new animator using the supplied configuration.
    ///
    /// - Parameter configuration: The animation ``configuration-swift.property``.
    public init(configuration: Configuration? = nil) {
        self.configuration = configuration ?? .defaultConfiguration()
    }

    private func scaleAndOffset(t: CGAffineTransform, alignment: FlashView.Configuration.Alignment) -> CGAffineTransform {
        let orientation: CGFloat = alignment == .bottom ? 1 : -1
        var transform = t.translatedBy(x: 0, y: configuration.translateAmount * orientation)
        transform = transform.scaledBy(x: configuration.scaleCoefficient, y: configuration.scaleCoefficient)
        return transform
    }

    // MARK: - Flash Animator

    /// Animates in the flash view.
    ///
    /// - Parameters:
    ///   - flashView: The flash view to animate in.
    ///   - completion: The ``FlashAnimator/CompletionHandler``. This is called when the animation has finished.
    public func animateIn(_ flashView: FlashView, completion: @escaping CompletionHandler) {
        flashView.alpha = 0
        flashView.transform = scaleAndOffset(t: flashView.transform, alignment: flashView.configuration.alignment)

        let timingParameters = UISpringTimingParameters(dampingRatio: configuration.dampingRatio,
                                                        initialVelocity: configuration.initialVelocity)
        let animator = UIViewPropertyAnimator(duration: configuration.duration,
                                              timingParameters: timingParameters)

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

    /// Animates out the flash view.
    ///
    /// - Parameters:
    ///   - flashView: The flash view to animate out.
    ///   - completion: The ``FlashAnimator/CompletionHandler``. This is called when the animation has finished.
    public func animationOut(_ flashView: FlashView, completion: @escaping CompletionHandler) {
        let animator = UIViewPropertyAnimator(duration: configuration.duration, curve: .easeInOut)

        animator.addAnimations {
            flashView.alpha = 0
        }
        animator.addAnimations {
            flashView.transform = scaleAndOffset(t: flashView.transform,
                                                 alignment: flashView.configuration.alignment)
        }
        animator.addCompletion { _ in
            completion()
        }

        animator.startAnimation()
    }
}
