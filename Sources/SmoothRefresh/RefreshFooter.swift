//
//  RefreshFooter.swift
//  SmoothRefresh
//
//  Created by W Zh on 2025/8/31.
//

import UIKit
import Combine

open class RefreshFooter: UIView {

    public private(set) var refreshState: RefreshState = .idle
    public private(set) var dragDistance: CGFloat = 0
    
    public let indicatorView = UIActivityIndicatorView(style: .large)
    
    /// RefreshHeader 应该直接被添加在 UIScrollView 上
    private var scrollView: UIScrollView? { superview as? UIScrollView }
    private var constraint: NSLayoutConstraint?
    private var cancellables = Set<AnyCancellable>()
    private var originalBottomInset: CGFloat = 0
    private var dragEndContinuation: CheckedContinuation<Void, Never>?
    private var refreshTask: Task<Void, Never>?
    private let feedback = UIImpactFeedbackGenerator(style: .light)
    
    var onRefresh: () async -> Void = { try? await Task.sleep(nanoseconds: 1_000_000_000) }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .orange
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.hidesWhenStopped = false
        addSubview(indicatorView)
        
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func beginRefreshing() {
//        guard let scrollView, refreshState != .refreshing else { return }
//        refreshState = .refreshing
//        refreshTask = Task(priority: .userInitiated) { @MainActor in
//            scrollView.panGestureRecognizer.isEnabled = false
//            await withSmoothAnimation { [self] in
//                scrollView.contentInset.top = originalBottomInset + bounds.height
//            }
//            scrollView.panGestureRecognizer.isEnabled = true
//            await triggerRefresh(scrollView: scrollView)
//        }
    }
    
    open func endRefreshing() {
//        guard let scrollView, refreshState == .refreshing else { return }
//        refreshTask?.cancel()
//        Task(priority: .userInitiated) { @MainActor in
//            await animateToInitialState(scrollView: scrollView)
//        }
    }
    
    open override func didMoveToSuperview() {
        cancellables = []
        super.didMoveToSuperview()
        guard let scrollView else { return }
        
        feedback.prepare()
        translatesAutoresizingMaskIntoConstraints = false
        constraint = topAnchor.constraint(
            equalTo: scrollView.topAnchor,
            constant: 0
        )
        let heightConstraint = heightAnchor.constraint(equalToConstant: 60)
        heightConstraint.priority = .defaultHigh
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            constraint!,
            heightConstraint
        ])
        
        scrollView.multicastDelegate.addDelegate(self)
        originalBottomInset = scrollView.contentInset.bottom
        
        Publishers
            .CombineLatest3(
                scrollView.publisher(for: \.bounds),
                scrollView.publisher(for: \.contentSize),
                scrollView.publisher(for: \.contentInset)
            )
            .sink(receiveValue: { [weak self] (bounds, size, inset) in
                guard let self else { return }
                let height = max(bounds.height, size.height)
                constraint?.constant = height + inset.bottom
            })
            .store(in: &cancellables)
        
//        scrollView.publisher(for: \.contentInset)
//            .removeDuplicates()
//            .sink { [weak self] contentInset in
//                guard let self, refreshState == .idle else { return }
//                constraint?.constant = -contentInset.bottom
//            }
//            .store(in: &cancellables)
    }
    
    open func didUpdateRefreshState(_ refreshState: RefreshState) {
//        if refreshState == .readyToRefresh {
//            feedback.impactOccurred()
//            indicatorView.startAnimating()
//        }
//        else if refreshState == .refreshing {
//            indicatorView.startAnimating()
//        }
//        else if refreshState == .completed {
//            indicatorView.stopAnimating()
//        }
//        else if refreshState == .pulling {
//            indicatorView.stopAnimating()
//        }
//        else if refreshState == .idle {
//            indicatorView.stopAnimating()
//            indicatorView.transform = .identity
//        }
    }
    
    open func didUpdateDragDistance(_ dragDistance: CGFloat) {
//        let progress = max(0, min(1, -dragDistance / bounds.height))
//        indicatorView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * progress)
    }
}

extension RefreshFooter: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldHandlePulling else { return }
        
//        let offsetY = scrollView.contentOffset.y
//        let insetTop = scrollView.adjustedContentInset.top
//        dragDistance = offsetY + insetTop
//        didUpdateDragDistance(dragDistance)
//        
//        var newRefreshState = refreshState
//        let threshold = -bounds.height
//        
//        if dragDistance >= 0 {
//            newRefreshState = .idle
//        } else if dragDistance <= threshold {
//            newRefreshState = .readyToRefresh
//        } else {
//            newRefreshState = .pulling
//        }
//        
//        if refreshState != newRefreshState {
//            refreshState = newRefreshState
//            didUpdateRefreshState(newRefreshState)
//        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if refreshState == .readyToRefresh {
//            scrollView.contentInset.top += bounds.height
//            refreshState = .refreshing
//            refreshTask = Task(priority: .userInitiated) { @MainActor in
//                await triggerRefresh(scrollView: scrollView)
//            }
//        } else if refreshState == .refreshing {
//            dragEndContinuation?.resume()
//            dragEndContinuation = nil
//        }
    }
    
    private var shouldHandlePulling: Bool {
        refreshState == .idle ||
        refreshState == .pulling ||
        refreshState == .readyToRefresh
    }
    
    private func triggerRefresh(scrollView: UIScrollView) async {
        await onRefresh()
        if Task.isCancelled {
            return
        }
        await animateToInitialState(scrollView: scrollView)
    }
    
    private func animateToInitialState(scrollView: UIScrollView) async {
//        if scrollView.isDragging {
//            await waitForDragEnd()
//        }
//        refreshState = .completed
//        scrollView.panGestureRecognizer.isEnabled = false
//        defer {
//            scrollView.panGestureRecognizer.isEnabled = true
//            refreshState = .idle
//        }
//        await withSmoothAnimation {
//            scrollView.contentInset.top = self.originalBottomInset
//        }
    }
    
    private func waitForDragEnd() async {
        await withCheckedContinuation { continuation in
            dragEndContinuation = continuation
        }
    }
}
