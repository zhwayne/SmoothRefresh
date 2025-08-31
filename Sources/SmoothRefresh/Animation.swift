//
//  Animation.swift
//  SmoothRefresh
//
//  Created by W Zh on 2025/8/31.
//

import UIKit

@MainActor func withSmoothAnimation(_ animations: @escaping () -> Void) async {
    let animator = UIViewPropertyAnimator(
        duration: 1,
        timingParameters: UISpringTimingParameters()
    )
    animator.addAnimations(animations)
    animator.startAnimation()
    let _ = await animator.addCompletion()
}

@MainActor func withSmoothAnimation(_ animations: @escaping () -> Void, complection: ((Bool) -> Void)? = nil) {
    let animator = UIViewPropertyAnimator(
        duration: 1,
        timingParameters: UISpringTimingParameters()
    )
    animator.addAnimations(animations)
    animator.startAnimation()
    animator.addCompletion { complection?($0 == .end) }
}
