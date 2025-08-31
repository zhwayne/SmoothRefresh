//
//  MulticastDelegate.swift
//  SmoothRefresh
//
//  Created by W Zh on 2025/8/31.
//

import UIKit
import ObjectiveC.runtime

private class WeakBox<T: AnyObject> {
    weak var value: T?
    init(_ value: T) { self.value = value }
}

final class MulticastDelegate<T> {
    fileprivate private(set) var delegates: [WeakBox<AnyObject>] = []
    
    func addDelegate(_ delegate: T) {
        delegates.append(WeakBox(delegate as AnyObject))
    }
    
    func removeDelegate(_ delegate: T) {
        delegates.removeAll { $0.value === (delegate as AnyObject) }
    }
    
    func invoke(_ block: (T) -> Void) {
        delegates = delegates.filter { $0.value != nil }
        for box in delegates {
            if let d = box.value as? T {
                block(d)
            }
        }
    }
}

final class ScrollViewMulticastProxy: NSObject, UIScrollViewDelegate {
    private let multicast = MulticastDelegate<UIScrollViewDelegate>()
    
    func addDelegate(_ delegate: UIScrollViewDelegate) {
        multicast.addDelegate(delegate)
    }
    
    func removeDelegate(_ delegate: UIScrollViewDelegate) {
        multicast.removeDelegate(delegate)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        multicast.invoke {
            $0.scrollViewDidScroll?(scrollView)
        }
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        multicast.invoke {
            $0.scrollViewDidZoom?(scrollView)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        multicast.invoke {
            $0.scrollViewWillBeginDragging?(scrollView)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        multicast.invoke {
            $0.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        multicast.invoke {
            $0.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        multicast.invoke {
            $0.scrollViewWillBeginDecelerating?(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        multicast.invoke {
            $0.scrollViewDidEndDecelerating?(scrollView)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        multicast.invoke {
            $0.scrollViewDidEndScrollingAnimation?(scrollView)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        var view: UIView?
        multicast.invoke {
            view = $0.viewForZooming?(in: scrollView)
        }
        return view
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        multicast.invoke {
            $0.scrollViewWillBeginZooming?(scrollView, with: view)
        }
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        multicast.invoke {
            $0.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
        }
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        var scrollToTop: Bool?
        multicast.invoke {
            scrollToTop = $0.scrollViewShouldScrollToTop?(scrollView)
        }
        return scrollToTop ?? true
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        multicast.invoke {
            $0.scrollViewDidScrollToTop?(scrollView)
        }
    }
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        multicast.invoke {
            $0.scrollViewDidChangeAdjustedContentInset?(scrollView)
        }
    }
}


extension UIScrollView {
    
    @MainActor private struct AssociatedKeys {
        static var multicastProxy = malloc(1)
    }
    
    var multicastDelegate: ScrollViewMulticastProxy {
        if let proxy = objc_getAssociatedObject(self, &AssociatedKeys.multicastProxy) as? ScrollViewMulticastProxy {
            return proxy
        }
        let proxy = ScrollViewMulticastProxy()
        objc_setAssociatedObject(self, &AssociatedKeys.multicastProxy, proxy, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        if let delegate {
            proxy.addDelegate(delegate)
        }
        delegate = proxy
        UIScrollView.swizzleDelegateSetter
        return proxy
    }
    
    static let swizzleDelegateSetter: Void = {
        MethodSwizzler.swizzleInstanceMethod(
            targetClass: UIScrollView.self,
            originalSelector: #selector(setter: UIScrollView.delegate),
            swizzledSelector: #selector(UIScrollView.swizzled_setDelegate(_:))
        )
    }()
    
    @objc private func swizzled_setDelegate(_ delegate: UIScrollViewDelegate?) {
        let proxy = multicastDelegate
        if let delegate, delegate !== proxy {
            // TODO: 可以把原始 delegate 做个标记。
            // 下次设置 scrollView.delegate = nil 的时候可以根据这个标记将原始 delegate 移除。
            proxy.addDelegate(delegate)   // 收录外部 delegate
        }
        // 始终把 proxy 装回去
        swizzled_setDelegate(proxy)
    }
}
