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
public protocol FlashAnimator {
    /// Animation completion handler.
    typealias CompletionHandler = () -> Void

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

extension DefaultAnimator {
    
    /// The animation configuration.
    public struct Configuration {
        public var duration: TimeInterval
        public var dampingRatio: CGFloat
        public var initialVelocity: CGVector
        public var translateAmount: CGFloat
        public var scaleCoefficient: CGFloat
        
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

/// The default flash animator.
public struct DefaultAnimator: FlashAnimator {

    // MARK: - Properties
    
    public let configuration: Configuration

    // MARK: - Initialization
    
    /// Initialize with the supplied animation duration.
    /// - Parameter configuration: The animation configuration.
    public init(configuration: Configuration? = nil) {
        self.configuration = configuration ?? .defaultConfiguration()
    }

    private func scaleAndOffset(t: CGAffineTransform, alignment: FlashView.Configuration.Alignment) -> CGAffineTransform {
        let orientation: CGFloat = alignment == .bottom ? 1 : -1
        var transform = t.translatedBy(x: 0, y: configuration.translateAmount * orientation)
        transform = transform.scaledBy(x: configuration.scaleCoefficient, y: configuration.scaleCoefficient)
        return transform
    }

    // MARK: - FlashAnimator Conformance

    public func animateIn(_ flashView: FlashView, completion: @escaping CompletionHandler) {
        flashView.alpha = 0
        flashView.transform = scaleAndOffset(t: flashView.transform, alignment: flashView.configuration.alignment)

        let timingParameters = UISpringTimingParameters(dampingRatio: configuration.dampingRatio,
                                                        initialVelocity: configuration.initialVelocity)
        let animator = UIViewPropertyAnimator(duration: configuration.duration, timingParameters: timingParameters)

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
        let animator = UIViewPropertyAnimator(duration: configuration.duration, curve: .easeInOut)

        animator.addAnimations {
            flashView.alpha = 0
        }
        animator.addAnimations {
            flashView.transform = scaleAndOffset(t: flashView.transform, alignment: flashView.configuration.alignment)
        }
        animator.addCompletion { _ in
            completion()
        }

        animator.startAnimation()
    }
}
