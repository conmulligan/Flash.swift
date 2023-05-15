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

    private let timingParameters = UISpringTimingParameters(dampingRatio: 0.5,
                                                            initialVelocity: CGVector(dx: 1.0, dy: 0.2))

    private let translateAmount: CGFloat = 16

    private let scaleCoefficient: CGFloat = 0.95

    /// Initialize with the supplied animation duration.
    /// - Parameter duration: The animation duration.
    public init(duration: TimeInterval = 0.33) {
        self.duration = duration
    }

    private func scaleAndOffset(t: CGAffineTransform, alignment: FlashView.Alignment) -> CGAffineTransform {
        let orientation: CGFloat = alignment == .bottom ? 1 : -1
        var transform = t.translatedBy(x: 0, y: translateAmount * orientation)
        transform = transform.scaledBy(x: scaleCoefficient, y: scaleCoefficient)
        return transform
    }

    // MARK: - FlashAnimator Conformance

    public func animateIn(_ flashView: FlashView, completion: @escaping CompletionHandler) {
        flashView.alpha = 0
        flashView.transform = scaleAndOffset(t: flashView.transform, alignment: flashView.configuration.alignment)

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
            flashView.transform = scaleAndOffset(t: flashView.transform, alignment: flashView.configuration.alignment)
        }
        animator.addCompletion { _ in
            completion()
        }

        animator.startAnimation()
    }
}
